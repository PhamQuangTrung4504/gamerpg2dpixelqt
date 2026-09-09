import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/constants/equipment_types.dart';
import 'package:gamerpg2dpixelqt/core/asset_paths.dart';
import 'package:gamerpg2dpixelqt/game/components/drop_item_component.dart';
import 'package:gamerpg2dpixelqt/game/components/monster_component.dart';
import 'package:gamerpg2dpixelqt/game/components/player_component.dart';
import 'package:gamerpg2dpixelqt/game/monster_spawner.dart';
import 'package:gamerpg2dpixelqt/game/survival_game.dart';
import 'package:gamerpg2dpixelqt/game/tutorial/tutorial_manager.dart';
import 'package:gamerpg2dpixelqt/models/equipment.dart';
import 'package:gamerpg2dpixelqt/models/monster.dart';
import 'package:gamerpg2dpixelqt/ui/tutorial/tutorial_hint_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prologue & Tutorial Scene Tests', () {
    test('Player starts without weapon when startWithSword is false', () {
      final player = PlayerComponent(startWithSword: false);

      expect(player.equippedItems.containsKey(EquipmentType.sword), isFalse);
      expect(player.equippedItems.isEmpty, isTrue);
      // Punch attack base damage remains 10 ATK
      expect(player.stats.attackPower, equals(10));
    });



    test('NPC Elder asset paths are valid and defined in AssetPaths', () {
      expect(AssetPaths.npcElder, equals('assets/npc/truong_lang_dung_im_noi_chuyen.png'));
      expect(AssetPaths.npcElderFlame, equals('npc/truong_lang_dung_im_noi_chuyen.png'));
    });

    testWidgets('TutorialHintOverlay wraps root with IgnorePointer for touch pass-through', (WidgetTester tester) async {
      final game = SurvivalGame();
      game.player = PlayerComponent(startWithSword: false);
      game.spawner = MonsterSpawnerComponent()..isEnabled = false;
      await game.world.add(game.spawner);
      final tutorial = TutorialManager();
      game.tutorialManager = tutorial;
      game.overlays.addEntry('PrologueDialogueOverlay', (context, game) => const SizedBox());
      game.overlays.addEntry('TutorialHintOverlay', (context, game) => const SizedBox());
      await game.add(tutorial);

      // Set combat step so hint overlay renders
      tutorial.start();
      tutorial.onDialogueFinished();
      tutorial.update(3.5); // Advance to combat step

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialHintOverlay(game: game),
          ),
        ),
      );

      // Verify IgnorePointer exists as the wrapper of TutorialHintOverlay
      final overlayIgnorePointer = find.descendant(
        of: find.byType(TutorialHintOverlay),
        matching: find.byType(IgnorePointer),
      );
      expect(overlayIgnorePointer, findsWidgets);

      final rootIgnorePointer = tester.widget<IgnorePointer>(overlayIgnorePointer.first);
      expect(rootIgnorePointer.ignoring, isTrue);
    });

    test('MonsterComponent remains idle and does not pursue when tutorialManager isPanning is active', () async {
      final game = SurvivalGame();
      game.player = PlayerComponent(startWithSword: false);
      game.spawner = MonsterSpawnerComponent()..isEnabled = false;
      await game.world.add(game.spawner);
      final tutorial = TutorialManager();
      game.tutorialManager = tutorial;
      game.overlays.addEntry('PrologueDialogueOverlay', (context, game) => const SizedBox());
      game.overlays.addEntry('TutorialHintOverlay', (context, game) => const SizedBox());
      await game.add(tutorial);

      final initialPos = Vector2(200, 200);
      final slime = MonsterComponent(
        monsterData: MonsterCatalog.getByLevel(1)!,
        initialPosition: initialPos,
      );
      await game.world.add(slime);

      // When panning is true
      tutorial.start();
      tutorial.onDialogueFinished();
      expect(tutorial.isPanning, isTrue);

      // Slime update should NOT move during camera pan
      slime.update(1.0);
      expect(slime.position, equals(initialPos));
    });

    test('MonsterSpawnerComponent isEnabled flag controls spawning loop', () {
      final spawner = MonsterSpawnerComponent();
      expect(spawner.isEnabled, isTrue);

      spawner.isEnabled = false;
      expect(spawner.isEnabled, isFalse);
    });

    test('TutorialManager linear step progression and spawner activation', () async {
      final game = SurvivalGame();
      // Setup minimal mock environment
      game.player = PlayerComponent(startWithSword: false);
      game.spawner = MonsterSpawnerComponent()..isEnabled = false;
      await game.world.add(game.spawner);
      final tutorial = TutorialManager();
      game.tutorialManager = tutorial;
      // Register dummy overlay entries for headless test
      game.overlays.addEntry('PrologueDialogueOverlay', (context, game) => const SizedBox());
      game.overlays.addEntry('TutorialHintOverlay', (context, game) => const SizedBox());
      await game.add(tutorial);

      expect(tutorial.currentStep, equals(PrologueStep.none));

      // 1. Start dialogue step
      tutorial.start();
      expect(tutorial.currentStep, equals(PrologueStep.dialogue));
      expect(tutorial.isTutorialActive, isTrue);

      // 2. Dialogue finished -> Camera Pan
      tutorial.onDialogueFinished();
      expect(tutorial.currentStep, equals(PrologueStep.cameraPan));

      // Simulate camera pan complete
      tutorial.update(3.5); // Advances past 3.4s of camera pan
      expect(tutorial.currentStep, equals(PrologueStep.combat));
      expect(tutorial.currentHintText, contains('tiếp cận'));

      // Simulate player near monsters
      game.player.position = tutorial.tutorialSlimes.first.position.clone();
      tutorial.update(0.1);
      expect(tutorial.currentHintText, contains('Tấn công'));

      // Simulate all slimes defeated -> pickupSword
      final slimes = game.world.children.whereType<MonsterComponent>().toList();
      for (final s in slimes) {
        s.currentHp = 0;
      }
      tutorial.update(0.1);

      expect(tutorial.currentStep, equals(PrologueStep.pickupSword));
      expect(tutorial.currentHintText, contains('Nhặt Kiếm Gỗ'));

      // 4. Simulate sword collected
      game.player.addToInventory(EquipmentCatalog.kiemGo);
      // Simulate drop item callback
      final dropItem = game.world.children.whereType<DropItemComponent>().first;
      dropItem.onCollectedCallback?.call();

      expect(tutorial.currentStep, equals(PrologueStep.equipSword));
      expect(tutorial.currentHintText, contains('Mở túi đồ'));

      // 5. Simulate player equipping sword
      game.player.equip(EquipmentCatalog.kiemGo);
      tutorial.update(0.1);

      expect(tutorial.currentStep, equals(PrologueStep.completed));
      expect(tutorial.currentHintText, contains('Tuyệt vời'));
      expect(game.spawner.isEnabled, isTrue);
    });
  });
}
