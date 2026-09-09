import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/equipment_types.dart';
import '../../models/equipment.dart';

/// Widget hiển thị mô hình nhân vật và các lớp trang bị đang mặc (Idle animation)
class CharacterPreviewWidget extends StatefulWidget {
  final Map<EquipmentType, Equipment> equippedItems;
  final double scale;
  final double? containerSize;

  const CharacterPreviewWidget({
    super.key,
    required this.equippedItems,
    this.scale = 1.45,
    this.containerSize,
  });

  @override
  State<CharacterPreviewWidget> createState() => _CharacterPreviewWidgetState();
}

class _CharacterPreviewWidgetState extends State<CharacterPreviewWidget> {
  int _currentFrame = 0;
  Timer? _animTimer;

  @override
  void initState() {
    super.initState();
    _animTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) {
        setState(() {
          _currentFrame = (_currentFrame == 0) ? 1 : 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  Widget _buildFrame(String assetPath) {
    final frameSize = 32.0 * widget.scale;
    final sheetWidth = 64.0 * widget.scale;
    final sheetHeight = 32.0 * widget.scale;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(-_currentFrame * frameSize, 0),
          child: OverflowBox(
            minWidth: sheetWidth,
            maxWidth: sheetWidth,
            minHeight: sheetHeight,
            maxHeight: sheetHeight,
            alignment: Alignment.topLeft,
            child: Image.asset(
              assetPath,
              width: sheetWidth,
              height: sheetHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  String _getLayerPath(Equipment equipment) {
    return 'assets/trang_bi/dung_im/trang_bi_dung_im_phia_duoi/${equipment.itemIdentifier}_dung_im_phia_duoi.png';
  }

  @override
  Widget build(BuildContext context) {
    final size = 32.0 * widget.scale;
    final boxSize = widget.containerSize ?? (size + 8);

    final wings = widget.equippedItems[EquipmentType.wings];
    final sword = widget.equippedItems[EquipmentType.sword];
    final pants = widget.equippedItems[EquipmentType.pants];
    final shoes = widget.equippedItems[EquipmentType.shoes];
    final armor = widget.equippedItems[EquipmentType.armor];
    final necklace = widget.equippedItems[EquipmentType.necklace];
    final helmet = widget.equippedItems[EquipmentType.helmet];
    final glasses = widget.equippedItems[EquipmentType.glasses];

    return Container(
      width: boxSize,
      height: boxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x44FFFFFF), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Cánh (Dưới thân khi nhìn thẳng)
          if (wings != null) _buildFrame(_getLayerPath(wings)),

          // 2. Vũ khí (Dưới thân khi nhìn thẳng)
          if (sword != null) _buildFrame(_getLayerPath(sword)),

          // 3. Thân nhân vật chính
          _buildFrame('assets/nhan_vat_chinh/dung_im/nhan_vat_chinh_dung_im_phia_duoi.png'),

          // 4. Quần
          if (pants != null) _buildFrame(_getLayerPath(pants)),

          // 5. Giầy
          if (shoes != null) _buildFrame(_getLayerPath(shoes)),

          // 6. Giáp
          if (armor != null) _buildFrame(_getLayerPath(armor)),

          // 7. Dây chuyền
          if (necklace != null) _buildFrame(_getLayerPath(necklace)),

          // 8. Mũ
          if (helmet != null) _buildFrame(_getLayerPath(helmet)),

          // 9. Kính
          if (glasses != null) _buildFrame(_getLayerPath(glasses)),
        ],
      ),
    );
  }
}
