import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/constants/direction.dart';
import 'package:gamerpg2dpixelqt/constants/game_constants.dart';
import 'package:gamerpg2dpixelqt/game/components/body_component.dart';
import 'package:gamerpg2dpixelqt/game/components/equipment_layer_component.dart';
import 'package:gamerpg2dpixelqt/game/components/player_component.dart';
import 'package:gamerpg2dpixelqt/models/equipment.dart';

void main() {
  group('PlayerComponent & BodyComponent Anchor & Flip Tests', () {
    test('PlayerComponent, BodyComponent, EquipmentLayerComponent have Anchor.center and aligned positions', () {
      final player = PlayerComponent();
      expect(player.anchor, Anchor.center);
      expect(player.size, GameConstants.characterSize);

      final body = BodyComponent();
      expect(body.anchor, Anchor.center);
      expect(body.size, GameConstants.characterSize);
      expect(body.position, GameConstants.characterSize / 2);

      final equip = EquipmentLayerComponent(equipment: EquipmentCatalog.kiemGo);
      expect(equip.anchor, Anchor.center);
      expect(equip.size, GameConstants.characterSize);
      expect(equip.position, GameConstants.characterSize / 2);
    });

    test('Flipping scale.x on direction change does not alter player position', () {
      final player = PlayerComponent(initialPosition: Vector2(500, 500));
      final initialPos = player.position.clone();

      // Start facing down (default)
      expect(player.scale.x, 1.0);
      expect(player.scale.y, 1.0);

      // Move Right -> scale.x should be -1.0
      player.velocity = Vector2(1, 0);
      player.update(0.1);
      expect(player.direction, GameDirection.right);
      expect(player.scale.x, -1.0);
      expect(player.scale.y, 1.0);

      // Position only moves forward by speed * dt (80 * 0.1 = 8), no teleport
      final expectedXAfterRight = initialPos.x + GameConstants.playerBaseSpeed * 0.1;
      expect((player.position.x - expectedXAfterRight).abs(), lessThan(0.0001));
      expect((player.position.y - initialPos.y).abs(), lessThan(0.0001));

      // Turn immediately Left -> scale.x returns to 1.0
      final posXBeforeLeft = player.position.x;
      player.velocity = Vector2(-1, 0);
      player.update(0.1);
      expect(player.direction, GameDirection.left);
      expect(player.scale.x, 1.0);
      expect(player.scale.y, 1.0);

      // Position should be posXBeforeLeft - (80 * 0.1), no teleport glitch
      final expectedXAfterLeft = posXBeforeLeft - GameConstants.playerBaseSpeed * 0.1;
      expect((player.position.x - expectedXAfterLeft).abs(), lessThan(0.0001));

      // Turn Up -> scale.x remains 1.0
      player.velocity = Vector2(0, -1);
      player.update(0.1);
      expect(player.direction, GameDirection.up);
      expect(player.scale.x, 1.0);

      // Turn Down -> scale.x remains 1.0
      player.velocity = Vector2(0, 1);
      player.update(0.1);
      expect(player.direction, GameDirection.down);
      expect(player.scale.x, 1.0);
    });

    test('Straight vs diagonal movement has identical uniform speed (no surge)', () {
      const dt = 0.05; // 50ms
      final expectedDistance = GameConstants.playerBaseSpeed * dt;

      // 1. Straight right
      final playerStraight = PlayerComponent(initialPosition: Vector2(500, 500));
      playerStraight.velocity = Vector2(1, 0);
      playerStraight.update(dt);
      final distStraight = (playerStraight.position - Vector2(500, 500)).length;
      expect((distStraight - expectedDistance).abs(), lessThan(0.0001));

      // 2. Diagonal down-right (1, 1)
      final playerDiagonal = PlayerComponent(initialPosition: Vector2(500, 500));
      playerDiagonal.velocity = Vector2(1, 1);
      playerDiagonal.update(dt);
      final distDiagonal = (playerDiagonal.position - Vector2(500, 500)).length;
      expect((distDiagonal - expectedDistance).abs(), lessThan(0.0001));

      // Both distances must be identical
      expect((distStraight - distDiagonal).abs(), lessThan(0.0001));
    });

    test('Player position is clamped strictly inside map boundaries', () {
      final player = PlayerComponent(initialPosition: Vector2(500, 500));
      final halfSize = GameConstants.characterSize / 2;

      // Attempt to move far past the top-left boundary
      player.position = Vector2(0, 0);
      player.velocity = Vector2(-1, -1);
      player.update(1.0);

      expect(player.position.x, greaterThanOrEqualTo(halfSize.x));
      expect(player.position.y, greaterThanOrEqualTo(halfSize.y));
      expect(player.position.x, equals(halfSize.x));
      expect(player.position.y, equals(halfSize.y));

      // Attempt to move far past the bottom-right boundary
      player.position = Vector2(GameConstants.mapWidth + 100, GameConstants.mapHeight + 100);
      player.velocity = Vector2(1, 1);
      player.update(1.0);

      expect(player.position.x, lessThanOrEqualTo(GameConstants.mapWidth - halfSize.x));
      expect(player.position.y, lessThanOrEqualTo(GameConstants.mapHeight - halfSize.y));
      expect(player.position.x, equals(GameConstants.mapWidth - halfSize.x));
      expect(player.position.y, equals(GameConstants.mapHeight - halfSize.y));
    });
  });
}
