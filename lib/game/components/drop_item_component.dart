import 'dart:math';
import 'package:flame/components.dart';
import '../../core/asset_paths.dart';
import '../../models/equipment.dart';
import '../survival_game.dart';
import 'floating_text_component.dart';

/// Chủng loại vật phẩm rơi trên mặt đất
enum DropItemType {
  gold,
  exp,
  equipment;
}

/// Component đại diện cho vật phẩm rơi (Vàng, Ngọc EXP, Trang bị)
class DropItemComponent extends PositionComponent with HasGameReference<SurvivalGame> {
  final DropItemType dropType;
  final int value;
  final Equipment? equipment;

  static const double pickupRadius = 40.0;
  static const double collectDistance = 12.0;
  static const double magnetSpeed = 160.0;

  double _bobTimer = 0.0;
  final double _baseY;

  SpriteComponent? _spriteComp;
  SpriteAnimationComponent? _haloComp;

  DropItemComponent.gold({
    required Vector2 position,
    required this.value,
  })  : dropType = DropItemType.gold,
        equipment = null,
        _baseY = position.y,
        super(
          position: position,
          size: Vector2.all(16.0),
          anchor: Anchor.center,
          priority: 5,
        );

  DropItemComponent.exp({
    required Vector2 position,
    required this.value,
  })  : dropType = DropItemType.exp,
        equipment = null,
        _baseY = position.y,
        super(
          position: position,
          size: Vector2.all(16.0),
          anchor: Anchor.center,
          priority: 5,
        );

  DropItemComponent.equipment({
    required Vector2 position,
    required Equipment this.equipment,
  })  : dropType = DropItemType.equipment,
        value = 0,
        _baseY = position.y,
        super(
          position: position,
          size: Vector2.all(16.0),
          anchor: Anchor.center,
          priority: 5,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Nếu là trang bị, tạo hào quang xoay/phát sáng phía sau
    if (dropType == DropItemType.equipment) {
      try {
        final haloImage = await game.images.load(AssetPaths.dropHalo);
        _haloComp = SpriteAnimationComponent(
          animation: SpriteAnimation.fromFrameData(
            haloImage,
            SpriteAnimationData.sequenced(
              amount: 2,
              stepTime: 0.25,
              textureSize: Vector2.all(48.0),
            ),
          ),
          position: size / 2,
          size: Vector2.all(28.0),
          anchor: Anchor.center,
          priority: 4,
        );
        await add(_haloComp!);
      } catch (_) {}
    }

    final String assetPath;
    switch (dropType) {
      case DropItemType.gold:
        assetPath = AssetPaths.itemGold;
      case DropItemType.exp:
        assetPath = AssetPaths.itemExp;
      case DropItemType.equipment:
        assetPath = equipment!.dropAssetPath;
    }

    try {
      final sprite = await game.loadSprite(assetPath);
      _spriteComp = SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
        position: size / 2,
        priority: 6,
      );
      await add(_spriteComp!);
    } catch (_) {
      // Fallback nếu thiếu file sprite trang bị riêng biệt
      final fallbackSprite = await game.loadSprite(AssetPaths.itemGold);
      _spriteComp = SpriteComponent(
        sprite: fallbackSprite,
        size: size,
        anchor: Anchor.center,
        position: size / 2,
        priority: 6,
      );
      await add(_spriteComp!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt * 4.0;

    final player = game.player;
    final diff = player.position - position;
    final distance = diff.length;

    // Hút về phía người chơi khi vào bán kính nhặt đồ
    if (distance <= pickupRadius) {
      if (distance <= collectDistance) {
        _onCollected();
        return;
      }
      final direction = diff.normalized();
      position += direction * magnetSpeed * dt;
    } else {
      // Hiệu ứng nhấp nhô nhẹ trên mặt đất
      position.y = _baseY + sin(_bobTimer) * 2.0;
    }
  }

  void _onCollected() {
    final player = game.player;
    switch (dropType) {
      case DropItemType.gold:
        player.addGold(value);
        game.world.add(
          FloatingTextComponent.info(
            position: position.clone(),
            text: '+$value Vàng',
          ),
        );
      case DropItemType.exp:
        player.expManager.addExp(value);
        game.world.add(
          FloatingTextComponent.info(
            position: position.clone(),
            text: '+$value EXP',
          ),
        );
      case DropItemType.equipment:
        if (equipment != null) {
          player.equip(equipment!);
          game.world.add(
            FloatingTextComponent.info(
              position: position.clone(),
              text: '+${equipment!.name}',
            ),
          );
        }
    }
    removeFromParent();
  }
}
