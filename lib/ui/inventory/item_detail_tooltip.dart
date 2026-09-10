import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/equipment_types.dart';
import '../../core/game_typography.dart';
import '../../models/equipment.dart';
import 'nine_slice_box.dart';

/// Hộp thoại/Popup soi đồ chi tiết 9-Slice (khung_soi_do_9slice_32x32.png)
/// Bố cục chuẩn mực 3 phần: Header cố định, Body cuộn mượt mà và Footer cố định nút bấm
class ItemDetailTooltip extends StatefulWidget {
  final Equipment item;
  final bool isEquipped;
  final int playerLevel;
  final bool isTutorialEquipTarget;
  final VoidCallback? onEquip;
  final VoidCallback? onUnequip;
  final VoidCallback? onSell;
  final VoidCallback? onClose;

  const ItemDetailTooltip({
    super.key,
    required this.item,
    required this.isEquipped,
    required this.playerLevel,
    this.isTutorialEquipTarget = false,
    this.onEquip,
    this.onUnequip,
    this.onSell,
    this.onClose,
  });

  @override
  State<ItemDetailTooltip> createState() => _ItemDetailTooltipState();
}

class _ItemDetailTooltipState extends State<ItemDetailTooltip>
    with SingleTickerProviderStateMixin {
  AnimationController? _bounceController;

  @override
  void initState() {
    super.initState();
    if (widget.isTutorialEquipTarget) {
      _initBounce();
    }
  }

  @override
  void didUpdateWidget(covariant ItemDetailTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTutorialEquipTarget && _bounceController == null) {
      _initBounce();
    } else if (!widget.isTutorialEquipTarget && _bounceController != null) {
      _bounceController?.dispose();
      _bounceController = null;
    }
  }

  void _initBounce() {
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    super.dispose();
  }

  Color _getRarityColor(EquipmentMaterial material) {
    switch (material) {
      case EquipmentMaterial.wood:
        return const Color(0xFFBCAAA4);
      case EquipmentMaterial.iron:
        return const Color(0xFFECEFF1);
      case EquipmentMaterial.silver:
        return const Color(0xFF80DEEA);
      case EquipmentMaterial.gold:
        return const Color(0xFFFFD54F);
      case EquipmentMaterial.emerald:
        return const Color(0xFF69F0AE);
      case EquipmentMaterial.diamond:
        return const Color(0xFF40C4FF);
      case EquipmentMaterial.special:
        return const Color(0xFFFF4081);
    }
  }

  List<String> _buildStatBonusList() {
    final list = <String>[];
    final s = widget.item.stats;

    if (s.maxHp > 0) list.add('+${s.maxHp.toInt()} Máu tối đa');
    if (s.hpRegen > 0) list.add('+${s.hpRegen.toInt()} Hồi máu /s');
    if (s.maxMp > 0) list.add('+${s.maxMp.toInt()} Năng lượng tối đa');
    if (s.mpRegen > 0) list.add('+${s.mpRegen.toInt()} Hồi năng lượng /s');
    if (s.attackPower > 0) list.add('+${s.attackPower.toInt()} Sức mạnh tấn công');
    if (s.critDamage > 0) list.add('+${s.critDamage.toInt()} Điểm chí mạng');
    if (s.defense > 0) list.add('+${s.defense.toInt()} Giáp phòng thủ');
    if (s.armorPenetration > 0) list.add('+${s.armorPenetration.toInt()} Xuyên giáp');
    if (s.critResistance > 0) list.add('+${s.critResistance.toInt()} Kháng chí mạng');
    if (s.dodge > 0) list.add('+${s.dodge.toInt()}% Né đòn');
    if (s.lifeSteal > 0) list.add('+${s.lifeSteal.toInt()}% Hút máu');
    if (s.manaSteal > 0) list.add('+${s.manaSteal.toInt()}% Hút mana');
    if (s.reflectDamage > 0) list.add('+${s.reflectDamage.toInt()}% Phản sát thương');
    if (s.coolness > 0) list.add('+${s.coolness.toInt()}% Ngầu');

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isLevelMet = widget.playerLevel >= widget.item.requiredLevel;
    final statList = _buildStatBonusList();
    final nameColor = _getRarityColor(widget.item.material);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Giới hạn chiều cao tối đa của Popup soi đồ theo yêu cầu
        final maxPopupHeight = (constraints.maxHeight * 0.75).clamp(240.0, 480.0);
        final popupWidth = 290.0.clamp(260.0, constraints.maxWidth * 0.9);

        return SizedBox(
          width: popupWidth,
          height: maxPopupHeight,
          child: NineSliceBox.inspectPanel(
            width: popupWidth,
            height: maxPopupHeight,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==========================================
                // 1. HEADER (Cố định ở đỉnh): Icon + Tên + Nút đóng [X]
                // ==========================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      widget.item.iconAssetPath,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GameTypography.pixel(
                              color: nameColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                              ],
                            ),
                          ),
                          Text(
                            'Loại: ${widget.item.type.vietnameseName} (${widget.item.material.vietnameseName})',
                            style: GameTypography.pixel(
                              color: const Color(0xFFAAAAAA),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onClose != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0x33FFFFFF),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white70),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 0.5, color: Color(0x33FFFFFF)),
                const SizedBox(height: 6),

                // ==========================================
                // 2. BODY (Cuộn linh hoạt Expanded + SingleChildScrollView)
                // ==========================================
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 3,
                    radius: const Radius.circular(2),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 2.1 Cấp độ yêu cầu & Cảnh báo chưa đủ cấp
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Yêu cầu: ',
                                  style: GameTypography.pixel(
                                    color: isLevelMet ? const Color(0xFFBBBBBB) : const Color(0xFFFF5252),
                                    fontSize: 13,
                                    fontWeight: isLevelMet ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Cấp ${widget.item.requiredLevel}',
                                  style: GameTypography.pixel(
                                    color: isLevelMet ? const Color(0xFF81C784) : const Color(0xFFFF5252),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isLevelMet) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(Chưa đủ!)',
                                    style: GameTypography.pixel(
                                      color: const Color(0xFFFF5252),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Dòng tip hướng dẫn cảnh báo cấp độ yêu cầu
                          if (!isLevelMet) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0x33FF5252),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0x88FF5252), width: 1),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, size: 14, color: Color(0xFFFF8A80)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Cần đạt Cấp ${widget.item.requiredLevel} để trang bị. Trang bị cấp cao mang lại sức mạnh vượt trội hơn!',
                                      style: GameTypography.pixel(
                                        color: const Color(0xFFFFCDD2),
                                        fontSize: 11.5,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),

                          // 2.2 Danh sách thuộc tính cộng thêm màu xanh lá
                          if (statList.isNotEmpty) ...[
                            ...statList.map(
                              (stat) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_right, size: 14, color: Color(0xFF69F0AE)),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        stat,
                                        style: GameTypography.pixel(
                                          color: const Color(0xFF69F0AE),
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
                          ] else
                            Text(
                              'Không có chỉ số cộng thêm',
                              style: GameTypography.pixel(color: Colors.white54, fontSize: 12),
                            ),

                          const SizedBox(height: 6),
                          const Divider(height: 1, thickness: 0.5, color: Color(0x33FFFFFF)),
                          const SizedBox(height: 6),

                          // 2.3 Giá bán
                          Row(
                            children: [
                              Text(
                                'Giá bán: ',
                                style: GameTypography.pixel(color: const Color(0xFFBBBBBB), fontSize: 13),
                              ),
                              Image.asset(
                                'assets/vat_pham/vat_pham_vang_16x16.png',
                                width: 14,
                                height: 14,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.none,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.item.sellPrice}',
                                style: GameTypography.pixel(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 0.5, color: Color(0x33FFFFFF)),
                const SizedBox(height: 6),

                // ==========================================
                // 3. FOOTER (Cố định ở đáy): Cụm nút bấm tương tác
                // ==========================================
                if (widget.isEquipped) ...[
                  NineSliceButton(
                    text: 'Gỡ Đồ',
                    height: 28,
                    fontSize: 14,
                    onPressed: widget.onUnequip,
                  ),
                ] else ...[
                  // Gợi ý trang bị Kiếm Gỗ nhấp nhô nếu đang trong hướng dẫn
                  if (widget.isTutorialEquipTarget && _bounceController != null) ...[
                    AnimatedBuilder(
                      animation: _bounceController!,
                      builder: (context, child) {
                        final bounce = sin(_bounceController!.value * pi) * 2.5;
                        return Transform.translate(
                          offset: Offset(0, bounce),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xEE2E7D32),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                              boxShadow: const [
                                BoxShadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_downward, color: Color(0xFFFFD54F), size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bấm vào đây để trang bị!',
                                    style: GameTypography.pixel(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: NineSliceButton(
                          text: 'Trang Bị',
                          height: 28,
                          fontSize: 14,
                          enabled: isLevelMet,
                          textColor: isLevelMet ? const Color(0xFF3E2723) : const Color(0xFF757575),
                          onPressed: isLevelMet ? widget.onEquip : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NineSliceButton(
                          text: 'Bán',
                          height: 28,
                          fontSize: 14,
                          textColor: const Color(0xFF5D4037),
                          onPressed: widget.onSell,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
