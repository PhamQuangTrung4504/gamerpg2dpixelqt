import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/equipment_types.dart';
import '../../core/game_typography.dart';
import '../../game/components/player_component.dart';
import '../../game/survival_game.dart';
import '../../game/tutorial/tutorial_manager.dart';
import '../../models/equipment.dart';
import 'character_preview_widget.dart';
import 'equipment_slot_widget.dart';
import 'item_detail_tooltip.dart';
import 'nine_slice_box.dart';
import 'stats_list_widget.dart';

/// Modal toàn màn hình hiển thị Bảng Thông Tin Trang Bị & Kho Đồ 100 ô
class InventoryOverlay extends StatefulWidget {
  final SurvivalGame game;

  const InventoryOverlay({super.key, required this.game});

  @override
  State<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay>
    with SingleTickerProviderStateMixin {
  final ScrollController _inventoryScrollController = ScrollController();
  late AnimationController _bounceController;

  Equipment? _inspectedItem;
  bool _isInspectedItemEquipped = false;
  EquipmentType? _inspectedEquippedType;

  PlayerComponent get _player => widget.game.player;

  @override
  void initState() {
    super.initState();
    _player.inventoryNotifier.addListener(_onPlayerStateChanged);
    widget.game.tutorialManager.addListener(_onPlayerStateChanged);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    widget.game.tutorialManager.removeListener(_onPlayerStateChanged);
    _player.inventoryNotifier.removeListener(_onPlayerStateChanged);
    _inventoryScrollController.dispose();
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
    if (widget.game.tutorialManager.currentStep == PrologueStep.equipSword &&
        item.id == EquipmentCatalog.kiemGo.id) {
      widget.game.tutorialManager.onSwordEquipped();
    }
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
    final step = widget.game.tutorialManager.currentStep;
    final isEquipTutorial = step == PrologueStep.equipSword;
    final isReadyToExitTutorial = step == PrologueStep.exitInventory;

    return Material(
      color: const Color(0xD8000000),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Co giãn responsive theo tỉ lệ màn hình, tối đa 820x420
          final modalWidth = (constraints.maxWidth * 0.94).clamp(320.0, 820.0);
          final modalHeight = (constraints.maxHeight * 0.92).clamp(300.0, 420.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Khung chính chứa 2 bảng lớn cạnh nhau
              Center(
                child: SizedBox(
                  width: modalWidth,
                  height: modalHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ==========================================
                      // BẢNG BÊN TRÁI: NHÂN VẬT & THUỘC TÍNH
                      // ==========================================
                      Expanded(
                        child: NineSliceBox.largePanel(
                          height: modalHeight,
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Tiêu đề bảng trái
                              Center(
                                child: Text(
                                  'NHÂN VẬT & TRANG BỊ',
                                  style: GameTypography.pixel(
                                    color: const Color(0xFFFFD54F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Nửa trên: Bố trí 10 ô trang bị bao quanh nhân vật theo cấu tạo RPG
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Cột bên trái (4 ô): Kính, Dây chuyền, Quần, Giày
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.glasses],
                                          slotType: EquipmentType.glasses,
                                          onTap: () => _inspectEquippedItem(EquipmentType.glasses),
                                        ),
                                        const SizedBox(height: 2),
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.necklace],
                                          slotType: EquipmentType.necklace,
                                          onTap: () => _inspectEquippedItem(EquipmentType.necklace),
                                        ),
                                        const SizedBox(height: 2),
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.pants],
                                          slotType: EquipmentType.pants,
                                          onTap: () => _inspectEquippedItem(EquipmentType.pants),
                                        ),
                                        const SizedBox(height: 2),
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.shoes],
                                          slotType: EquipmentType.shoes,
                                          onTap: () => _inspectEquippedItem(EquipmentType.shoes),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 8),

                                    // Cột chính giữa: Mũ (trên đầu), Nhân vật Preview, Áo giáp (dưới thân)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Phía trên: Mũ nằm chính giữa bên trên đầu nhân vật
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.helmet],
                                          slotType: EquipmentType.helmet,
                                          onTap: () => _inspectEquippedItem(EquipmentType.helmet),
                                        ),
                                        const SizedBox(height: 3),

                                        // Mô hình nhân vật preview (thu nhỏ 20%, scale 1.45, khung 56x56)
                                        CharacterPreviewWidget(
                                          equippedItems: equipped,
                                          scale: 1.45,
                                          containerSize: 56,
                                        ),
                                        const SizedBox(height: 3),

                                        // Dưới thân: Áo giáp
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.armor],
                                          slotType: EquipmentType.armor,
                                          onTap: () => _inspectEquippedItem(EquipmentType.armor),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 8),

