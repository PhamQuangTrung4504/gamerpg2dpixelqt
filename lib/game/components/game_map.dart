import 'package:flame/components.dart';
import '../../constants/game_constants.dart';
import '../../core/asset_paths.dart';
import '../survival_game.dart';

/// Component hiển thị bản đồ pixel 1254 x 1254
class GameMapComponent extends SpriteComponent with HasGameReference<SurvivalGame> {
  GameMapComponent()
      : super(
          size: GameConstants.mapSize,
          position: Vector2.zero(),
          priority: 0, // Nằm ở lớp dưới cùng (background)
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(AssetPaths.map1);
  }
}
