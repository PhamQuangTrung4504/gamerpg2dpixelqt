import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../../constants/direction.dart';
import '../../constants/equipment_types.dart';
import '../../constants/game_constants.dart';
import '../../constants/player_state.dart';
import '../../core/exp_manager.dart';
import '../../models/attribute_type.dart';
import '../../models/character_stats.dart';
import '../../models/equipment.dart';
import '../../models/skill.dart';
import '../survival_game.dart';
import 'body_component.dart';
import 'equipment_layer_component.dart';
import 'monster_component.dart';
import 'skills/basic_slash_effect.dart';
import 'skills/flame_slash_projectile.dart';
import 'skills/shield_effect.dart';
import 'skills/sword_storm_area.dart';

class InventoryNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Component người chơi chính kết hợp Thân và Đa lớp trang bị (Multi-layer Equipment)
class PlayerComponent extends PositionComponent with HasGameReference<SurvivalGame> {
  final BodyComponent _body = BodyComponent();
  final Map<EquipmentType, EquipmentLayerComponent> _equipmentLayers = {};
  final Map<EquipmentType, Equipment> _equippedItems = {};

  // Hệ thống túi đồ (Inventory)
  static const int maxInventorySlots = 100;
  final List<Equipment> _inventory = [];
  final InventoryNotifier inventoryNotifier = InventoryNotifier();

  GameDirection _direction = GameDirection.down;
  CharacterState _state = CharacterState.idle;

  // Chỉ số gốc (Base Stats) có thể cộng điểm tiềm năng
  CharacterStats _baseStats = CharacterStats.initialBase;
  late CharacterStats _totalStats;
  double _currentHp = 100;
  double _currentMp = 100;
  int _gold = 0;

  late final ExpManager _expManager;

  // Cấp độ của các kỹ năng (khởi đầu cấp 1)
  final Map<String, int> _skillLevels = {
    SkillCatalog.danhThuong.id: 1,
    SkillCatalog.lietHoaDoatMenh.id: 1,
    SkillCatalog.vanKiemQuyTong.id: 1,
    SkillCatalog.nguKiemPhiKiem.id: 1,
  };

  // Vector di chuyển từ input (Joystick hoặc Bàn phím)
  Vector2 velocity = Vector2.zero();

  // Bộ đếm hồi phục HP/MP theo chu kỳ 1s
  double _regenTimer = 0.0;

  // Thời gian duy trì đòn tấn công
  double _attackTimer = 0.0;
  static const double _attackDuration = 0.25;

  // Bộ đếm hồi chiêu (Cooldown) cho Đòn đánh thường và 3 Kỹ năng
  double attackCooldownRemaining = 0.0;
  double skill1CooldownRemaining = 0.0;
  double skill2CooldownRemaining = 0.0;
  double skill3CooldownRemaining = 0.0;

  // Hiệu ứng Buff tạm thời (từ Kỹ năng 3)
  double _buffArmor = 0.0;
  double _buffCritResistance = 0.0;
  double _buffDuration = 0.0;

  PlayerComponent({Vector2? initialPosition})
      : super(
          position: initialPosition ?? Vector2(GameConstants.mapWidth / 2, GameConstants.mapHeight / 2),
          size: GameConstants.characterSize,
          anchor: Anchor.center,
          priority: 10,
        ) {
    _expManager = ExpManager(
      onLevelUp: (newLevel, skillPointsGained) {
        // Tự động hồi đầy HP và MP khi thăng cấp
        _currentHp = _totalStats.maxHp;
        _currentMp = _totalStats.maxMp;
        notifyInventoryChanged();
      },
    );

    // Mặc định trang bị kiếm gỗ cho nhân vật ban đầu
    _equippedItems[EquipmentType.sword] = EquipmentCatalog.kiemGo;
    _gold = 0;

    _recalculateStats();
    _currentHp = _totalStats.maxHp;
    _currentMp = _totalStats.maxMp;
  }

