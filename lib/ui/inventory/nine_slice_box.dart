import 'package:flutter/material.dart';
import '../../core/game_typography.dart';

/// Widget hỗ trợ khung 9-Slice cho giao diện Pixel Art
class NineSliceBox extends StatelessWidget {
  final String imagePath;
  final Rect centerSlice;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  const NineSliceBox({
    super.key,
    required this.imagePath,
    required this.centerSlice,
    this.child,
    this.padding = const EdgeInsets.all(12),
    this.width,
    this.height,
  });

  /// Khung bảng lớn 9-slice (48x48)
  factory NineSliceBox.largePanel({
    Key? key,
    Widget? child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double? width,
    double? height,
  }) {
    return NineSliceBox(
      key: key,
      imagePath: 'assets/hud/khung_bang_lon_9slice_48x48.png',
      centerSlice: const Rect.fromLTRB(16, 16, 32, 32),
      padding: padding,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Khung soi đồ 9-slice (32x32)
  factory NineSliceBox.inspectPanel({
    Key? key,
    Widget? child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
    double? width,
    double? height,
  }) {
    return NineSliceBox(
      key: key,
      imagePath: 'assets/hud/khung_soi_do_9slice_32x32.png',
      centerSlice: const Rect.fromLTRB(10, 8, 22, 24),
      padding: padding,
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            centerSlice: centerSlice,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
          if (child != null)
            Padding(
              padding: padding,
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Nút bấm 9-Slice co giãn tự động theo độ dài chữ
class NineSliceButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double? width;
  final double height;
  final Color textColor;
  final double fontSize;

  const NineSliceButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.width,
    this.height = 32,
    this.textColor = const Color(0xFF3E2723),
    this.fontSize = 15,
  });

  @override
  State<NineSliceButton> createState() => _NineSliceButtonState();
}

class _NineSliceButtonState extends State<NineSliceButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.enabled && widget.onPressed != null;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: isClickable ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isClickable
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isClickable ? () => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 60),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/nut_bam/nut_bam_9slice_48x24.png',
                      centerSlice: const Rect.fromLTRB(10, 8, 38, 16),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: GameTypography.pixel(
                        color: widget.textColor,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            blurRadius: 1,
                            color: Color(0x66FFFFFF),
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
