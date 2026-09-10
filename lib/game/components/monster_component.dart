import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../constants/game_constants.dart';
import '../../constants/player_state.dart';
import '../../core/asset_paths.dart';
import '../../core/combat_calculator.dart';
import '../../models/equipment.dart';
import '../../models/monster.dart';
import '../survival_game.dart';
import 'drop_item_component.dart';
import 'floating_text_component.dart';

/// Component quái vật hoàn chỉnh với AI truy đuổi, cận chiến, mini HP bar và hệ thống rơi đồ
class MonsterComponent extends SpriteAnimationGroupComponent<CharacterState>
    with HasGameReference<SurvivalGame>, CollisionCallbacks {
  final MonsterData monsterData;
  late double currentHp;

  static const double meleeRange = 28.0;
  static const double attackCooldown = 1.0;

  double _attackTimer = 0.0;
  double _slowTimer = 0.0;
  double _slowMultiplier = 1.0;
  double _stunTimer = 0.0;
  bool _isDead = false;

  final Paint _hpBgPaint = Paint()..color = const Color(0xFF2B2B2B);
  final Paint _hpFillPaint = Paint()..color = const Color(0xFFE53935);
  final Paint _hpBorderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  MonsterComponent({
    required this.monsterData,
    required Vector2 initialPosition,
  })  : currentHp = monsterData.stats.maxHp,
        super(
          position: initialPosition,
          size: Vector2.all(monsterData.type.frameSize),
          anchor: Anchor.center,
          priority: 8,
        );

  bool get isDead => _isDead;
  bool isAiActive = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Hitbox va chạm
    final hitboxRadius = monsterData.type.frameSize * 0.42;
    await add(
      CircleHitbox(
        radius: hitboxRadius,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

    // Tải 3 trạng thái hoạt ảnh (idle, move, attack) từ ảnh gốc _phia_trai.png
    final animationsMap = <CharacterState, SpriteAnimation>{};
    for (final state in [CharacterState.idle, CharacterState.move, CharacterState.attack]) {
      final path = AssetPaths.monster(
        monsterAssetName: monsterData.type.assetName,
        state: state,
      );
      final image = await game.images.load(path);
      final frameSize = monsterData.type.frameSize;

      final double stepTime;
      switch (state) {
        case CharacterState.idle:
          stepTime = 0.35;
        case CharacterState.move:
          stepTime = 0.20;
        case CharacterState.attack:
          stepTime = 0.18;
      }

      animationsMap[state] = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: stepTime,
          textureSize: Vector2.all(frameSize),
        ),
      );
    }

    animations = animationsMap;
    current = CharacterState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDead) return;

    // Trong lúc Camera đang lia giới thiệu quái trong kịch bản mở đầu, giữ quái ở trạng thái đứng yên
    if (game.tutorialManager.isPanning) {
      if (animations != null) {
        current = CharacterState.idle;
      }
      return;
    }

    if (animations == null) return;

    // Cập nhật trạng thái hiệu ứng khống chế (Slow & Stun)
    if (_stunTimer > 0) {
      _stunTimer -= dt;
      current = CharacterState.idle;
      return;
    }

    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) {
        _slowMultiplier = 1.0;
      }
    }

    final player = game.player;
    final diff = player.position - position;
    final distance = diff.length;

    // Lật ngang mặt theo vị trí người chơi quanh Anchor.center
    if (diff.x > 0) {
      scale.x = -1.0; // Quay sang phải
    } else {
      scale.x = 1.0; // Quay sang trái
    }
    scale.y = 1.0;

    // Nếu AI chưa kích hoạt (trong lúc Trưởng Làng nói chuyện hoặc Lia Camera), quái đứng yên tại chỗ
    if (!isAiActive) {
      current = CharacterState.idle;
      return;
    }

    // AI Chiến đấu & Di chuyển
    if (distance <= meleeRange) {
      // Trong tầm cận chiến -> Tấn công
      current = CharacterState.attack;
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        _attackTimer = attackCooldown;
        _performMeleeAttack();
      }
    } else {
      // Ngoài tầm cận chiến -> Di chuyển áp sát
      current = CharacterState.move;
      final direction = diff.normalized();
      final speed = monsterData.moveSpeed * _slowMultiplier;
      position += direction * speed * dt;

      // Giới hạn quái không vượt ra ngoài biên map
      final half = size.x / 2;
      position.x = position.x.clamp(half, GameConstants.mapWidth - half);
      position.y = position.y.clamp(half, GameConstants.mapHeight - half);
    }
  }

  /// Quái vật ra đòn tấn công người chơi
  void _performMeleeAttack() {
    final player = game.player;
    final result = CombatCalculator.calculateDamage(
      attacker: monsterData.stats,
      defender: player.stats,
    );

    if (result.isDodged) {
      game.world.add(
        FloatingTextComponent.miss(position: player.position.clone()),
      );
    } else {
      player.takeDamage(result.damageDealt);
      game.world.add(
        FloatingTextComponent.damage(
          position: player.position.clone(),
          amount: result.damageDealt,
          isCrit: result.isCrit,
        ),
      );

      // Phản sát thương từ người chơi lên quái nếu có
      if (result.reflectedDamage > 0) {
        takeDamage(result.reflectedDamage);
      }
    }
  }

  /// Nhận sát thương từ người chơi hoặc kỹ năng
  void takeDamage(double damage, {bool isCrit = false, bool isDodged = false}) {
    if (_isDead) return;

    if (isDodged) {
      if (isMounted) {
        game.world.add(
          FloatingTextComponent.miss(position: position.clone()),
        );
      }
      return;
    }

    currentHp = max(0, currentHp - damage);
    if (isMounted) {
      game.world.add(
        FloatingTextComponent.damage(
          position: position.clone() + Vector2(0, -size.y * 0.3),
          amount: damage,
          isCrit: isCrit,
        ),
      );
    }

    if (currentHp <= 0) {
      _die();
    }
  }

  /// Áp dụng hiệu ứng đẩy lùi (Knockback)
  void applyKnockback(Vector2 direction, double distance) {
    if (_isDead) return;
    position += direction.normalized() * distance;
    final half = size.x / 2;
    position.x = position.x.clamp(half, GameConstants.mapWidth - half);
    position.y = position.y.clamp(half, GameConstants.mapHeight - half);
  }

  /// Áp dụng hiệu ứng làm chậm
  void applySlow(double percent, double duration) {
    _slowMultiplier = max(0.2, 1.0 - percent);
    _slowTimer = duration;
  }

  /// Áp dụng hiệu ứng choáng
  void applyStun(double duration) {
    _stunTimer = duration;
  }

  /// Quái vật bị tiêu diệt
  void _die() {
    if (_isDead) return;
    _isDead = true;

    final rng = Random();
    final pos = position.clone();

    if (isMounted) {
      // 1. Rơi vàng ngẫu nhiên theo chỉ số quái
      final goldAmount = monsterData.minGoldDrop +
          rng.nextInt(max(1, monsterData.maxGoldDrop - monsterData.minGoldDrop + 1));
      game.world.add(
        DropItemComponent.gold(
          position: pos + Vector2(rng.nextDouble() * 12 - 6, rng.nextDouble() * 12 - 6),
          value: goldAmount,
        ),
      );

      // 2. Rơi ngọc kinh nghiệm
      game.world.add(
        DropItemComponent.exp(
          position: pos + Vector2(rng.nextDouble() * 12 - 6, rng.nextDouble() * 12 - 6),
          value: monsterData.expReward,
        ),
      );

      // 3. Kiểm tra tỉ lệ rơi trang bị từ danh mục trang bị phù hợp với cấp quái
      _checkEquipmentDrop(pos, rng);

      removeFromParent();
    }
  }

  /// Kiểm tra tỉ lệ rơi trang bị chuẩn xác theo tài liệu
  void _checkEquipmentDrop(Vector2 dropPos, Random rng) {
    if (!isMounted) return;

    final playerLevel = game.player.expManager.currentLevel;
    final effectiveLevel = max(monsterData.level, playerLevel);

    // Lọc trang bị có cấp độ yêu cầu phù hợp với cấp của quái vật hoặc người chơi (trong khoảng +-5 cấp)
    final eligibleItems = EquipmentCatalog.all.where((e) {
      final levelDiff = (e.requiredLevel - effectiveLevel).abs();
      return levelDiff <= 5;
    }).toList();

    if (eligibleItems.isEmpty) return;

    // Trộn ngẫu nhiên để không bị cố định rơi một món lặp lại
    eligibleItems.shuffle(rng);

    // Tỉ lệ tổng thể rơi trang bị khi tiêu diệt quái: ~40%
    if (rng.nextDouble() > 0.40) return;

    for (final item in eligibleItems) {
      final roll = rng.nextDouble() * 100.0;
      final rate = max(20.0, item.dropRatePercent);
      if (roll <= rate) {
        game.world.add(
          DropItemComponent.equipment(
            position: dropPos + Vector2(rng.nextDouble() * 20 - 10, rng.nextDouble() * 20 - 10),
            equipment: item,
          ),
        );
        // Mỗi quái tối đa rơi 1 món trang bị cùng lúc
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Vẽ thanh máu mini căn giữa phía trên đầu quái (Mini HP Bar)
    final maxHp = monsterData.stats.maxHp;
    if (maxHp <= 0 || _isDead) return;

    final barWidth = size.x * 0.85;
    const barHeight = 3.5;
    final barX = (size.x - barWidth) / 2;
    final barY = -6.0;

    final hpRatio = (currentHp / maxHp).clamp(0.0, 1.0);

    // Khung nền xám
    final bgRect = Rect.fromLTWH(barX, barY, barWidth, barHeight);
    canvas.drawRect(bgRect, _hpBgPaint);

    // Vạch máu đỏ
    if (hpRatio > 0) {
      final fillRect = Rect.fromLTWH(barX, barY, barWidth * hpRatio, barHeight);
      canvas.drawRect(fillRect, _hpFillPaint);
    }

    // Viền đen mảnh phong cách pixel
    canvas.drawRect(bgRect, _hpBorderPaint);
  }
}
