import 'package:flame/components.dart';
import '../../constants/direction.dart';
import '../../constants/game_constants.dart';
import '../../constants/player_state.dart';
import '../../core/asset_paths.dart';
import '../../models/equipment.dart';
import '../survival_game.dart';

/// Component render lớp trang bị trực tiếp lên thân nhân vật
class EquipmentLayerComponent extends SpriteAnimationComponent with HasGameReference<SurvivalGame> {
  final Equipment equipment;
  CharacterState _state = CharacterState.idle;
  GameDirection _direction = GameDirection.down;

  final Map<String, SpriteAnimation> _animationCache = {};

  EquipmentLayerComponent({required this.equipment})
      : super(
          size: GameConstants.characterSize,
          anchor: Anchor.center,
          priority: equipment.type.renderPriority,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!equipment.type.hasVisualLayer) return;

    await _loadAnimations();
    _updateAnimation();
  }

  Future<void> _loadAnimations() async {
    final id = equipment.itemIdentifier;
    for (final state in CharacterState.values) {
      for (final dir in [GameDirection.down, GameDirection.left, GameDirection.up]) {
        try {
          final path = AssetPaths.equipmentLayer(
            itemIdentifier: id,
            state: state,
            direction: dir,
          );
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
        } catch (_) {
          // Bỏ qua nếu có file không tồn tại
        }
      }
    }
  }

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
    final dirKey = _direction == GameDirection.right ? GameDirection.left : _direction;
    final key = '${_state.name}_${dirKey.assetSuffix}';
    if (_animationCache.containsKey(key)) {
      animation = _animationCache[key];
    }
  }
}
