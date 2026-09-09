import 'package:flutter/material.dart';
import '../../constants/equipment_types.dart';
import '../../core/game_typography.dart';
import '../../game/components/player_component.dart';
import '../../game/survival_game.dart';
import '../../models/equipment.dart';
import 'character_preview_widget.dart';
import 'equipment_slot_widget.dart';
import 'item_detail_tooltip.dart';
import 'nine_slice_box.dart';
import 'stats_list_widget.dart';

/// Modal toàn màn hình hiển thị Bảng Thông Tin Trang Bị & Kho Đồ
class InventoryOverlay extends StatefulWidget {
  final SurvivalGame game;

  const InventoryOverlay({super.key, required this.game});

  @override
  State<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay> {
  Equipment? _inspectedItem;
  bool _isInspectedItemEquipped = false;
  EquipmentType? _inspectedEquippedType;

  PlayerComponent get _player => widget.game.player;

  @override
  void initState() {
    super.initState();
    _player.inventoryNotifier.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    _player.inventoryNotifier.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _inspectEquippedItem(EquipmentType type) {
    final item = _player.equippedItems[type];
    if (item != null) {
      setState(() {
        _inspectedItem = item;
        _isInspectedItemEquipped = true;
        _inspectedEquippedType = type;
      });
    }
  }

  void _inspectInventoryItem(Equipment item) {
    setState(() {
      _inspectedItem = item;
      _isInspectedItemEquipped = false;
      _inspectedEquippedType = null;
    });
  }

  void _closeInspect() {
    setState(() {
      _inspectedItem = null;
      _isInspectedItemEquipped = false;
      _inspectedEquippedType = null;
    });
  }

  Future<void> _equipItem(Equipment item) async {
    _closeInspect();
    await _player.equipFromInventory(item);
  }

  void _unequipItem(EquipmentType type) {
    _closeInspect();
    _player.unequipToInventory(type);
  }

  void _sellItem(Equipment item) {
    _closeInspect();
    _player.sellInventoryItem(item);
  }

  @override
  Widget build(BuildContext context) {
    final equipped = _player.equippedItems;
    final inventory = _player.inventory;
    final playerLevel = _player.expManager.currentLevel;

    return Material(
      color: const Color(0xCC000000),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Khung chứa 2 bảng lớn đặt cạnh nhau
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780, maxHeight: 420),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // BẢNG BÊN TRÁI: NHÂN VẬT & THUỘC TÍNH
                  // ==========================================
                  Expanded(
                    child: NineSliceBox.largePanel(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tiêu đề bảng trái
                          Center(
                            child: Text(
                              'NHÂN VẬT & TRANG BỊ',
                              style: GameTypography.pixel(
                                color: const Color(0xFFFFD54F),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Nửa trên: Mô hình nhân vật và 10 ô trang bị bao quanh
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Cột 5 ô trang bị bên trái: Mũ, Kính, Giáp, Quần, Giày
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.helmet],
                                    slotType: EquipmentType.helmet,
                                    onTap: () => _inspectEquippedItem(EquipmentType.helmet),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.glasses],
                                    slotType: EquipmentType.glasses,
                                    onTap: () => _inspectEquippedItem(EquipmentType.glasses),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.armor],
                                    slotType: EquipmentType.armor,
                                    onTap: () => _inspectEquippedItem(EquipmentType.armor),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.pants],
                                    slotType: EquipmentType.pants,
                                    onTap: () => _inspectEquippedItem(EquipmentType.pants),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.shoes],
                                    slotType: EquipmentType.shoes,
                                    onTap: () => _inspectEquippedItem(EquipmentType.shoes),
                                  ),
                                ],
                              ),

                              // Chính giữa: Mô hình nhân vật idle (Thân + Đa lớp trang bị)
                              CharacterPreviewWidget(
                                equippedItems: equipped,
                                scale: 2.3,
                              ),

                              // Cột 5 ô trang bị bên phải: Kiếm, Cánh, Dây chuyền, Nhẫn, Bí kíp
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.sword],
                                    slotType: EquipmentType.sword,
                                    onTap: () => _inspectEquippedItem(EquipmentType.sword),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.wings],
                                    slotType: EquipmentType.wings,
                                    onTap: () => _inspectEquippedItem(EquipmentType.wings),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.necklace],
                                    slotType: EquipmentType.necklace,
                                    onTap: () => _inspectEquippedItem(EquipmentType.necklace),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.ring],
                                    slotType: EquipmentType.ring,
                                    onTap: () => _inspectEquippedItem(EquipmentType.ring),
                                  ),
                                  const SizedBox(height: 4),
                                  EquipmentSlotWidget(
                                    item: equipped[EquipmentType.tome],
                                    slotType: EquipmentType.tome,
                                    onTap: () => _inspectEquippedItem(EquipmentType.tome),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Nửa dưới: Danh sách cuộn xem 14 chỉ số thuộc tính thực tế
                          Expanded(
                            child: StatsListWidget(
                              stats: _player.stats,
                              currentHp: _player.currentHp,
                              currentMp: _player.currentMp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ==========================================
                  // BẢNG BÊN PHẢI: KHO ĐỒ / TÚI ĐỒ (INVENTORY)
                  // ==========================================
                  Expanded(
                    child: NineSliceBox.largePanel(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tiêu đề bảng phải kèm số lượng ô
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KHO ĐỒ (HÀNH TRANG)',
                                style: GameTypography.pixel(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
                                    Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                  ],
                                ),
                              ),
                              Text(
                                '${inventory.length} / ${PlayerComponent.maxInventorySlots}',
                                style: GameTypography.pixel(
                                  color: const Color(0xFFAAAAAA),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Lưới 20 ô vật phẩm (Grid 4x5)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0x33000000),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0x22FFFFFF)),
                              ),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: PlayerComponent.maxInventorySlots,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                  childAspectRatio: 1.0,
                                ),
                                itemBuilder: (context, index) {
                                  final item = (index < inventory.length) ? inventory[index] : null;
                                  return EquipmentSlotWidget(
                                    item: item,
                                    isSelected: _inspectedItem == item && item != null,
                                    onTap: item != null ? () => _inspectInventoryItem(item) : null,
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Thanh hiển thị Vàng dưới cùng
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x44000000),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x33FFD54F)),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/vat_pham/vat_pham_vang_16x16.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.none,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Vàng: ',
                                  style: GameTypography.pixel(
                                    color: const Color(0xFFCCCCCC),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${_player.gold}',
                                  style: GameTypography.pixel(
                                    color: const Color(0xFFFFD54F),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút Đóng "X" góc trên bên phải màn hình
          Positioned(
            top: 14,
            right: 18,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => widget.game.closeInventory(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Popup soi đồ chi tiết (ItemDetailTooltip) nếu đang nhấp vào món đồ
          if (_inspectedItem != null)
            GestureDetector(
              onTap: _closeInspect,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: const Color(0x66000000),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {}, // Chặn click xuyên qua nền
                  child: ItemDetailTooltip(
                    item: _inspectedItem!,
                    isEquipped: _isInspectedItemEquipped,
                    playerLevel: playerLevel,
                    onEquip: () => _equipItem(_inspectedItem!),
                    onUnequip: () {
                      if (_inspectedEquippedType != null) {
                        _unequipItem(_inspectedEquippedType!);
                      }
                    },
                    onSell: () => _sellItem(_inspectedItem!),
                    onClose: _closeInspect,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
