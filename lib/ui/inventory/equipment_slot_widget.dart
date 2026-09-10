import 'dart:math';
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
  final bool isHighlighted;
  final double size;

  const EquipmentSlotWidget({
    super.key,
    this.item,
    this.slotType,
    this.onTap,
    this.isSelected = false,
    this.isHighlighted = false,
    this.size = 38,
  });

  @override
  State<EquipmentSlotWidget> createState() => _EquipmentSlotWidgetState();
}

class _EquipmentSlotWidgetState extends State<EquipmentSlotWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.isHighlighted) {
      _initPulse();
    }
  }

  @override
  void didUpdateWidget(covariant EquipmentSlotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && _pulseController == null) {
      _initPulse();
    } else if (!widget.isHighlighted && _pulseController != null) {
      _pulseController?.dispose();
      _pulseController = null;
    }
  }

  void _initPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasItem = widget.item != null;
    final isInteractive = widget.onTap != null && hasItem;

    // Sprite icon đường dẫn
    final String spritePath = hasItem
        ? widget.item!.iconAssetPath
        : 'assets/o_trang_bi/o_trang_bi_rong.png';

    final isSlotActive = widget.isSelected || widget.isHighlighted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: widget.size,
              height: widget.size,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: widget.isHighlighted
                    ? const Color(0x66FFD54F)
                    : (widget.isSelected
                        ? const Color(0x66FFD54F)
                        : (_isHovered && hasItem ? const Color(0x44FFFFFF) : const Color(0x22000000))),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSlotActive
                      ? const Color(0xFFFFD54F)
                      : (_isHovered && hasItem
                          ? const Color(0xFFEEEEEE)
                          : const Color(0x448D6E63)),
                  width: isSlotActive ? 2 : 1,
                ),
                boxShadow: widget.isHighlighted
                    ? const [
                        BoxShadow(
                          color: Color(0xDDFFD54F),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
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

            // Mũi tên chỉ dẫn nhấp nhô cho ô trang bị được gợi ý
            if (widget.isHighlighted && _pulseController != null)
              AnimatedBuilder(
                animation: _pulseController!,
                builder: (context, child) {
                  final bounce = sin(_pulseController!.value * pi) * 3.0;
                  return Positioned(
                    top: -17 + bounce,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xEE2E7D32),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                          boxShadow: const [
                            BoxShadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_downward, color: Color(0xFFFFD54F), size: 10),
                            const SizedBox(width: 2),
                            Text(
                              'Kiếm',
                              style: GameTypography.pixel(
                                color: Colors.white,
                                fontSize: 10,
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
        ),
      ),
    );
  }
}
