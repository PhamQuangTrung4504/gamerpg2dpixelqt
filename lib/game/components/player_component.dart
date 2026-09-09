import 'dart:math';
import 'package:flame/components.dart';
import '../../constants/direction.dart';
import '../../constants/equipment_types.dart';
import '../../constants/game_constants.dart';
import '../../constants/player_state.dart';
import '../../core/exp_manager.dart';
import '../../models/character_stats.dart';
import '../../models/equipment.dart';
import '../survival_game.dart';
import 'body_component.dart';
import 'equipment_layer_component.dart';

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

  late final ExpManager _expManager;

  // Vector di chuyển từ input (Joystick hoặc Bàn phím)
  Vector2 velocity = Vector2.zero();

  // Bộ đếm hồi phục HP/MP theo chu kỳ 1s
  double _regenTimer = 0.0;

  // Thời gian duy trì đòn tấn công
  double _attackTimer = 0.0;
  static const double _attackDuration = 0.30;

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
  ExpManager get expManager => _expManager;
  Map<EquipmentType, Equipment> get equippedItems => Map.unmodifiable(_equippedItems);

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

  /// Tính toán lại toàn bộ chỉ số khi thay đổi trang bị
  void _recalculateStats() {
    var combined = CharacterStats.initialBase;
    for (final item in _equippedItems.values) {
      combined = combined + item.stats;
    }
    _totalStats = combined.applyCoolnessMultiplier();

    // Đảm bảo HP và MP không vượt quá Max HP/MP mới
    _currentHp = _currentHp.clamp(0, _totalStats.maxHp);
    _currentMp = _currentMp.clamp(0, _totalStats.maxMp);
  }

  /// Kích hoạt đòn tấn công
  void performAttack() {
    if (_state == CharacterState.attack) return;
    _state = CharacterState.attack;
    _attackTimer = _attackDuration;
    _syncLayers();
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
