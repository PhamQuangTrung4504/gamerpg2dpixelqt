import 'dart:math';
import 'package:flame/components.dart';
import '../../../core/asset_paths.dart';
import '../../../core/combat_calculator.dart';
import '../../../models/skill.dart';
import '../../survival_game.dart';
import '../floating_text_component.dart';
import '../monster_component.dart';
import 'flying_sword_projectile.dart';

/// Hiệu ứng khiên hộ thể của Kỹ năng 3 - Ngự Kiếm Hộ Thể
/// - Giai đoạn 1 (3s đầu): Vòng khiên bảo vệ + 6 thanh phi kiếm xoay tròn cách tâm 38px, gây sát thương va chạm nhẹ khi quái chạm vào.
/// - Giai đoạn 2 (Sau 3s): 6 thanh phi kiếm đồng loạt tách ra, phóng vào các mục tiêu quái gần nhất (tự đổi mục tiêu nếu quái chết).
class ShieldBuffEffectComponent extends PositionComponent with HasGameReference<SurvivalGame> {
  static const double shieldDuration = 3.0;
  static const double orbitRadius = 38.0;
  static const int swordCount = 6;
  static const double orbitSpeed = 4.0; // Tốc độ xoay (rad/s)
  static const double swordAngleOffset = 0.41; // Căn chỉnh mũi kiếm theo góc sprite gốc

  static const double buffArmor = 15.0;
  static const double buffCritResistance = 5.0;
  static const double grazeRadius = 48.0; // Bán kính nhận sát thương va chạm kiếm xoay
  static const double grazeInterval = 0.30; // Nhịp gây sát thương va chạm

  double _timer = 0.0;
  double _orbitAngle = 0.0;
  double _grazeTimer = 0.0;
  final int skillLevel;

  final List<SpriteComponent> _orbitingSwords = [];

  ShieldBuffEffectComponent({this.skillLevel = 1})
      : super(
          size: Vector2.zero(),
          anchor: Anchor.center,
          priority: 22,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Hoạt ảnh vòng khiên phát sáng bao bọc nhân vật
    try {
      final shieldImage = await game.images.load(AssetPaths.fxShield);
      final shieldAnimComp = SpriteAnimationComponent(
        animation: SpriteAnimation.fromFrameData(
          shieldImage,
          SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.15,
            textureSize: Vector2.all(32.0),
          ),
        ),
        size: Vector2(56.0, 56.0),
        anchor: Anchor.center,
        priority: 20,
      );
      add(shieldAnimComp);
    } catch (_) {}

    // 2. Tạo 6 thanh phi kiếm nhỏ xếp đều theo góc 60 độ (2*pi/6) xoay quanh người
    try {
      final swordSprite = await game.loadSprite(AssetPaths.fxSkill3FlyingSword);
      for (int i = 0; i < swordCount; i++) {
        final swordComp = SpriteComponent(
          sprite: swordSprite,
          size: Vector2.all(24.0),
          anchor: Anchor.center,
          priority: 24,
        );
        add(swordComp);
        _orbitingSwords.add(swordComp);
      }
      _updateSwordPositions();
    } catch (_) {}

    // 3. Bật hiệu ứng buff chỉ số cho nhân vật
    final skillData = SkillCatalog.nguKiemPhiKiem.getDataForLevel(skillLevel);
    game.player.applyTemporaryBuff(
      extraArmor: skillData.buffArmor,
      extraCritResistance: skillData.buffCritResistance,
      duration: skillData.buffDuration > 0 ? skillData.buffDuration : shieldDuration,
    );

    // 4. Hiện chữ thông báo hiệu ứng
    if (isMounted) {
      game.world.add(
        FloatingTextComponent.info(
          position: game.player.position.clone() + Vector2(0, -24),
          text: 'Hộ Thể: +${skillData.buffArmor.toInt()} Giáp!',
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Bám sát theo vị trí người chơi
    position = game.player.position.clone();

    // Xoay 6 phi kiếm quanh tâm
    _orbitAngle += orbitSpeed * dt;
    _updateSwordPositions();

    // Quái chạm vào vòng kiếm xoay quanh người trong 3 giây này bị nhận sát thương va chạm nhẹ
    _grazeTimer += dt;
    if (_grazeTimer >= grazeInterval) {
      _grazeTimer = 0.0;
      _dealGrazingDamage();
    }

    // Đúng sau 3 giây: 6 phi kiếm đồng loạt tách ra và lao vào mục tiêu
    if (_timer >= shieldDuration) {
      _launchFlyingSwords();
      removeFromParent();
    }
  }

  /// Cập nhật tọa độ và góc xoay của 6 thanh phi kiếm theo quỹ đạo hình tròn bán kính 38px
  void _updateSwordPositions() {
    for (int i = 0; i < _orbitingSwords.length; i++) {
      final a = _orbitAngle + (i * 2 * pi / swordCount);
      _orbitingSwords[i].position = Vector2(cos(a) * orbitRadius, sin(a) * orbitRadius);
      // Hướng mũi kiếm theo tiếp tuyến quỹ đạo xoay tròn
      _orbitingSwords[i].angle = a + (pi / 2) + swordAngleOffset;
    }
  }

  /// Gây sát thương va chạm nhẹ lên quái vật chạm vào vòng kiếm xoay quanh người
  void _dealGrazingDamage() {
    final player = game.player;
    final monsters = game.world.children.whereType<MonsterComponent>().toList();

    for (final monster in monsters) {
      if (monster.isDead) continue;

      final dist = (monster.position - position).length;
      if (dist <= grazeRadius) {
        // Sát thương va chạm nhẹ: 25% Sức mạnh tấn công của người chơi
        final result = CombatCalculator.calculateDamage(
          attacker: player.stats,
          defender: monster.monsterData.stats,
          skillData: const SkillLevelData(
            level: 1,
            powerMultiplier: 0.25,
            manaCost: 0,
            cooldown: 0,
          ),
        );

        monster.takeDamage(
          result.damageDealt,
          isCrit: result.isCrit,
          isDodged: result.isDodged,
        );

        if (result.lifeStealed > 0) {
          player.healHp(result.lifeStealed);
        }
      }
    }
  }

  /// Sau 3 giây, 6 thanh phi kiếm đồng loạt tách ra từ vị trí xoay và lao vun vút vào quái vật
  void _launchFlyingSwords() {
    if (!isMounted) return;

    for (int i = 0; i < swordCount; i++) {
      final a = _orbitAngle + (i * 2 * pi / swordCount);
      // Tách ra từ đúng tọa độ của từng thanh kiếm trên vòng xoay
      final swordStartPos = position + Vector2(cos(a) * orbitRadius, sin(a) * orbitRadius);

      final flyingSword = FlyingSwordProjectileComponent(
        startPosition: swordStartPos,
        burstAngle: a,
        skillLevel: skillLevel,
      );
      game.world.add(flyingSword);
    }
  }
}