                                    // Cột bên phải (4 ô): Kiếm (Vũ khí), Cánh, Nhẫn, Bí kíp
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.sword],
                                          slotType: EquipmentType.sword,
                                          onTap: () => _inspectEquippedItem(EquipmentType.sword),
                                        ),
                                        const SizedBox(height: 2),
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.wings],
                                          slotType: EquipmentType.wings,
                                          onTap: () => _inspectEquippedItem(EquipmentType.wings),
                                        ),
                                        const SizedBox(height: 2),
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.ring],
                                          slotType: EquipmentType.ring,
                                          onTap: () => _inspectEquippedItem(EquipmentType.ring),
                                        ),
                                        const SizedBox(height: 2),
                                        EquipmentSlotWidget(
                                          size: 28,
                                          item: equipped[EquipmentType.tome],
                                          slotType: EquipmentType.tome,
                                          onTap: () => _inspectEquippedItem(EquipmentType.tome),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Nửa dưới: Danh sách cuộn xem trọn vẹn 14 chỉ số thuộc tính thực tế
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

                      const SizedBox(width: 12),

                      // ==========================================
                      // BẢNG BÊN PHẢI: KHO ĐỒ / TÚI ĐỒ (100 Ô)
                      // ==========================================
                      Expanded(
                        child: NineSliceBox.largePanel(
                          height: modalHeight,
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Tiêu đề bảng phải kèm số lượng ô và khoảng đệm an toàn tránh nút [X]
                              Row(
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'KHO ĐỒ (HÀNH TRANG)',
                                            style: GameTypography.pixel(
                                              color: const Color(0xFFFFD54F),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              shadows: const [
                                                Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0x66000000),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0x55FFD54F), width: 1),
                                            ),
                                            child: Text(
                                              '${inventory.length} / ${PlayerComponent.maxInventorySlots}',
                                              style: GameTypography.pixel(
                                                color: const Color(0xFFE0E0E0),
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                shadows: const [
                                                  Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Khoảng đệm an toàn tuyệt đối không để nút Đóng [X] đè lên chữ
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Lưới 100 ô vật phẩm có thanh cuộn mượt mà (5 ô mỗi hàng, 20 hàng)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x66000000),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0x44FFFFFF), width: 1),
                                  ),
                                  child: Scrollbar(
                                    controller: _inventoryScrollController,
                                    thumbVisibility: true,
                                    thickness: 4,
                                    radius: const Radius.circular(2),
                                    child: GridView.builder(
                                      controller: _inventoryScrollController,
                                      physics: const ClampingScrollPhysics(),
                                      padding: const EdgeInsets.only(right: 6),
                                      itemCount: PlayerComponent.maxInventorySlots,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 5,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                        childAspectRatio: 1.0,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item = (index < inventory.length) ? inventory[index] : null;
                                        final isSwordTutorialTarget = isEquipTutorial &&
                                            _inspectedItem == null &&
                                            item != null &&
                                            item.id == EquipmentCatalog.kiemGo.id;

                                        return EquipmentSlotWidget(
                                          item: item,
                                          isSelected: _inspectedItem == item && item != null,
                                          isHighlighted: isSwordTutorialTarget,
                                          onTap: item != null ? () => _inspectInventoryItem(item) : null,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Thanh hiển thị Vàng dưới cùng
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x55000000),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0x44FFD54F)),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/vat_pham/vat_pham_vang_16x16.png',
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Vàng: ',
                                      style: GameTypography.pixel(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${_player.gold}',
                                      style: GameTypography.pixel(
                                        color: const Color(0xFFFFD54F),
                                        fontSize: 16,
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
                top: 8,
                right: 12,
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
                          BoxShadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 2)),
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

              // Banner hướng dẫn tân thủ (nằm trên đỉnh Stack, không bị 2 panel che khuất)
              if (isEquipTutorial || isReadyToExitTutorial)
                Positioned(
                  top: 10,
                  left: 20,
                  right: 60,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xEE141414),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isReadyToExitTutorial
                              ? const Color(0xFF81C784)
                              : const Color(0xFFFFD54F),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isReadyToExitTutorial
                                ? Icons.check_circle
                                : Icons.lightbulb,
                            color: isReadyToExitTutorial
                                ? const Color(0xFF81C784)
                                : const Color(0xFFFFD54F),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isReadyToExitTutorial
                                  ? 'Trang bị Kiếm Gỗ thành công! Nhấn [X] để tiếp tục hướng dẫn!'
                                  : 'Hãy chọn Kiếm Gỗ trong Túi Đồ và nhấn nút "Trang Bị" để sẵn sàng chiến đấu!',
                              style: GameTypography.pixel(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Mũi tên nhấp nhô trỏ thẳng vào nút Thoát [X] màu đỏ khi đã trang bị xong
              if (isReadyToExitTutorial)
                Positioned(
                  top: 44,
                  right: 12,
                  child: AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final bounce = sin(_bounceController.value * pi) * 3.0;
                      return Transform.translate(
                        offset: Offset(0, bounce),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xEE2E7D32),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                            boxShadow: const [
                              BoxShadow(color: Colors.black87, blurRadius: 5),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_upward, color: Color(0xFFFFD54F), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Bấm nút [X] để thoát!',
                                style: GameTypography.pixel(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Popup soi đồ chi tiết (ItemDetailTooltip) nếu đang nhấp vào món đồ
              if (_inspectedItem != null)
                GestureDetector(
                  onTap: _closeInspect,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: const Color(0x77000000),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {}, // Chặn click xuyên qua nền
                      child: ItemDetailTooltip(
                        item: _inspectedItem!,
                        isEquipped: _isInspectedItemEquipped,
                        playerLevel: playerLevel,
                        isTutorialEquipTarget: isEquipTutorial &&
                            !_isInspectedItemEquipped &&
                            _inspectedItem?.id == EquipmentCatalog.kiemGo.id,
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
          );
        },
      ),
    );
  }
}