  GameDirection get direction => _direction;
  CharacterState get state => _state;
  CharacterStats get stats => _totalStats;
  double get currentHp => _currentHp;
  double get currentMp => _currentMp;
  int get gold => _gold;
  ExpManager get expManager => _expManager;
  int get attributePoints => _expManager.attributePoints;
  CharacterStats get baseStats => _baseStats;
  Map<EquipmentType, Equipment> get equippedItems => Map.unmodifiable(_equippedItems);
  List<Equipment> get inventory => List.unmodifiable(_inventory);

  /// Nâng cấp thuộc tính bằng Điểm Tiềm Năng (+20 HP, +1 HP/s, +20 MP, +1 MP/s, +3 ATK, +1 DEF)
  bool upgradeAttribute(AttributeType type) {
    if (!_expManager.useAttributePoint()) return false;

    switch (type) {
      case AttributeType.maxHp:
        _baseStats = _baseStats.copyWith(maxHp: _baseStats.maxHp + type.increaseAmount);
        _currentHp += type.increaseAmount;
      case AttributeType.hpRegen:
        _baseStats = _baseStats.copyWith(hpRegen: _baseStats.hpRegen + type.increaseAmount);
      case AttributeType.maxMp:
        _baseStats = _baseStats.copyWith(maxMp: _baseStats.maxMp + type.increaseAmount);
        _currentMp += type.increaseAmount;
      case AttributeType.mpRegen:
        _baseStats = _baseStats.copyWith(mpRegen: _baseStats.mpRegen + type.increaseAmount);
      case AttributeType.attackPower:
        _baseStats = _baseStats.copyWith(attackPower: _baseStats.attackPower + type.increaseAmount);
      case AttributeType.defense:
        _baseStats = _baseStats.copyWith(defense: _baseStats.defense + type.increaseAmount);
    }

    _recalculateStats();
    notifyInventoryChanged();
    return true;
  }

  /// Lấy cấp độ hiện tại của một kỹ năng
  int getSkillLevel(String skillId) => _skillLevels[skillId] ?? 1;

  /// Kiểm tra có thể nâng cấp kỹ năng hay không
  bool canUpgradeSkill(Skill skill) {
    final currentLevel = getSkillLevel(skill.id);
    if (currentLevel >= skill.maxSkillLevel) return false;
    if (_expManager.skillPoints <= 0) return false;
    if (_expManager.currentLevel < skill.requiredCharacterLevel) return false;
    return true;
  }

  /// Nâng cấp kỹ năng bằng Điểm Kỹ Năng
  bool upgradeSkill(Skill skill) {
    if (!canUpgradeSkill(skill)) return false;
    if (!_expManager.useSkillPoint()) return false;

    _skillLevels[skill.id] = getSkillLevel(skill.id) + 1;
    notifyInventoryChanged();
    return true;
  }

  void notifyInventoryChanged() {
    inventoryNotifier.notify();
  }

  void addGold(int amount) {
    _gold += amount;
    notifyInventoryChanged();
  }

  /// Thêm vật phẩm vào túi đồ
  bool addToInventory(Equipment item) {
    if (_inventory.length >= maxInventorySlots) return false;
    _inventory.add(item);
    notifyInventoryChanged();
    return true;
  }

  /// Xóa vật phẩm khỏi túi đồ
  bool removeFromInventory(Equipment item) {
    final removed = _inventory.remove(item);
    if (removed) {
      notifyInventoryChanged();
    }
    return removed;
  }

  /// Trang bị một vật phẩm từ túi đồ:
  /// Nếu ô đó đang có đồ, cất đồ cũ vào túi đồ.
  Future<void> equipFromInventory(Equipment item) async {
    _inventory.remove(item);
    final oldEquipped = _equippedItems[item.type];
    if (oldEquipped != null) {
      _inventory.add(oldEquipped);
    }
    await equip(item);
    notifyInventoryChanged();
  }

