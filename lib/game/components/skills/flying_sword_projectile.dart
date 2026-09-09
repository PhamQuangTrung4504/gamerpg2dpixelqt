import 'dart:math';
import 'package:flame/components.dart';
import '../../../core/asset_paths.dart';
import '../../../core/combat_calculator.dart';
import '../../../models/skill.dart';
import '../../survival_game.dart';
import '../floating_text_component.dart';
import '../monster_component.dart';

/// Phi kiếm tự định hướng truy đuổi mục tiêu của Kỹ năng 3 - Ngự Kiếm Hộ Thể
/// - Phóng ra từ vòng xoay theo góc burst.
/// - Tự động định vị và lao vun vút vào quái vật gần nhất.
/// - Nếu quái vật mục tiêu chết trước khi kiếm trúng, kiếm tự động chuyển hướng tìm quái sống tiếp theo.
class FlyingSwordProjectileComponent extends SpriteComponent with HasGameReference<SurvivalGame> {
  final double burstAngle;
  static const double flightSpeed = 380.0;
  static const double burstSpeed = 220.0;
  static const double burstDuration = 0.15;
  static const double maxLifetime = 2.5;
  static const double swordAngleOffset = 0.41; // Căn chỉnh mũi kiếm theo góc sprite gốc

  double _timer = 0.0;
  Vector2 _velocity = Vector2.zero();
  MonsterComponent? _target;

  FlyingSwordProjectileComponent({
    required Vector2 startPosition,
    required this.burstAngle,
  }) : super(
          position: startPosition.clone(),
          size: Vector2.all(24.0),
          anchor: Anchor.center,
          priority: 26,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      sprite = await game.loadSprite(AssetPaths.fxSkill3FlyingSword);
    } catch (_) {}

    // Giai đoạn bung nan hoa nhẹ từ vị trí tách vòng bảo hộ (0.15s đầu)
    _velocity = Vector2(cos(burstAngle), sin(burstAngle)) * burstSpeed;
    angle = burstAngle + swordAngleOffset;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    if (_timer < burstDuration) {
      // Đang bung ra theo hướng góc tách vòng xoay
      position += _velocity * dt;
    } else {
      // Giai đoạn truy đuổi: Luôn đảm bảo mục tiêu còn sống, nếu quái chết lập tức chuyển hướng
      _findOrUpdateTarget();

      if (_target != null && !_target!.isDead && _target!.isMounted) {
        final toTarget = _target!.position - position;
        final dist = toTarget.length;

        // Va chạm mục tiêu
        if (dist <= 18.0) {
          _hitTarget(_target!);
          return;
        }

        // Đuổi theo mục tiêu với tốc độ cao
        final targetDir = toTarget.normalized();
        position += targetDir * flightSpeed * dt;
        angle = atan2(targetDir.y, targetDir.x) + swordAngleOffset;
      } else {
        // Nếu không còn quái vật nào trong tầm, tiếp tục bay thẳng theo hướng hiện tại
        final currentDirAngle = angle - swordAngleOffset;
        final forwardDir = Vector2(cos(currentDirAngle), sin(currentDirAngle));
        position += forwardDir * flightSpeed * dt;
      }
    }

    if (_timer >= maxLifetime) {
      removeFromParent();
    }
  }

  /// Tìm kiếm hoặc cập nhật lại mục tiêu: Nếu mục tiêu cũ đã chết/bị hủy, tự chuyển hướng tìm quái tiếp theo
  void _findOrUpdateTarget() {
    if (_target != null && !_target!.isDead && _target!.isMounted) {
      return; // Mục tiêu hiện tại vẫn còn sống và hợp lệ
    }

    final monsters = game.world.children.whereType<MonsterComponent>().toList();
    double closestDist = double.infinity;
    MonsterComponent? closest;

    for (final monster in monsters) {
      if (monster.isDead || !monster.isMounted) continue;
      final d = (monster.position - position).length;
      if (d < closestDist) {
        closestDist = d;
        closest = monster;
      }
    }

    _target = closest;
  }

  /// Xử lý trúng đích gây sát thương và hiệu ứng
  void _hitTarget(MonsterComponent monster) {
    final player = game.player;
    final skillData = SkillCatalog.nguKiemPhiKiem.getDataForLevel(1);

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

    if (isMounted) {
      if (result.lifeStealed > 0) {
        player.healHp(result.lifeStealed);
        game.world.add(FloatingTextComponent.heal(position: player.position.clone(), amount: result.lifeStealed));
      }
      if (result.manaStealed > 0) {
        player.healMp(result.manaStealed);
        game.world.add(FloatingTextComponent.mana(position: player.position.clone(), amount: result.manaStealed));
      }
    }

    removeFromParent();
  }
}

