import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/asset_paths.dart';
import '../../../core/combat_calculator.dart';
import '../../../models/skill.dart';
import '../../survival_game.dart';
import '../floating_text_component.dart';
import '../monster_component.dart';

/// Đạn kiếm khí rực lửa của Kỹ năng 1 - Liệt Hỏa Đoạt Mệnh (Xuyên thấu, Nở to dần, Đẩy lùi, Giới hạn 250px)
class FlameSlashProjectileComponent extends SpriteComponent with HasGameReference<SurvivalGame> {
  final Vector2 direction;
  static const double flightSpeed = 320.0;
  static const double maxRange = 250.0;
  static const double initialScale = 1.35; // Tăng phạm vi ban đầu lúc vừa xuất chiêu
  static const double maxScale = 2.2;

  double _traveledDistance = 0.0;
  double get traveledDistance => _traveledDistance;
  final Set<MonsterComponent> _hitMonsters = {};

  FlameSlashProjectileComponent({
    required Vector2 startPosition,
    required Vector2 flightDirection,
  })  : direction = flightDirection.normalized(),
        super(
          position: startPosition.clone(),
          size: Vector2.all(32.0),
          anchor: Anchor.center,
          priority: 25,
        ) {
    angle = atan2(direction.y, direction.x);
    scale = Vector2.all(initialScale);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(AssetPaths.fxSkill1Flame);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final step = flightSpeed * dt;
    position += direction * step;
    _traveledDistance += step;

    // 1. Tính toán tiến trình bay (0.0 -> 1.0) trên quãng đường tối đa đúng 250px
    final progress = (_traveledDistance / maxRange).clamp(0.0, 1.0);

    // 2. Kích thước nở to dần theo cự ly: từ 1.35x -> 2.2x
    final currentScale = initialScale + progress * (maxScale - initialScale);
    scale = Vector2.all(currentScale);

    // 3. Hiệu ứng Fade-out nhẹ ở 20% cự ly cuối (200px -> 250px)
    if (progress >= 0.8) {
      final fadeProgress = (progress - 0.8) / 0.2;
      final alpha = ((1.0 - fadeProgress) * 255).round().clamp(0, 255);
      paint.color = Colors.white.withAlpha(alpha);
    }

    // 4. Kiểm tra va chạm xuyên thấu với hitbox mở rộng theo scale
    _checkPiercingCollisions(currentScale);

    // 5. Kết thúc hành trình đúng cự ly 250px, tự hủy không bay tràn map
    if (_traveledDistance >= maxRange) {
      removeFromParent();
    }
  }

  void _checkPiercingCollisions(double currentScale) {
    if (!isMounted) return;
    final player = game.player;
    final skillData = SkillCatalog.lietHoaDoatMenh.getDataForLevel(1);

    // Hitbox bán nguyệt tự động mở rộng theo scale (từ 20px nở lên đến 44px)
    final collisionRadius = 20.0 * currentScale;

    final monsters = game.world.children.whereType<MonsterComponent>().toList();
    for (final monster in monsters) {
      if (monster.isDead || _hitMonsters.contains(monster)) continue;

      final dist = (monster.position - position).length;
      if (dist <= collisionRadius) {
        _hitMonsters.add(monster);

        // Tính toán sát thương kỹ năng 1 (140% Sức mạnh + 20)
        final result = CombatCalculator.calculateDamage(
          attacker: player.stats,
          defender: monster.monsterData.stats,
          skillData: skillData,
        );

        monster.takeDamage(
          result.damageDealt,
          isCrit: result.isCrit,
          isDodged: result.isDodged,
        );

        // Đẩy lùi quái 18px theo hướng đạn bay
        monster.applyKnockback(direction, skillData.knockbackDistance > 0 ? skillData.knockbackDistance : 18.0);

        // Hồi phục nếu có hút máu / mana
        if (result.lifeStealed > 0) {
          player.healHp(result.lifeStealed);
          game.world.add(FloatingTextComponent.heal(position: player.position.clone(), amount: result.lifeStealed));
        }
        if (result.manaStealed > 0) {
          player.healMp(result.manaStealed);
          game.world.add(FloatingTextComponent.mana(position: player.position.clone(), amount: result.manaStealed));
        }
      }
    }
  }
}
