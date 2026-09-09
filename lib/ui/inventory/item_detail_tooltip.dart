import 'package:flutter/material.dart';
import '../../constants/equipment_types.dart';
import '../../core/game_typography.dart';
import '../../models/equipment.dart';
import 'nine_slice_box.dart';

/// Hộp thoại/Popup soi đồ chi tiết 9-Slice (khung_soi_do_9slice_32x32.png)
class ItemDetailTooltip extends StatelessWidget {
  final Equipment item;
  final bool isEquipped;
  final int playerLevel;
  final VoidCallback? onEquip;
  final VoidCallback? onUnequip;
  final VoidCallback? onSell;
  final VoidCallback? onClose;

  const ItemDetailTooltip({
    super.key,
    required this.item,
    required this.isEquipped,
    required this.playerLevel,
    this.onEquip,
    this.onUnequip,
    this.onSell,
    this.onClose,
  });

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
    final s = item.stats;

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
    final isLevelMet = playerLevel >= item.requiredLevel;
    final statList = _buildStatBonusList();
    final nameColor = _getRarityColor(item.material);

    return NineSliceBox.inspectPanel(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tiêu đề: Icon + Tên trang bị + Nút Đóng
          Row(
            children: [
              Image.asset(
                item.iconAssetPath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
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
                      'Loại: ${item.type.vietnameseName} (${item.material.vietnameseName})',
                      style: GameTypography.pixel(
                        color: const Color(0xFFAAAAAA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white70),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 0.5, color: Color(0x33FFFFFF)),
          const SizedBox(height: 6),

          // 2. Cấp độ yêu cầu
          Row(
            children: [
              Text(
                'Yêu cầu: ',
                style: GameTypography.pixel(color: const Color(0xFFBBBBBB), fontSize: 13),
              ),
              Text(
                'Cấp ${item.requiredLevel}',
                style: GameTypography.pixel(
                  color: isLevelMet ? const Color(0xFF81C784) : const Color(0xFFE57373),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isLevelMet)
                Text(
                  ' (Chưa đủ!)',
                  style: GameTypography.pixel(color: const Color(0xFFE57373), fontSize: 12),
                ),
            ],
          ),

          const SizedBox(height: 4),

          // 3. Danh sách thuộc tính cộng thêm màu xanh lá
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

          // 4. Giá bán
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
                '${item.sellPrice}',
                style: GameTypography.pixel(
                  color: const Color(0xFFFFD54F),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 5. Nút bấm tương tác 9-Slice
          if (isEquipped) ...[
            NineSliceButton(
              text: 'Gỡ Đồ',
              height: 28,
              fontSize: 14,
              onPressed: onUnequip,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: NineSliceButton(
                    text: 'Trang Bị',
                    height: 28,
                    fontSize: 14,
                    enabled: isLevelMet,
                    onPressed: isLevelMet ? onEquip : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NineSliceButton(
                    text: 'Bán',
                    height: 28,
                    fontSize: 14,
                    textColor: const Color(0xFF5D4037),
                    onPressed: onSell,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