  /// Tháo trang bị trên người cất lại vào túi đồ
  bool unequipToInventory(EquipmentType type) {
    final item = _equippedItems[type];
    if (item == null) return false;
    if (_inventory.length >= maxInventorySlots) return false;

    unequip(type);
    _inventory.add(item);
    notifyInventoryChanged();
    return true;
  }

  /// Bán một vật phẩm trong túi đồ lấy vàng theo đúng giá catalog
  bool sellInventoryItem(Equipment item) {
    if (_inventory.remove(item)) {
      addGold(item.sellPrice);
      notifyInventoryChanged();
      return true;
    }
    return false;
  }

  /// Áp dụng hiệu ứng buff phòng thủ tạm thời (từ Kỹ năng 3)
  void applyTemporaryBuff({
    required double extraArmor,
    required double extraCritResistance,
    required double duration,
  }) {
    _buffArmor = extraArmor;
    _buffCritResistance = extraCritResistance;
    _buffDuration = duration;
    _recalculateStats();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Thêm Thân nhân vật
    await add(_body);

    // Nạp các lớp trang bị hình ảnh đang mặc
    for (final item in _equippedItems.values) {
      if (item.type.hasVisualLayer) {
        final layer = EquipmentLayerComponent(equipment: item);
        _equipmentLayers[item.type] = layer;
        await add(layer);
        layer.updateStateAndDirection(state: _state, direction: _direction);
      }
    }
    _syncLayers();
  }

  /// Trang bị một vật phẩm
  Future<void> equip(Equipment equipment) async {
    // Tháo trang bị cũ cùng loại nếu có
    if (_equipmentLayers.containsKey(equipment.type)) {
      final oldLayer = _equipmentLayers.remove(equipment.type);
      if (oldLayer != null && isMounted) {
        remove(oldLayer);
      }
    }

    _equippedItems[equipment.type] = equipment;

    // Nếu trang bị có lớp hình ảnh hiển thị trên người và component đã được mount
    if (equipment.type.hasVisualLayer && isMounted) {
      final layer = EquipmentLayerComponent(equipment: equipment);
      _equipmentLayers[equipment.type] = layer;
      await add(layer);
      layer.updateStateAndDirection(state: _state, direction: _direction);
    }
    _syncLayers();

    _recalculateStats();
    notifyInventoryChanged();
  }

  /// Lấy component hiển thị của trang bị theo loại
  EquipmentLayerComponent? getEquipmentLayer(EquipmentType type) => _equipmentLayers[type];

  /// Tháo trang bị theo loại
  void unequip(EquipmentType type) {
    if (_equippedItems.containsKey(type)) {
      _equippedItems.remove(type);
      final layer = _equipmentLayers.remove(type);
      if (layer != null && isMounted) {
        remove(layer);
      }
      _recalculateStats();
      notifyInventoryChanged();
    }
  }

  /// Tính toán lại toàn bộ chỉ số khi thay đổi trang bị hoặc kích hoạt buff
  void _recalculateStats() {
    var combined = _baseStats;
    for (final item in _equippedItems.values) {
      combined = combined + item.stats;
    }
    var total = combined.applyCoolnessMultiplier();

    // Áp dụng thêm chỉ số Buff tạm thời
    if (_buffArmor > 0 || _buffCritResistance > 0) {
      total = total.copyWith(
        defense: total.defense + _buffArmor,
        critResistance: total.critResistance + _buffCritResistance,
      );
    }
    _totalStats = total;

    // Đảm bảo HP và MP không vượt quá Max HP/MP mới
    _currentHp = _currentHp.clamp(0, _totalStats.maxHp);
    _currentMp = _currentMp.clamp(0, _totalStats.maxMp);
  }

