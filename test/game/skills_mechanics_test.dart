import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/constants/direction.dart';
import 'package:gamerpg2dpixelqt/constants/equipment_types.dart';
import 'package:gamerpg2dpixelqt/core/combat_calculator.dart';
import 'package:gamerpg2dpixelqt/core/game_typography.dart';
import 'package:gamerpg2dpixelqt/game/components/game_hud.dart';
import 'package:gamerpg2dpixelqt/game/components/joystick.dart';
import 'package:gamerpg2dpixelqt/game/components/skills/flame_slash_projectile.dart';
import 'package:gamerpg2dpixelqt/game/components/skills/flying_sword_projectile.dart';
import 'package:gamerpg2dpixelqt/game/components/skills/shield_effect.dart';
import 'package:gamerpg2dpixelqt/game/components/skills/sword_storm_area.dart';
import 'package:gamerpg2dpixelqt/constants/player_state.dart';
import 'package:gamerpg2dpixelqt/game/components/equipment_layer_component.dart';
import 'package:gamerpg2dpixelqt/models/character_stats.dart';
import 'package:gamerpg2dpixelqt/models/equipment.dart';
import 'package:gamerpg2dpixelqt/models/monster.dart';
import 'package:gamerpg2dpixelqt/models/skill.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('3 Active Skills Optimization & Mechanics Tests', () {
    test('Skill 1 - FlameSlashProjectile: Starts at 1.35x, scales to 2.2x and strictly caps at 250px with fade-out', () {
      final startPos = Vector2(100.0, 100.0);
      final projectile = FlameSlashProjectileComponent(
        startPosition: startPos,
        flightDirection: Vector2(1.0, 0.0),
      );

      expect(FlameSlashProjectileComponent.maxRange, equals(250.0));
      expect(FlameSlashProjectileComponent.initialScale, equals(1.35));
      expect(projectile.scale.x, closeTo(1.35, 0.01));
      expect(projectile.anchor, equals(Anchor.center));

      // Simulate flight 100px (progress = 100 / 250 = 0.4)
      projectile.update(100.0 / FlameSlashProjectileComponent.flightSpeed);
      // scale = 1.35 + 0.4 * (2.2 - 1.35) = 1.69
      expect(projectile.scale.x, closeTo(1.69, 0.05));

      // Simulate flight to 225px (progress = 225 / 250 = 0.9 -> in fade-out zone >= 0.8)
      projectile.update(125.0 / FlameSlashProjectileComponent.flightSpeed);
      // scale = 1.35 + 0.9 * (2.2 - 1.35) = 2.115
      expect(projectile.scale.x, closeTo(2.115, 0.05));
      // In fade-out zone: paint alpha is reduced below 255
      expect(projectile.paint.color.a, lessThan(1.0));

      // Simulate reaching and exceeding 250px -> exceeds maxRange
      projectile.update(50.0 / FlameSlashProjectileComponent.flightSpeed);
      expect(projectile.traveledDistance, greaterThanOrEqualTo(FlameSlashProjectileComponent.maxRange));
    });

    test('Skill 2 - SwordStormArea: 90px radius, 3 waves, 1.25s duration', () {
      final center = Vector2(200.0, 200.0);
      final stormArea = SwordStormAreaComponent(centerPosition: center);

      expect(SwordStormAreaComponent.effectRadius, equals(90.0));
      expect(SwordStormAreaComponent.totalWaves, equals(3));
      expect(SwordStormAreaComponent.waveInterval, equals(0.30));
      expect(stormArea.position, equals(center));
      expect(stormArea.anchor, equals(Anchor.center));
      expect(stormArea.size, equals(Vector2(180.0, 180.0)));
    });

    test('Skill 3 - ShieldBuffEffect: 6 orbiting swords, 38px radius, 3.0s duration', () {
      final shield = ShieldBuffEffectComponent();

      expect(ShieldBuffEffectComponent.shieldDuration, equals(3.0));
      expect(ShieldBuffEffectComponent.swordCount, equals(6));
      expect(ShieldBuffEffectComponent.orbitRadius, equals(38.0));
      expect(ShieldBuffEffectComponent.grazeRadius, equals(48.0));
      expect(ShieldBuffEffectComponent.buffArmor, equals(15.0));
      expect(ShieldBuffEffectComponent.buffCritResistance, equals(5.0));
      expect(shield.anchor, equals(Anchor.center));
    });

    test('Skill 3 - FlyingSwordProjectile: Starts at radial burst angle, homes in on targets', () {
      final startPos = Vector2(150.0, 150.0);
      final sword = FlyingSwordProjectileComponent(
        startPosition: startPos,
        burstAngle: 0.0,
      );

      expect(FlyingSwordProjectileComponent.flightSpeed, equals(380.0));
      expect(FlyingSwordProjectileComponent.maxLifetime, equals(2.5));
      expect(sword.position, equals(startPos));
      expect(sword.anchor, equals(Anchor.center));
    });

    test('Skill 3 - Grazing damage formula applies light 25% attack damage', () {
      const attackerStats = CharacterStats.initialBase; // attackPower = 10
      final monsterStats = MonsterCatalog.getByLevel(1)!.stats;

      final result = CombatCalculator.calculateDamage(
        attacker: attackerStats,
        defender: monsterStats,
        skillData: const SkillLevelData(
          level: 1,
          powerMultiplier: 0.25,
          manaCost: 0,
          cooldown: 0,
        ),
        forceDodge: false,
        forceCrit: false,
      );

      // Light grazing damage: 25% of power should produce a positive, mild damage
      expect(result.damageDealt, greaterThanOrEqualTo(1.0));
      expect(result.damageDealt, lessThan(attackerStats.attackPower));
    });
  });

  group('HUD Positioning, Pixel Typography & Equipment Layering Tests', () {
    test('HUD coordinates shifted right by 5px and slots updated accordingly', () {
      expect(GameHud.hudOriginX, equals(21.0));
      expect(GameHud.expOriginX, equals(21.0));
      expect(GameHud.hpSlotX, equals(54.0));
      expect(GameHud.mpSlotX, equals(54.0));
      expect(GameHud.expSlotX, equals(65.0));
    });

    test('Dynamic Equipment render priorities match direction specifications', () {
      // 1. Khi hướng down, left, right (nhìn phía trước / góc nghiêng):
      for (final dir in [GameDirection.down, GameDirection.left, GameDirection.right]) {
        // Cánh nằm sau cùng: priority = 5
        expect(EquipmentType.wings.getRenderPriority(dir), equals(5));
        // Kiếm đè lên cánh, dưới thân: priority = 10
        expect(EquipmentType.sword.getRenderPriority(dir), equals(10));

        // Quần, Giáp, Giày, Mũ, Phụ kiện: priority = 30 (đè lên thân)
        expect(EquipmentType.pants.getRenderPriority(dir), equals(30));
        expect(EquipmentType.armor.getRenderPriority(dir), equals(30));
        expect(EquipmentType.shoes.getRenderPriority(dir), equals(30));
        expect(EquipmentType.helmet.getRenderPriority(dir), equals(30));
        expect(EquipmentType.necklace.getRenderPriority(dir), equals(30));
        expect(EquipmentType.glasses.getRenderPriority(dir), equals(30));
      }

      // 2. Khi hướng up (phia_tren - nhìn từ sau lưng):
      // Quần, Giáp, Giày, Mũ, Dây chuyền: priority = 20
      expect(EquipmentType.pants.getRenderPriority(GameDirection.up), equals(20));
      expect(EquipmentType.armor.getRenderPriority(GameDirection.up), equals(20));
      expect(EquipmentType.shoes.getRenderPriority(GameDirection.up), equals(20));
      expect(EquipmentType.helmet.getRenderPriority(GameDirection.up), equals(20));
      expect(EquipmentType.necklace.getRenderPriority(GameDirection.up), equals(20));

      // Cánh = 35 (đè lên lưng áo)
      expect(EquipmentType.wings.getRenderPriority(GameDirection.up), equals(35));
      // Kiếm = 40 (vẽ đè lên trên cả Cánh để lộ rõ thanh kiếm sau lưng)
      expect(EquipmentType.sword.getRenderPriority(GameDirection.up), equals(40));

      // Kính = 0 (ẩn hoàn toàn khi nhìn từ sau lưng)
      expect(EquipmentType.glasses.getRenderPriority(GameDirection.up), equals(0));
    });

    test('Virtual Joystick dimensions increased by 15%', () {
      expect(GameJoystick.bgSize, equals(83.0));
      expect(GameJoystick.bgRadius, equals(41.4));
      expect(GameJoystick.knobSize, equals(32.0));
    });

    test('GameTypography creates pixel TextStyle with VT323 font family', () {
      final style = GameTypography.pixel(
        color: const Color(0xFFFFD54F),
        fontSize: 14.0,
      );
      expect(style.fontSize, equals(14.0));
      expect(style.color, equals(const Color(0xFFFFD54F)));
      expect(style.fontFamily, contains('VT323'));
    });

    test('EquipmentLayerComponent hides glasses on GameDirection.up and shows on others', () {
      final glassesItem = EquipmentCatalog.kinh;
      final layer = EquipmentLayerComponent(equipment: glassesItem);

      // Facing down: visible
      layer.updateStateAndDirection(state: CharacterState.idle, direction: GameDirection.down);
      expect(layer.isVisible, isTrue);

      // Facing left: visible
      layer.updateStateAndDirection(state: CharacterState.move, direction: GameDirection.left);
      expect(layer.isVisible, isTrue);

      // Facing right: visible
      layer.updateStateAndDirection(state: CharacterState.move, direction: GameDirection.right);
      expect(layer.isVisible, isTrue);

      // Facing up: completely hidden
      layer.updateStateAndDirection(state: CharacterState.move, direction: GameDirection.up);
      expect(layer.isVisible, isFalse);

      // Back to down: visible again
      layer.updateStateAndDirection(state: CharacterState.idle, direction: GameDirection.down);
      expect(layer.isVisible, isTrue);
    });

    test('Sword priority is strictly higher than Wings priority across all directions', () {
      for (final dir in GameDirection.values) {
        final swordPriority = EquipmentType.sword.getRenderPriority(dir);
        final wingsPriority = EquipmentType.wings.getRenderPriority(dir);
        expect(
          swordPriority,
          greaterThan(wingsPriority),
          reason: 'Sword ($swordPriority) must render over Wings ($wingsPriority) in direction $dir',
        );
      }
    });
  });
}
