import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/constants/equipment_types.dart';
import 'package:gamerpg2dpixelqt/game/components/player_component.dart';
import 'package:gamerpg2dpixelqt/models/character_stats.dart';
import 'package:gamerpg2dpixelqt/models/equipment.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/equipment_slot_widget.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/item_detail_tooltip.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/nine_slice_box.dart';
import 'package:gamerpg2dpixelqt/ui/inventory/stats_list_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Inventory & Equipment Logic Tests', () {
    test('Initial inventory state and starter items', () {
      final player = PlayerComponent();

      // Kiểm tra trang bị ban đầu
      expect(player.equippedItems.containsKey(EquipmentType.sword), isTrue);
      expect(player.equippedItems[EquipmentType.sword]?.id, equals('kiem_go'));

      // Kiểm tra túi đồ có sức chứa tối đa 20 ô
      expect(PlayerComponent.maxInventorySlots, equals(20));

      // Kiểm tra túi đồ ban đầu rỗng và vàng là 0
      expect(player.inventory.isEmpty, isTrue);
      expect(player.gold, equals(0));
    });

    test('Add and remove item from inventory', () {
      final player = PlayerComponent();
      final initialCount = player.inventory.length;

      // Thêm kiếm bạc
      final added = player.addToInventory(EquipmentCatalog.kiemBac);
      expect(added, isTrue);
      expect(player.inventory.length, equals(initialCount + 1));
      expect(player.inventory.contains(EquipmentCatalog.kiemBac), isTrue);

      // Xóa kiếm bạc
      final removed = player.removeFromInventory(EquipmentCatalog.kiemBac);
      expect(removed, isTrue);
      expect(player.inventory.length, equals(initialCount));
      expect(player.inventory.contains(EquipmentCatalog.kiemBac), isFalse);
    });

    test('Inventory capacity limit (max 20 slots)', () {
      final player = PlayerComponent();
      // Làm đầy túi đồ tới 20 món
      while (player.inventory.length < PlayerComponent.maxInventorySlots) {
        player.addToInventory(EquipmentCatalog.nhanSat);
      }
      expect(player.inventory.length, equals(PlayerComponent.maxInventorySlots));

      // Thêm món thứ 21 -> thất bại
      final overflow = player.addToInventory(EquipmentCatalog.kiemKimCuong);
      expect(overflow, isFalse);
      expect(player.inventory.length, equals(PlayerComponent.maxInventorySlots));
    });

    test('Equip from inventory swaps existing equipment back to inventory', () async {
      final player = PlayerComponent();
      final initialEquippedSword = player.equippedItems[EquipmentType.sword];
      expect(initialEquippedSword?.id, equals('kiem_go'));

      // Đảm bảo kiếm sắt nằm trong túi đồ
      player.addToInventory(EquipmentCatalog.kiemSat);
      expect(player.inventory.contains(EquipmentCatalog.kiemSat), isTrue);

      // Mặc kiếm sắt từ túi
      await player.equipFromInventory(EquipmentCatalog.kiemSat);

      // Kiếm sắt đã được mặc
      expect(player.equippedItems[EquipmentType.sword]?.id, equals('kiem_sat'));
      // Kiếm gỗ cũ bị đẩy lại về túi đồ
      expect(player.inventory.contains(EquipmentCatalog.kiemGo), isTrue);
      // Kiếm sắt không còn nằm trong túi đồ
      expect(player.inventory.contains(EquipmentCatalog.kiemSat), isFalse);
    });

    test('Unequip item moves it to inventory and recalculates stats', () {
      final player = PlayerComponent();
      final initialAtk = player.stats.attackPower;

      // Tháo kiếm gỗ về túi đồ
      final unequipped = player.unequipToInventory(EquipmentType.sword);
      expect(unequipped, isTrue);
      expect(player.equippedItems.containsKey(EquipmentType.sword), isFalse);
      expect(player.inventory.contains(EquipmentCatalog.kiemGo), isTrue);

      // Sức mạnh tấn công giảm đi 10 điểm của kiếm gỗ
      expect(player.stats.attackPower, equals(initialAtk - 10));
    });

    test('Sell item adds gold and removes from inventory', () {
      final player = PlayerComponent();
      final initialGold = player.gold;
      player.addToInventory(EquipmentCatalog.nhanSat);

      final sold = player.sellInventoryItem(EquipmentCatalog.nhanSat);
      expect(sold, isTrue);
      expect(player.inventory.contains(EquipmentCatalog.nhanSat), isFalse);
      expect(player.gold, equals(initialGold + EquipmentCatalog.nhanSat.sellPrice));
    });

    test('InventoryNotifier notifies on inventory or gold mutations', () {
      final player = PlayerComponent();
      int notifyCount = 0;
      player.inventoryNotifier.addListener(() => notifyCount++);

      player.addGold(50);
      expect(notifyCount, equals(1));

      player.addToInventory(EquipmentCatalog.kinh);
      expect(notifyCount, equals(2));

      player.removeFromInventory(EquipmentCatalog.kinh);
      expect(notifyCount, equals(3));
    });
  });

  group('Inventory UI Widgets Tests', () {
    testWidgets('NineSliceButton renders and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NineSliceButton(
                text: 'Trang Bị',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Trang Bị'), findsOneWidget);
      await tester.tap(find.text('Trang Bị'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('EquipmentSlotWidget displays empty and filled slots', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                EquipmentSlotWidget(
                  item: null,
                  slotType: EquipmentType.helmet,
                ),
                EquipmentSlotWidget(
                  item: EquipmentCatalog.kiemSat,
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(EquipmentSlotWidget), findsNWidgets(2));
      await tester.tap(find.byType(EquipmentSlotWidget).last);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('StatsListWidget renders 14 actual stat rows', (tester) async {
      const stats = CharacterStats(
        maxHp: 150,
        hpRegen: 3,
        maxMp: 120,
        mpRegen: 4,
        attackPower: 45,
        critDamage: 10,
        defense: 25,
        armorPenetration: 5,
        critResistance: 6,
        dodge: 8,
        lifeSteal: 5,
        manaSteal: 3,
        reflectDamage: 4,
        coolness: 2,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 700,
              child: StatsListWidget(
                stats: stats,
                currentHp: 130,
                currentMp: 110,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Máu (HP)'), findsOneWidget);
      expect(find.text('Hồi máu'), findsOneWidget);
      expect(find.text('Năng lượng (MP)'), findsOneWidget);
      expect(find.text('Hồi năng lượng'), findsOneWidget);
      expect(find.text('Sức mạnh tấn công'), findsOneWidget);
      expect(find.text('Điểm chí mạng'), findsOneWidget);
      expect(find.text('Giáp phòng thủ'), findsOneWidget);
      expect(find.text('Xuyên giáp'), findsOneWidget);
      expect(find.text('Kháng chí mạng'), findsOneWidget);
      expect(find.text('Né đòn'), findsOneWidget);
      expect(find.text('Hút máu'), findsOneWidget);
      expect(find.text('Hút năng lượng'), findsOneWidget);
      expect(find.text('Phản sát thương'), findsOneWidget);
      expect(find.text('Chỉ số Ngầu'), findsOneWidget);
    });

    testWidgets('ItemDetailTooltip displays equipment inspect details and action buttons', (tester) async {
      bool equipPressed = false;
      bool sellPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ItemDetailTooltip(
                item: EquipmentCatalog.kiemSat,
                isEquipped: false,
                playerLevel: 5,
                onEquip: () => equipPressed = true,
                onSell: () => sellPressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Kiếm Sắt'), findsOneWidget);
      expect(find.text('Cấp 5'), findsOneWidget);
      expect(find.text('Trang Bị'), findsOneWidget);
      expect(find.text('Bán'), findsOneWidget);

      await tester.tap(find.text('Trang Bị'));
      await tester.pump();
      expect(equipPressed, isTrue);

      await tester.tap(find.text('Bán'));
      await tester.pump();
      expect(sellPressed, isTrue);
    });
  });
}