  /// Kích hoạt Đòn đánh thường (Cận chiến hình bán nguyệt)
  bool performAttack() {
    if (attackCooldownRemaining > 0) return false;

    final skillLevel = getSkillLevel(SkillCatalog.danhThuong.id);
    final skillData = SkillCatalog.danhThuong.getDataForLevel(skillLevel);
    attackCooldownRemaining = skillData.cooldown;

    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();

    // Sinh hiệu ứng chém bán nguyệt trước mặt nhân vật
    if (isMounted) {
      game.world.add(
        BasicSlashEffectComponent(
          playerPosition: position,
          direction: _direction,
          skillLevel: skillLevel,
        ),
      );
    }
    return true;
  }

  /// Kỹ năng 1: Liệt Hỏa Đoạt Mệnh (Kiếm khí lửa xuyên thấu bay thẳng 250px)
  bool useSkill1() {
    if (skill1CooldownRemaining > 0) return false;
    final skillLevel = getSkillLevel(SkillCatalog.lietHoaDoatMenh.id);
    final skillData = SkillCatalog.lietHoaDoatMenh.getDataForLevel(skillLevel);

    if (!consumeMp(skillData.manaCost)) return false;

    skill1CooldownRemaining = skillData.cooldown;
    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();

    if (isMounted) {
      game.world.add(
        FlameSlashProjectileComponent(
          startPosition: position,
          flightDirection: _direction.toVector2(),
          skillLevel: skillLevel,
        ),
      );
    }
    return true;
  }

  /// Kỹ năng 2: Vạn Kiếm Quy Tông (Kiếm trận bán kính 90px, 3 đợt cự kiếm + làm chậm)
  bool useSkill2() {
    if (skill2CooldownRemaining > 0) return false;
    final skillLevel = getSkillLevel(SkillCatalog.vanKiemQuyTong.id);
    final skillData = SkillCatalog.vanKiemQuyTong.getDataForLevel(skillLevel);

    if (!consumeMp(skillData.manaCost)) return false;

    skill2CooldownRemaining = skillData.cooldown;
    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();

    if (isMounted) {
      // Tìm vị trí quái gần nhất trong vòng 200px hoặc cách trước mặt 80px
      final targetPos = _findNearestMonsterTarget() ?? (position + _direction.toVector2() * 80.0);
      game.world.add(
        SwordStormAreaComponent(
          centerPosition: targetPos,
          skillLevel: skillLevel,
        ),
      );
    }
    return true;
  }

  /// Kỹ năng 3: Ngự Kiếm Hộ Thể / Phi Kiếm (Khiên xoay buff thủ 3s sau đó phóng 6 phi kiếm)
  bool useSkill3() {
    if (skill3CooldownRemaining > 0) return false;
    final skillLevel = getSkillLevel(SkillCatalog.nguKiemPhiKiem.id);
    final skillData = SkillCatalog.nguKiemPhiKiem.getDataForLevel(skillLevel);

    if (!consumeMp(skillData.manaCost)) return false;

    skill3CooldownRemaining = skillData.cooldown;
    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();

    if (isMounted) {
      game.world.add(
        ShieldBuffEffectComponent(skillLevel: skillLevel),
      );
    }
    return true;
  }

  Vector2? _findNearestMonsterTarget() {
    if (!isMounted) return null;
    final monsters = game.world.children.whereType<MonsterComponent>().toList();
    double minDistance = 220.0;
    Vector2? closest;

    for (final monster in monsters) {
      if (monster.isDead) continue;
      final dist = (monster.position - position).length;
      if (dist < minDistance) {
        minDistance = dist;
        closest = monster.position.clone();
      }
    }
    return closest;
  }

  /// Trừ máu khi nhận sát thương
  void takeDamage(double damage) {
    _currentHp = max(0, _currentHp - damage);
  }

  /// Tiêu hao năng lượng
  bool consumeMp(double amount) {
    if (_currentMp >= amount) {
      _currentMp -= amount;
      return true;
    }
    return false;
  }

  /// Hồi máu
  void healHp(double amount) {
    _currentHp = min(_totalStats.maxHp, _currentHp + amount);
  }

