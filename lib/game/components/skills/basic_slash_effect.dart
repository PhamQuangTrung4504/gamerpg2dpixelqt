import 'dart:math';
import 'package:flame/components.dart';
import '../../../constants/direction.dart';
import '../../../core/asset_paths.dart';
import '../../../core/combat_calculator.dart';
import '../../../models/skill.dart';
import '../../survival_game.dart';
import '../floating_text_component.dart';
import '../monster_component.dart';

/// Hiệu ứng chém hình bán nguyệt của đòn đánh thường (Cận chiến)
class BasicSlashEffectComponent extends SpriteComponent with HasGameReference<SurvivalGame> {
  final GameDirection direction;
  static const double effectDuration = 0.22;
  double _elapsed = 0.0;

  BasicSlashEffectComponent({
    required Vector2 playerPosition,
    required this.direction,
  }) : super(
          size: Vector2.all(32.0),
          anchor: Anchor.center,
          priority: 20,
        ) {
    // Đặt vị trí lệch về phía trước mặt nhân vật 20px
    final dirVec = direction.toVector2();
    position = playerPosition + dirVec * 20.0;

    // Xoay góc theo hướng nhìn
    switch (direction) {
      case GameDirection.right:
        angle = 0;
      case GameDirection.down:
        angle = pi / 2;
      case GameDirection.left:
        angle = pi;
      case GameDirection.up:
        angle = -pi / 2;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(AssetPaths.fxBasicSlash);

    // Quét toàn bộ quái vật trong vùng hình quạt 120 độ cự ly 45px
    _dealDamageToNearbyMonsters();
  }

  void _dealDamageToNearbyMonsters() {
    final player = game.player;
    final dirVec = direction.toVector2();
    final skillData = SkillCatalog.danhThuong.getDataForLevel(1);

    final monsters = game.world.children.whereType<MonsterComponent>().toList();
    for (final monster in monsters) {
      if (monster.isDead) continue;

      final diff = monster.position - player.position;
      final dist = diff.length;

      // Cự ly đánh trúng trong vòng 48px
      if (dist <= 48.0) {
        // Kiểm tra góc đánh (góc giữa hướng nhìn và vector tới quái <= 75 độ)
        final dot = dirVec.dot(diff.normalized());
        if (dot >= 0.25 || dist <= 20.0) {
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

          // Hút máu nếu có
          if (result.lifeStealed > 0) {
            player.healHp(result.lifeStealed);
            game.world.add(
              FloatingTextComponent.heal(
                position: player.position.clone(),
                amount: result.lifeStealed,
              ),
            );
          }

          // Hút mana nếu có
          if (result.manaStealed > 0) {
            player.healMp(result.manaStealed);
            game.world.add(
              FloatingTextComponent.mana(
                position: player.position.clone(),
                amount: result.manaStealed,
              ),
            );
          }
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= effectDuration) {
      removeFromParent();
    }
  }
}
