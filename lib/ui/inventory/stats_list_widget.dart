import 'package:flutter/material.dart';
import '../../core/game_typography.dart';
import '../../models/character_stats.dart';

/// Item mô tả một dòng chỉ số thuộc tính
class StatEntry {
  final String label;
  final String value;
  final Color color;
  final String? tooltip;

  const StatEntry({
    required this.label,
    required this.value,
    required this.color,
    this.tooltip,
  });
}

/// Danh sách cuộn hiển thị đầy đủ 14 chỉ số thuộc tính nhân vật
class StatsListWidget extends StatelessWidget {
  final CharacterStats stats;
  final double currentHp;
  final double currentMp;

  const StatsListWidget({
    super.key,
    required this.stats,
    required this.currentHp,
    required this.currentMp,
  });

  List<StatEntry> get _statEntries => [
        StatEntry(
          label: 'Máu (HP)',
          value: '${currentHp.toInt()} / ${stats.maxHp.toInt()}',
          color: const Color(0xFFEF5350),
          tooltip: 'Lượng sinh mệnh hiện tại và tối đa của nhân vật',
        ),
        StatEntry(
          label: 'Hồi máu',
          value: '+${stats.hpRegen.toStringAsFixed(1)} /s',
          color: const Color(0xFFFF7043),
          tooltip: 'Tốc độ hồi phục máu mỗi giây',
        ),
        StatEntry(
          label: 'Năng lượng (MP)',
          value: '${currentMp.toInt()} / ${stats.maxMp.toInt()}',
          color: const Color(0xFF42A5F5),
          tooltip: 'Năng lượng dùng để thi triển các chiêu thức kỹ năng',
        ),
        StatEntry(
          label: 'Hồi năng lượng',
          value: '+${stats.mpRegen.toStringAsFixed(1)} /s',
          color: const Color(0xFF29B6F6),
          tooltip: 'Tốc độ hồi phục năng lượng mỗi giây',
        ),
        StatEntry(
          label: 'Sức mạnh tấn công',
          value: '${stats.attackPower.toInt()}',
          color: const Color(0xFFFFA726),
          tooltip: 'Sát thương cơ bản gây ra khi đánh thường và dùng kỹ năng',
        ),
        StatEntry(
          label: 'Điểm chí mạng',
          value: '${stats.critDamage.toInt()}',
          color: const Color(0xFFFFCA28),
          tooltip: 'Càng cao thì sát thương khi bạo kích càng lớn',
        ),
        StatEntry(
          label: 'Giáp phòng thủ',
          value: '${stats.defense.toInt()}',
          color: const Color(0xFF66BB6A),
          tooltip: 'Giảm trực tiếp lượng sát thương nhận vào từ quái',
        ),
        StatEntry(
          label: 'Xuyên giáp',
          value: '${stats.armorPenetration.toInt()}',
          color: const Color(0xFFAB47BC),
          tooltip: 'Bỏ qua một phần giáp phòng thủ của kẻ địch',
        ),
        StatEntry(
          label: 'Kháng chí mạng',
          value: '${stats.critResistance.toInt()}',
          color: const Color(0xFF26A69A),
          tooltip: 'Giảm sát thương khi bị kẻ địch đánh chí mạng',
        ),
        StatEntry(
          label: 'Né đòn',
          value: '${stats.dodge.toStringAsFixed(1)}%',
          color: const Color(0xFF26C6DA),
          tooltip: 'Tỉ lệ phần trăm né tránh hoàn toàn đòn đánh (MISS)',
        ),
        StatEntry(
          label: 'Hút máu',
          value: '${stats.lifeSteal.toStringAsFixed(1)}%',
          color: const Color(0xFFFF5252),
          tooltip: 'Hồi lại lượng máu theo phần trăm sát thương gây ra',
        ),
        StatEntry(
          label: 'Hút năng lượng',
          value: '${stats.manaSteal.toStringAsFixed(1)}%',
          color: const Color(0xFF448AFF),
          tooltip: 'Hồi lại năng lượng khi gây sát thương lên kẻ địch',
        ),
        StatEntry(
          label: 'Phản sát thương',
          value: '${stats.reflectDamage.toStringAsFixed(1)}%',
          color: const Color(0xFFFF8A65),
          tooltip: 'Phản hồi lại phần trăm sát thương nhận phải lên quái',
        ),
        StatEntry(
          label: 'Chỉ số Ngầu',
          value: '+${stats.coolness.toStringAsFixed(1)}%',
          color: const Color(0xFFFFD700),
          tooltip: '1 điểm Ngầu tăng +1% cho toàn bộ các thuộc tính khác!',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final entries = _statEntries;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 4,
        radius: const Radius.circular(2),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Divider(
            height: 6,
            thickness: 0.5,
            color: Color(0x15FFFFFF),
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  // Chấm tròn phân loại
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: entry.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tên chỉ số
                  Expanded(
                    child: Text(
                      entry.label,
                      style: GameTypography.pixel(
                        color: const Color(0xFFCCCCCC),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Giá trị chỉ số
                  Text(
                    entry.value,
                    style: GameTypography.pixel(
                      color: entry.color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
