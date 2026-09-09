import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/asset_paths.dart';
import '../../../core/combat_calculator.dart';
import '../../../models/skill.dart';
import '../../survival_game.dart';
import '../monster_component.dart';

/// Kiếm trận diện rộng của Kỹ năng 2 - Vạn Kiếm Quy Tông (Bán kính 90px, 3 đợt sát thương + Làm chậm)
class SwordStormAreaComponent extends PositionComponent with HasGameReference<SurvivalGame> {
  static const double effectRadius = 90.0;
  static const int totalWaves = 3;
  static const double waveInterval = 0.30;
  static const double totalDuration = 1.25;

  int _wavesCompleted = 0;
  double _waveTimer = 0.0;
  double _totalTimer = 0.0;

  final Paint _groundCirclePaint = Paint()
    ..color = const Color(0x3342A5F5)
    ..style = PaintingStyle.fill;
  final Paint _groundBorderPaint = Paint()
    ..color = const Color(0x8890CAF9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  final Paint _innerRingPaint = Paint()
    ..color = const Color(0x5564B5F6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final int skillLevel;

  SwordStormAreaComponent({
    required Vector2 centerPosition,
    this.skillLevel = 1,
  })  : super(
          position: centerPosition.clone(),
          size: Vector2.all(effectRadius * 2),
          anchor: Anchor.center,
          priority: 7, // Vẽ trên mặt đất nhưng dưới quái và người
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Kích hoạt ngay đợt cự kiếm đầu tiên giáng xuống tâm kiếm trận
    _triggerSwordWave();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _totalTimer += dt;
    _waveTimer += dt;

    if (_wavesCompleted < totalWaves && _waveTimer >= waveInterval) {
      _waveTimer = 0.0;
      _triggerSwordWave();
    }

    if (_totalTimer >= totalDuration) {
      removeFromParent();
    }
  }

  /// Kích hoạt một đợt cự kiếm giáng thẳng xuống giữa tâm kiếm trận và gây sát thương + làm chậm
  Future<void> _triggerSwordWave() async {
    _wavesCompleted++;

    // 1. Tạo hoạt ảnh cự kiếm ánh sáng rơi từ trên cao cắm xuống đúng tâm kiếm trận
    // File ảnh gốc 192x32 gồm 6 frames, mỗi frame 32x32. Scale 3.0x thành 96x96px.
    try {
      final swordImage = await game.images.load(AssetPaths.fxSkill2SwordArray);
      final swordAnimComp = SpriteAnimationComponent(
        animation: SpriteAnimation.fromFrameData(
          swordImage,
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: 0.07,
            textureSize: Vector2.all(32.0),
            loop: false,
          ),
        ),
        position: position.clone(), // Đúng chính giữa tâm kiếm trận
        size: Vector2(96.0, 96.0), // Scale 3.0x cân xứng với bán kính 90px
        anchor: Anchor.center,
        removeOnFinish: true,
        priority: 25,
      );

      if (isMounted) {
        game.world.add(swordAnimComp);
      }
    } catch (_) {}

    // 2. Gây sát thương + làm chậm 30% lên tất cả quái vật trong bán kính 90px
    final player = game.player;
    final skillData = SkillCatalog.vanKiemQuyTong.getDataForLevel(skillLevel);

    final monsters = game.world.children.whereType<MonsterComponent>().toList();
    for (final monster in monsters) {
      if (monster.isDead) continue;

      final dist = (monster.position - position).length;
      if (dist <= effectRadius) {
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

        // Áp dụng làm chậm 30% trong 2.0 giây theo đúng thiết kế
        monster.applySlow(0.30, 2.0);

        if (result.lifeStealed > 0) {
          player.healHp(result.lifeStealed);
        }
        if (result.manaStealed > 0) {
          player.healMp(result.manaStealed);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Vẽ vòng tròn trận pháp ma thuật trên nền đất (tâm trận và vòng đồng tâm)
    final center = (size / 2).toOffset();
    canvas.drawCircle(center, effectRadius, _groundCirclePaint);
    canvas.drawCircle(center, effectRadius, _groundBorderPaint);
    canvas.drawCircle(center, effectRadius * 0.45, _innerRingPaint);
  }
}