  /// Hồi năng lượng
  void healMp(double amount) {
    _currentMp = min(_totalStats.maxMp, _currentMp + amount);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Cập nhật bộ đếm hồi chiêu
    if (attackCooldownRemaining > 0) {
      attackCooldownRemaining = max(0, attackCooldownRemaining - dt);
    }
    if (skill1CooldownRemaining > 0) {
      skill1CooldownRemaining = max(0, skill1CooldownRemaining - dt);
    }
    if (skill2CooldownRemaining > 0) {
      skill2CooldownRemaining = max(0, skill2CooldownRemaining - dt);
    }
    if (skill3CooldownRemaining > 0) {
      skill3CooldownRemaining = max(0, skill3CooldownRemaining - dt);
    }

    // Cập nhật thời gian hiệu lực Buff tạm thời
    if (_buffDuration > 0) {
      _buffDuration -= dt;
      if (_buffDuration <= 0) {
        _buffArmor = 0;
        _buffCritResistance = 0;
        _recalculateStats();
      }
    }

    // 1. Cập nhật chu kỳ hồi máu / hồi năng lượng mỗi giây
    _regenTimer += dt;
    if (_regenTimer >= GameConstants.regenIntervalSeconds) {
      _regenTimer -= GameConstants.regenIntervalSeconds;
      if (_totalStats.hpRegen > 0 && _currentHp < _totalStats.maxHp) {
        _currentHp = min(_totalStats.maxHp, _currentHp + _totalStats.hpRegen);
      }
      if (_totalStats.mpRegen > 0 && _currentMp < _totalStats.maxMp) {
        _currentMp = min(_totalStats.maxMp, _currentMp + _totalStats.mpRegen);
      }
    }

    // 2. Cập nhật thời gian tấn công
    if (_state == CharacterState.attack) {
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        _state = velocity.isZero() ? CharacterState.idle : CharacterState.move;
        _syncLayers();
      }
    }

    // 3. Xử lý di chuyển
    if (!velocity.isZero() && _state != CharacterState.attack) {
      _state = CharacterState.move;
      _direction = GameDirection.fromVector2(velocity);

      // Di chuyển theo vận tốc
      final moveDelta = velocity.normalized() * GameConstants.playerBaseSpeed * dt;
      position += moveDelta;

      // Giới hạn trong biên map 1254 x 1254
      final halfSize = size / 2;
      position.x = position.x.clamp(halfSize.x, GameConstants.mapWidth - halfSize.x);
      position.y = position.y.clamp(halfSize.y, GameConstants.mapHeight - halfSize.y);

      _syncLayers();
    } else if (_state != CharacterState.attack && velocity.isZero() && _state != CharacterState.idle) {
      _state = CharacterState.idle;
      _syncLayers();
    }
  }

  /// Đồng bộ hướng và trạng thái cho Thân và tất cả các lớp trang bị
  void _syncLayers() {
    // Xử lý lật ngang quanh tâm Anchor.center:
    // Khi quay sang phải dùng scale.x = -1.0;
    // Khi quay sang các hướng còn lại (trái, xuống, lên) trả lại scale.x = 1.0;
    // Tuyệt đối không thay đổi position khi lật trục X.
    if (_direction == GameDirection.right) {
      scale.x = -1.0;
    } else {
      scale.x = 1.0;
    }
    scale.y = 1.0;

    // Cập nhật Dynamic Priority cho Thân theo hướng nhìn:
    // - Khi hướng 'up' (nhìn từ sau lưng): Thân = 10, Quần/Giáp/Mũ = 20, Cánh = 35, Kiếm = 40 (đè lên Cánh)
    // - Khi hướng 'down', 'left', 'right' (nhìn phía trước / nghiêng): Cánh = 5, Kiếm = 10, Thân = 20, Trang phục = 30
    _body.priority = _direction == GameDirection.up ? 10 : 20;

    _body.updateStateAndDirection(state: _state, direction: _direction);
    for (final layer in _equipmentLayers.values) {
      layer.updateStateAndDirection(state: _state, direction: _direction);
    }
  }
}
