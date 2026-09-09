import 'dart:math';
import 'package:flame/components.dart';
import '../../constants/direction.dart';
import '../../constants/equipment_types.dart';
import '../../constants/game_constants.dart';
import '../../constants/player_state.dart';
import '../../core/exp_manager.dart';
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

/// Component người chơi chính kết hợp Thân và Đa lớp trang bị (Multi-layer Equipment)
class PlayerComponent extends PositionComponent with HasGameReference<SurvivalGame> {
  final BodyComponent _body = BodyComponent();
  final Map<EquipmentType, EquipmentLayerComponent> _equipmentLayers = {};
  final Map<EquipmentType, Equipment> _equippedItems = {};

  GameDirection _direction = GameDirection.down;
  CharacterState _state = CharacterState.idle;

  late CharacterStats _totalStats;
  double _currentHp = 100;
  double _currentMp = 100;
  int _gold = 0;

  late final ExpManager _expManager;

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
      },
    );
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
  Map<EquipmentType, Equipment> get equippedItems => Map.unmodifiable(_equippedItems);

  void addGold(int amount) {
    _gold += amount;
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

    // Mặc định trang bị kiếm gỗ cho nhân vật ban đầu
    await equip(EquipmentCatalog.kiemGo);
    _syncLayers();
  }

  /// Trang bị một vật phẩm
  Future<void> equip(Equipment equipment) async {
    // Tháo trang bị cũ cùng loại nếu có
    if (_equipmentLayers.containsKey(equipment.type)) {
      final oldLayer = _equipmentLayers.remove(equipment.type);
      if (oldLayer != null) {
        remove(oldLayer);
      }
    }

    _equippedItems[equipment.type] = equipment;

    // Nếu trang bị có lớp hình ảnh hiển thị trên người
    if (equipment.type.hasVisualLayer) {
      final layer = EquipmentLayerComponent(equipment: equipment);
      _equipmentLayers[equipment.type] = layer;
      await add(layer);
      layer.updateStateAndDirection(state: _state, direction: _direction);
    }

    _recalculateStats();
  }

  /// Tháo trang bị theo loại
  void unequip(EquipmentType type) {
    if (_equippedItems.containsKey(type)) {
      _equippedItems.remove(type);
      final layer = _equipmentLayers.remove(type);
      if (layer != null) {
        remove(layer);
      }
      _recalculateStats();
    }
  }

  /// Tính toán lại toàn bộ chỉ số khi thay đổi trang bị hoặc kích hoạt buff
  void _recalculateStats() {
    var combined = CharacterStats.initialBase;
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

    final skillData = SkillCatalog.danhThuong.getDataForLevel(1);
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
        ),
      );
    }
    return true;
  }

  /// Kỹ năng 1: Liệt Hỏa Đoạt Mệnh (Kiếm khí lửa xuyên thấu bay thẳng 250px)
  bool useSkill1() {
    if (skill1CooldownRemaining > 0) return false;
    final skillData = SkillCatalog.lietHoaDoatMenh.getDataForLevel(1);

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
        ),
      );
    }
    return true;
  }

  /// Kỹ năng 2: Vạn Kiếm Quy Tông (Kiếm trận bán kính 90px, 3 đợt cự kiếm + làm chậm)
  bool useSkill2() {
    if (skill2CooldownRemaining > 0) return false;
    final skillData = SkillCatalog.vanKiemQuyTong.getDataForLevel(1);

    if (!consumeMp(skillData.manaCost)) return false;

    skill2CooldownRemaining = skillData.cooldown;
    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();

    if (isMounted) {
      // Tìm vị trí quái gần nhất trong vòng 200px hoặc cách trước mặt 80px
      final targetPos = _findNearestMonsterTarget() ?? (position + _direction.toVector2() * 80.0);
      game.world.add(
        SwordStormAreaComponent(centerPosition: targetPos),
      );
    }
    return true;
  }

  /// Kỹ năng 3: Ngự Kiếm Hộ Thể / Phi Kiếm (Khiên xoay buff thủ 3s sau đó phóng 6 phi kiếm)
  bool useSkill3() {
    if (skill3CooldownRemaining > 0) return false;
    final skillData = SkillCatalog.nguKiemPhiKiem.getDataForLevel(1);

    if (!consumeMp(skillData.manaCost)) return false;

    skill3CooldownRemaining = skillData.cooldown;
    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();

    if (isMounted) {
      game.world.add(ShieldBuffEffectComponent());
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

    _body.updateStateAndDirection(state: _state, direction: _direction);
    for (final layer in _equipmentLayers.values) {
      layer.updateStateAndDirection(state: _state, direction: _direction);
    }
  }
}
