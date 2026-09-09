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
class StatsListWidget extends StatefulWidget {
  final CharacterStats stats;
  final double currentHp;
  final double currentMp;

  const StatsListWidget({
    super.key,
    required this.stats,
    required this.currentHp,
    required this.currentMp,
  });

  @override
  State<StatsListWidget> createState() => _StatsListWidgetState();
}

class _StatsListWidgetState extends State<StatsListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<StatEntry> get _statEntries => [
        StatEntry(
          label: 'Máu (HP)',
          value: '${widget.currentHp.toInt()} / ${widget.stats.maxHp.toInt()}',
          color: const Color(0xFFFF5252),
          tooltip: 'Lượng sinh mệnh hiện tại và tối đa của nhân vật',
        ),
        StatEntry(
          label: 'Hồi máu',
          value: '+${widget.stats.hpRegen.toStringAsFixed(1)} /s',
          color: const Color(0xFFFF7043),
          tooltip: 'Tốc độ hồi phục máu mỗi giây',
        ),
        StatEntry(
          label: 'Năng lượng (MP)',
          value: '${widget.currentMp.toInt()} / ${widget.stats.maxMp.toInt()}',
          color: const Color(0xFF40C4FF),
          tooltip: 'Năng lượng dùng để thi triển các chiêu thức kỹ năng',
        ),
        StatEntry(
          label: 'Hồi năng lượng',
          value: '+${widget.stats.mpRegen.toStringAsFixed(1)} /s',
          color: const Color(0xFF80D8FF),
          tooltip: 'Tốc độ hồi phục năng lượng mỗi giây',
        ),
        StatEntry(
          label: 'Sức mạnh tấn công',
          value: '${widget.stats.attackPower.toInt()}',
          color: const Color(0xFFFFD54F),
          tooltip: 'Sát thương cơ bản gây ra khi đánh thường và dùng kỹ năng',
        ),
        StatEntry(
          label: 'Điểm chí mạng',
          value: '${widget.stats.critDamage.toInt()}',
          color: const Color(0xFFFFE082),
          tooltip: 'Càng cao thì sát thương khi bạo kích càng lớn',
        ),
        StatEntry(
          label: 'Giáp phòng thủ',
          value: '${widget.stats.defense.toInt()}',
          color: const Color(0xFF69F0AE),
          tooltip: 'Giảm trực tiếp lượng sát thương nhận vào từ quái',
        ),
        StatEntry(
          label: 'Xuyên giáp',
          value: '${widget.stats.armorPenetration.toInt()}',
          color: const Color(0xFFE040FB),
          tooltip: 'Bỏ qua một phần giáp phòng thủ của kẻ địch',
        ),
        StatEntry(
          label: 'Kháng chí mạng',
          value: '${widget.stats.critResistance.toInt()}',
          color: const Color(0xFF64FFDA),
          tooltip: 'Giảm sát thương khi bị kẻ địch đánh chí mạng',
        ),
        StatEntry(
          label: 'Né đòn',
          value: '${widget.stats.dodge.toStringAsFixed(1)}%',
          color: const Color(0xFF18FFFF),
          tooltip: 'Tỉ lệ phần trăm né tránh hoàn toàn đòn đánh (MISS)',
        ),
        StatEntry(
          label: 'Hút máu',
          value: '${widget.stats.lifeSteal.toStringAsFixed(1)}%',
          color: const Color(0xFFFF5252),
          tooltip: 'Hồi lại lượng máu theo phần trăm sát thương gây ra',
        ),
        StatEntry(
          label: 'Hút năng lượng',
          value: '${widget.stats.manaSteal.toStringAsFixed(1)}%',
          color: const Color(0xFF448AFF),
          tooltip: 'Hồi lại năng lượng khi gây sát thương lên kẻ địch',
        ),
        StatEntry(
          label: 'Phản sát thương',
          value: '${widget.stats.reflectDamage.toStringAsFixed(1)}%',
          color: const Color(0xFFFF6E40),
          tooltip: 'Phản hồi lại phần trăm sát thương nhận phải lên quái',
        ),
        StatEntry(
          label: 'Chỉ số Ngầu',
          value: '+${widget.stats.coolness.toStringAsFixed(1)}%',
          color: const Color(0xFFFFD700),
          tooltip: '1 điểm Ngầu tăng +1% cho toàn bộ các thuộc tính khác!',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final entries = _statEntries;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x66000000),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x44FFFFFF), width: 1),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 4,
        radius: const Radius.circular(2),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Divider(
            height: 4,
            thickness: 0.5,
            color: Color(0x22FFFFFF),
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                children: [
                  // Chấm tròn phân loại
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: entry.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: entry.color.withAlpha(120), blurRadius: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tên chỉ số với độ tương phản cao sắc nét
                  Expanded(
                    child: Text(
                      entry.label,
                      style: GameTypography.pixel(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                        ],
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
                        Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
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
