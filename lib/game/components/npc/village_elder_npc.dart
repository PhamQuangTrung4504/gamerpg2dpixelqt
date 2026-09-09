import 'dart:ui';
import 'package:flame/components.dart';
import '../../../constants/game_constants.dart';
import '../../../core/asset_paths.dart';
import '../../survival_game.dart';

/// Component NPC Trưởng Làng hướng dẫn cốt truyện tân thủ
class VillageElderNpcComponent extends SpriteAnimationComponent with HasGameReference<SurvivalGame> {
  VillageElderNpcComponent({Vector2? position})
      : super(
          position: position ?? Vector2(GameConstants.mapWidth / 2 + 40, GameConstants.mapHeight / 2 - 10),
          size: Vector2(32, 32),
          anchor: Anchor.center,
          priority: 15,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Xác định đường dẫn phù hợp với tiền tố Flame (tránh lặp assets/assets/...)
    final primaryPath = game.images.prefix.isNotEmpty
        ? AssetPaths.npcElderFlame
        : AssetPaths.npcElder;

    Image image;
    try {
      image = await game.images.load(primaryPath);
    } catch (_) {
      // Dự phòng đường dẫn thay thế nếu cấu hình prefix thay đổi
      final fallbackPath = primaryPath.startsWith('assets/')
          ? primaryPath.substring(7)
          : 'assets/$primaryPath';
      image = await game.images.load(fallbackPath);
    }

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.35,
        textureSize: Vector2(32, 32),
      ),
    );
  }
}
