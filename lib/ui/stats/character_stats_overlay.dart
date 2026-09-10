import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/game_typography.dart';
import '../../game/components/player_component.dart';
import '../../game/survival_game.dart';
import '../../game/tutorial/tutorial_manager.dart';
import '../../models/attribute_type.dart';
import '../inventory/nine_slice_box.dart';

/// Modal bảng nâng cấp Điểm Tiềm Năng (Attribute Points) cho 6 chỉ số nhân vật
class CharacterStatsOverlay extends StatefulWidget {
  final SurvivalGame game;

  const CharacterStatsOverlay({super.key, required this.game});

  @override
  State<CharacterStatsOverlay> createState() => _CharacterStatsOverlayState();
}

class _CharacterStatsOverlayState extends State<CharacterStatsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  PlayerComponent get _player => widget.game.player;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _player.inventoryNotifier.addListener(_onStateChanged);
    widget.game.tutorialManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    widget.game.tutorialManager.removeListener(_onStateChanged);
    _player.inventoryNotifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  double _getStatValue(AttributeType type) {
    switch (type) {
      case AttributeType.maxHp:
        return _player.stats.maxHp;
      case AttributeType.hpRegen:
        return _player.stats.hpRegen;
      case AttributeType.maxMp:
        return _player.stats.maxMp;
      case AttributeType.mpRegen:
        return _player.stats.mpRegen;
      case AttributeType.attackPower:
        return _player.stats.attackPower;
      case AttributeType.defense:
        return _player.stats.defense;
    }
  }

  Color _getStatColor(AttributeType type) {
    switch (type) {
      case AttributeType.maxHp:
        return const Color(0xFFEF5350);
      case AttributeType.hpRegen:
        return const Color(0xFFFF7043);
      case AttributeType.maxMp:
        return const Color(0xFF42A5F5);
      case AttributeType.mpRegen:
        return const Color(0xFF26C6DA);
      case AttributeType.attackPower:
        return const Color(0xFFFFCA28);
      case AttributeType.defense:
        return const Color(0xFF66BB6A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = _player.attributePoints;

    return Material(
      color: const Color(0xD8000000),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final modalWidth = (constraints.maxWidth * 0.92).clamp(320.0, 560.0);
          final modalHeight = (constraints.maxHeight * 0.92).clamp(320.0, 430.0);

          return Center(
            child: SizedBox(
              width: modalWidth,
              height: modalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Khung chính 9-slice
                  Positioned.fill(
                    child: NineSliceBox.largePanel(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tiêu đề & Điểm tiềm năng
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
                                        'THUỘC TÍNH NHÂN VẬT',
                                        style: GameTypography.pixel(
                                          color: const Color(0xFFFFD54F),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: points > 0 ? const Color(0x88C62828) : const Color(0x66000000),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: points > 0 ? const Color(0xFFFF5252) : const Color(0x55FFD54F),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Text(
                                          'Điểm tiềm năng: $points',
                                          style: GameTypography.pixel(
                                            color: points > 0 ? Colors.white : const Color(0xFFE0E0E0),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            shadows: const [
                                              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Khoảng trống an toàn bên phải cho nút [X]
                              const SizedBox(width: 36),
                            ],
                          ),

                          const SizedBox(height: 6),

                          if (widget.game.tutorialManager.currentStep == PrologueStep.exitStats) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x3381C784),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF81C784), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF81C784)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Cộng điểm thành công! Nhấn nút [X] ở góc phải để hoàn thành tân thủ!',
                                      style: GameTypography.pixel(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (points > 0) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x33FFD54F),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0x88FFD54F), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFFFFD54F)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.game.tutorialManager.currentStep == PrologueStep.upgradeStats
                                          ? 'Mũi tên chỉ dẫn: Nhấn các nút [+] màu vàng để gia tăng Máu, Tấn Công hoặc Giáp!'
                                          : 'Gợi ý: Nhấn nút [+] để cộng điểm vào Máu (sinh tồn), Tấn Công (sát thương) hoặc Giáp (giảm sát thương nhận)!',
                                      style: GameTypography.pixel(
                                        color: const Color(0xFFFFF9C4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Danh sách 6 dòng thuộc tính
                          Expanded(
                            child: ListView.separated(
                              physics: const ClampingScrollPhysics(),
                              itemCount: AttributeType.values.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final attr = AttributeType.values[index];
                                final currentVal = _getStatValue(attr);
                                final statColor = _getStatColor(attr);
                                final canAdd = points > 0;

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x55000000),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0x33FFFFFF), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      // Chấm màu biểu thị thuộc tính
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: statColor.withValues(alpha: 0.8), blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Tên thuộc tính
                                      Expanded(
                                        child: Text(
                                          attr.displayName,
                                          style: GameTypography.pixel(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            shadows: const [
                                              Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Giá trị hiện tại : [Giá trị] (+[Định mức])
                                      Text(
                                        ': ${currentVal.toInt()} ',
                                        style: GameTypography.pixel(
                                          color: statColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '(${attr.increaseText})',
                                        style: GameTypography.pixel(
                                          color: const Color(0xFF81C784),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // Nút cộng điểm tiềm năng
                                      MouseRegion(
                                        cursor: canAdd ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                        child: GestureDetector(
                                          onTap: canAdd
                                              ? () {
                                                  _player.upgradeAttribute(attr);
                                                  widget.game.tutorialManager.onStatUpgraded();
                                                  setState(() {});
                                                }
                                              : null,
                                          child: Opacity(
                                            opacity: canAdd ? 1.0 : 0.5,
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: canAdd
                                                    ? const [
                                                        BoxShadow(
                                                          color: Color(0x66FFD54F),
                                                          blurRadius: 4,
                                                          spreadRadius: 1,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Image.asset(
                                                'assets/nut_bam/nut_cong_thuoc_tinh_24x24.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Ghi chú cơ chế
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x22FFFFFF)),
                            ),
                            child: Text(
                              '* Mỗi cấp nhận +3 Điểm Tiềm Năng. Chỉ số được nhân thêm với hệ số Ngầu của nhân vật.',
                              style: GameTypography.pixel(
                                color: const Color(0xFFBDBDBD),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Nút Đóng "X" góc trên bên phải khung
                  Positioned(
                    top: 6,
                    right: 8,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => widget.game.closeStats(),
                        child: Container(
                          width: 28,
                          height: 28,
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
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Mũi tên nhấp nhô trỏ thẳng vào nút Thoát [X] khi đã cộng điểm xong
                  if (widget.game.tutorialManager.currentStep == PrologueStep.exitStats)
                    Positioned(
                      top: 38,
                      right: 8,
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
                                    'Bấm [X] để hoàn thành!',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
