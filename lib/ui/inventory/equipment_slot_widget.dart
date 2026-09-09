import 'package:flutter/material.dart';
import '../../constants/equipment_types.dart';
import '../../core/game_typography.dart';
import '../../models/equipment.dart';

/// Ô hiển thị trang bị (dùng cho 10 ô trên người & các ô trong túi đồ)
class EquipmentSlotWidget extends StatefulWidget {
  final Equipment? item;
  final EquipmentType? slotType;
  final VoidCallback? onTap;
  final bool isSelected;
  final double size;

  const EquipmentSlotWidget({
    super.key,
    this.item,
    this.slotType,
    this.onTap,
    this.isSelected = false,
    this.size = 38,
  });

  @override
  State<EquipmentSlotWidget> createState() => _EquipmentSlotWidgetState();
}

class _EquipmentSlotWidgetState extends State<EquipmentSlotWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasItem = widget.item != null;
    final isInteractive = widget.onTap != null && hasItem;

    // Sprite icon đường dẫn
    final String spritePath = hasItem
        ? widget.item!.iconAssetPath
        : 'assets/o_trang_bi/o_trang_bi_rong.png';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.size,
          height: widget.size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0x66FFD54F)
                : (_isHovered && hasItem ? const Color(0x44FFFFFF) : const Color(0x22000000)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFFFD54F)
                  : (_isHovered && hasItem
                      ? const Color(0xFFEEEEEE)
                      : const Color(0x448D6E63)),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ảnh icon trang bị hoặc ô rỗng
              Image.asset(
                spritePath,
                width: widget.size - 8,
                height: widget.size - 8,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),

              // Nếu ô trống và có loại ô, có thể hiển thị ký tự gợi ý mờ
              if (!hasItem && widget.slotType != null && _isHovered)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xAA000000),
                    alignment: Alignment.center,
                    child: Text(
                      widget.slotType!.vietnameseName,
                      textAlign: TextAlign.center,
                      style: GameTypography.pixel(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
