import 'package:flame/components.dart';
import '../../constants/direction.dart';
import '../../constants/game_constants.dart';
import '../../constants/player_state.dart';
import '../../core/asset_paths.dart';
import '../survival_game.dart';

/// Component render hình ảnh cơ thể nhân vật chính
class BodyComponent extends SpriteAnimationComponent with HasGameReference<SurvivalGame> {
  CharacterState _state = CharacterState.idle;
  GameDirection _direction = GameDirection.down;

  // Cache các animation để chuyển đổi tức thì không giật lag
  final Map<String, SpriteAnimation> _animationCache = {};

  BodyComponent()
      : super(
          size: GameConstants.characterSize,
          anchor: Anchor.center,
          priority: 10,
        );

  CharacterState get state => _state;
  GameDirection get direction => _direction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAllAnimations();
    _updateAnimation();
  }

  /// Nạp trước toàn bộ animation cơ thể cho mọi trạng thái và hướng
  Future<void> _loadAllAnimations() async {
    for (final state in CharacterState.values) {
      for (final dir in [GameDirection.down, GameDirection.left, GameDirection.up]) {
        final path = AssetPaths.characterBody(state: state, direction: dir);
        final key = '${state.name}_${dir.assetSuffix}';
        final image = await game.images.load(path);

        final double stepTime;
        switch (state) {
          case CharacterState.idle:
            stepTime = GameConstants.idleStepTime;
          case CharacterState.move:
            stepTime = GameConstants.moveStepTime;
          case CharacterState.attack:
            stepTime = GameConstants.attackStepTime;
        }

        _animationCache[key] = SpriteAnimation.fromFrameData(
          image,
          SpriteAnimationData.sequenced(
            amount: GameConstants.characterFrameCount,
            stepTime: stepTime,
            textureSize: GameConstants.characterSize,
          ),
        );
      }
    }
  }

  /// Cập nhật trạng thái và hướng nhìn
  void updateStateAndDirection({
    required CharacterState state,
    required GameDirection direction,
  }) {
    if (_state == state && _direction == direction) return;
    _state = state;
    _direction = direction;
    _updateAnimation();
  }

  void _updateAnimation() {
    // Với hướng right, lấy animation của left
    final dirKey = _direction == GameDirection.right ? GameDirection.left : _direction;
    final key = '${_state.name}_${dirKey.assetSuffix}';
    if (_animationCache.containsKey(key)) {
      animation = _animationCache[key];
    }
  }
}
