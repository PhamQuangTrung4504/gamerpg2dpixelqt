import 'package:flame/components.dart';
import '../../core/asset_paths.dart';
import '../survival_game.dart';

/// Joystick điều khiển ảo căn chỉnh chuẩn xác theo assets và responsive theo màn hình
class GameJoystick extends JoystickComponent {
  static const double bgSize = 83.0;
  static const double bgRadius = 41.4; // Tăng 15% (36px -> 41.4px)
  static const double knobSize = 32.0; // Tăng 15% (28px -> 32px)
  static const double defaultMargin = 40.0;

  GameJoystick({
    required Sprite knobSprite,
    required Sprite bgSprite,
  }) : super(
          knob: SpriteComponent(
            sprite: knobSprite,
            size: Vector2.all(knobSize),
            anchor: Anchor.center,
          ),
          background: SpriteComponent(
            sprite: bgSprite,
            size: Vector2.all(bgSize),
            anchor: Anchor.topLeft,
          ),
          knobRadius: bgRadius, // Bán kính di chuyển 41.4px
          anchor: Anchor.center,
          priority: 100,
        );

  static Future<GameJoystick> create(SurvivalGame game) async {
    final knobSprite = await game.loadSprite(AssetPaths.joystickKnob);
    final bgSprite = await game.loadSprite(AssetPaths.joystickBackground);
    return GameJoystick(knobSprite: knobSprite, bgSprite: bgSprite);
  }

  @override
  void onMount() {
    super.onMount();
    reposition();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    reposition();
  }

  /// Căn chỉnh núm nằm giữa tâm vòng và neo cố định cách mép dưới 40px, mép trái 40px
  void reposition() {
    final s = game.size;
    if (s.x <= 0 || s.y <= 0) return;
    position = Vector2(defaultMargin + bgRadius, s.y - defaultMargin - bgRadius);
  }
}
