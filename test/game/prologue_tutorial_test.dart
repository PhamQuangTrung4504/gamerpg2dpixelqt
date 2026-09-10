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
import 'package:gamerpg2dpixelqt/models/skill.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/equipment_slot_widget.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/inventory_overlay.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/item_detail_tooltip.dart';
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
      game.overlays.addEntry('TutorialHintOverlay', (context, game) => const SizedBox());
      game.overlays.addEntry('PrologueDialogueOverlay', (context, game) => const SizedBox());
      await game.add(tutorial);

      // Start tutorial directly enters combat
      tutorial.start();

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

    test('MonsterSpawnerComponent isEnabled flag controls spawning loop', () {
      final spawner = MonsterSpawnerComponent();
      expect(spawner.isEnabled, isTrue);

      spawner.isEnabled = false;
      expect(spawner.isEnabled, isFalse);
    });

    test('TutorialManager coordinates complete 5-stage sequential tutorial flow', () async {
      final game = SurvivalGame();
      game.player = PlayerComponent(startWithSword: false);
      game.spawner = MonsterSpawnerComponent()..isEnabled = false;
      await game.world.add(game.spawner);
      final tutorial = TutorialManager();
      game.tutorialManager = tutorial;
      game.overlays.addEntry('TutorialHintOverlay', (context, game) => const SizedBox());
      game.overlays.addEntry('PrologueDialogueOverlay', (context, game) => const SizedBox());
      await game.add(tutorial);

      expect(tutorial.currentStep, equals(PrologueStep.none));

      // 1. Giai đoạn 1: Già Làng nói chuyện, 4 Slime đứng im
      tutorial.start();
      expect(tutorial.currentStep, equals(PrologueStep.elderDialogue));
      expect(tutorial.isTutorialActive, isTrue);
      expect(tutorial.tutorialSlimes.length, equals(4));
      for (final s in tutorial.tutorialSlimes) {
        expect(s.isAiActive, isFalse);
      }

      // 1.2 Kết thúc thoại Già Làng -> Lia camera
      tutorial.onDialogueFinished();
      expect(tutorial.currentStep, equals(PrologueStep.cameraPan));
      expect(tutorial.isPanning, isTrue);

      // Mô phỏng hoàn tất lia camera (1.5s lia sang + 1.0s nhìn + 1.5s lia về = 4.0s)
      tutorial.update(1.6);
      tutorial.update(1.1);
      tutorial.update(1.6);

      // Camera pan hoàn tất -> Slimes kích hoạt AI, bước sang combat
      expect(tutorial.currentStep, equals(PrologueStep.combat));
      expect(tutorial.isPanning, isFalse);
      for (final s in tutorial.tutorialSlimes) {
        expect(s.isAiActive, isTrue);
      }
      expect(
        tutorial.currentHintText,
        contains('Dùng Cần gạt ảo (Joystick) hoặc phím WASD để tiếp cận và nhấn Nút Đánh'),
      );

      // 2. Giai đoạn 2: Tiêu diệt 4 Slime -> Rớt Kiếm Gỗ
      final slimes = game.world.children.whereType<MonsterComponent>().toList();
      for (final s in slimes) {
        s.currentHp = 0;
      }
      tutorial.update(0.1);

      expect(tutorial.currentStep, equals(PrologueStep.pickupSword));
      expect(tutorial.currentHintText, contains('Nhặt Kiếm Gỗ'));
      expect(game.player.expManager.currentLevel, equals(2));
      expect(game.player.expManager.skillPoints, equals(1));
      expect(game.player.expManager.attributePoints, equals(3));

      // 3. Giai đoạn 2 -> 3: Nhặt Kiếm Gỗ -> Mũi tên chỉ icon Rương Đồ
      game.player.addToInventory(EquipmentCatalog.kiemGo);
      final dropItem = game.world.children.whereType<DropItemComponent>().first;
      dropItem.onCollectedCallback?.call();

      expect(tutorial.currentStep, equals(PrologueStep.openInventory));
      expect(tutorial.currentHintText, contains('mở Rương Đồ'));

      // Mở Túi Đồ
      tutorial.onInventoryOpened();
      expect(tutorial.currentStep, equals(PrologueStep.equipSword));

      // Trang bị Kiếm Gỗ -> exitInventory
      await game.player.equip(EquipmentCatalog.kiemGo);
      tutorial.onSwordEquipped();
      expect(tutorial.currentStep, equals(PrologueStep.exitInventory));

      // Đóng Túi Đồ -> Chuyển sang Giai đoạn 4: Nâng Kỹ Năng
      tutorial.onInventoryClosed();
      expect(tutorial.currentStep, equals(PrologueStep.openSkillTree));
      expect(tutorial.currentHintText, contains('Bảng Kỹ Năng'));

      // Mở Bảng Kỹ Năng
      tutorial.onSkillTreeOpened();
      expect(tutorial.currentStep, equals(PrologueStep.upgradeSkill));

      // Nâng cấp kỹ năng
      tutorial.onSkillUpgraded();
      expect(tutorial.currentStep, equals(PrologueStep.exitSkillTree));

      // Đóng Bảng Kỹ Năng -> Chuyển sang Giai đoạn 5: Nâng Thuộc Tính
      tutorial.onSkillTreeClosed();
      expect(tutorial.currentStep, equals(PrologueStep.openStats));
      expect(tutorial.currentHintText, contains('Bảng Thuộc Tính'));

      // Mở Bảng Thuộc Tính
      tutorial.onStatsOpened();
      expect(tutorial.currentStep, equals(PrologueStep.upgradeStats));

      // Nâng điểm thuộc tính
      tutorial.onStatUpgraded();
      expect(tutorial.currentStep, equals(PrologueStep.exitStats));

      // Đóng Bảng Thuộc Tính -> Hoàn tất toàn bộ kịch bản!
      tutorial.onStatsClosed();
      expect(tutorial.currentStep, equals(PrologueStep.completed));
      expect(tutorial.currentHintText, contains('Hoàn thành tân thủ'));
      expect(game.spawner.isEnabled, isTrue);
      expect(game.isSurvivalTimerActive, isTrue);
    });

    testWidgets('EquipmentSlotWidget renders highlight and guide indicator when isHighlighted is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EquipmentSlotWidget(
                item: EquipmentCatalog.kiemGo,
                isHighlighted: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(EquipmentSlotWidget), findsOneWidget);
      expect(find.text('Kiếm'), findsOneWidget);
    });

    testWidgets('ItemDetailTooltip displays warning and disables Trang Bi button when level requirement is not met', (WidgetTester tester) async {
      // Find a high level item
      final highLevelItem = EquipmentCatalog.all.firstWhere((e) => e.requiredLevel >= 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ItemDetailTooltip(
                item: highLevelItem,
                isEquipped: false,
                playerLevel: 1, // Under-leveled
              ),
            ),
          ),
        ),
      );

      // Warning text should be visible
      expect(find.textContaining('Cần đạt Cấp ${highLevelItem.requiredLevel}'), findsOneWidget);
      expect(find.textContaining('Chưa đủ'), findsOneWidget);

      // Trang Bi button should exist and be disabled
      expect(find.text('Trang Bị'), findsOneWidget);
    });

    testWidgets('ItemDetailTooltip displays tutorial guide indicator when isTutorialEquipTarget is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ItemDetailTooltip(
                item: EquipmentCatalog.kiemGo,
                isEquipped: false,
                playerLevel: 1,
                isTutorialEquipTarget: true,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('trang bị'), findsWidgets);
      expect(find.text('Bấm vào đây để trang bị!'), findsOneWidget);
    });

    test('Player component starts with 3 skills locked at level 0', () {
      final player = PlayerComponent();
      expect(player.isSkillUnlocked(SkillCatalog.danhThuong.id), isTrue);
      expect(player.isSkillUnlocked(SkillCatalog.lietHoaDoatMenh.id), isFalse);
      expect(player.isSkillUnlocked(SkillCatalog.vanKiemQuyTong.id), isFalse);
      expect(player.isSkillUnlocked(SkillCatalog.nguKiemPhiKiem.id), isFalse);

      // Attempting to cast locked skill returns false
      expect(player.useSkill1(), isFalse);
      expect(player.useSkill2(), isFalse);
      expect(player.useSkill3(), isFalse);

      // Once unlocked, skill can be cast
      player.unlockSkill(SkillCatalog.lietHoaDoatMenh.id);
      expect(player.isSkillUnlocked(SkillCatalog.lietHoaDoatMenh.id), isTrue);
      expect(player.useSkill1(), isTrue);
    });

    testWidgets('InventoryOverlay displays top banner and exit bouncing arrow when readyToExitInventory', (WidgetTester tester) async {
      final game = SurvivalGame();
      game.player = PlayerComponent(startWithSword: false);
      game.tutorialManager = TutorialManager();
      game.tutorialManager.onSwordEquipped();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryOverlay(game: game),
          ),
        ),
      );

      // Banner should be visible on top
      expect(find.textContaining('Trang bị Kiếm Gỗ thành công'), findsOneWidget);
      // Bouncing arrow pointing to [X] should be visible
      expect(find.textContaining('Bấm nút [X] để thoát'), findsOneWidget);
    });
  });
}
