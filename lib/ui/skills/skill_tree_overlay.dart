import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/game_typography.dart';
import '../../game/components/player_component.dart';
import '../../game/survival_game.dart';
import '../../game/tutorial/tutorial_manager.dart';
import '../../models/skill.dart';
import '../inventory/nine_slice_box.dart';

/// Modal bảng cây kỹ năng và nâng cấp chiêu thức
class SkillTreeOverlay extends StatefulWidget {
  final SurvivalGame game;

  const SkillTreeOverlay({super.key, required this.game});

  @override
  State<SkillTreeOverlay> createState() => _SkillTreeOverlayState();
}

class _SkillTreeOverlayState extends State<SkillTreeOverlay>
    with SingleTickerProviderStateMixin {
  Skill _selectedSkill = SkillCatalog.danhThuong;
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

  @override
  Widget build(BuildContext context) {
    final skillPoints = _player.expManager.skillPoints;
    final playerLevel = _player.expManager.currentLevel;

    return Material(
      color: const Color(0xD8000000),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final modalWidth = (constraints.maxWidth * 0.94).clamp(360.0, 780.0);
          final modalHeight = (constraints.maxHeight * 0.94).clamp(330.0, 440.0);

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
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tiêu đề & Điểm kỹ năng
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
                                        'BẢNG KỸ NĂNG NHÂN VẬT',
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
                                          color: skillPoints > 0 ? const Color(0x88C62828) : const Color(0x66000000),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: skillPoints > 0 ? const Color(0xFFFF5252) : const Color(0x55FFD54F),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Text(
                                          'Điểm kỹ năng: $skillPoints',
                                          style: GameTypography.pixel(
                                            color: skillPoints > 0 ? Colors.white : const Color(0xFFE0E0E0),
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
                              // Khoảng đệm an toàn góc phải tránh nút [X]
                              const SizedBox(width: 36),
                            ],
                          ),

                          const SizedBox(height: 6),

                          if (widget.game.tutorialManager.currentStep == PrologueStep.exitSkillTree) ...[
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
                                      'Học kỹ năng thành công! Nhấn nút [X] ở góc phải để tiếp tục hướng dẫn!',
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
                          ] else if (skillPoints > 0) ...[
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
                                      widget.game.tutorialManager.currentStep == PrologueStep.upgradeSkill
                                          ? 'Mũi tên chỉ dẫn: Chọn kỹ năng và nhấn "Học Kỹ Năng / Nâng Cấp"!'
                                          : 'Gợi ý: Chọn kỹ năng và nhấn "Học Kỹ Năng" để mở khóa chiêu thức chiến đấu mới!',
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

                          // Thân modal: 2 cột (Danh sách 4 kỹ năng bên trái + Khung soi chi tiết bên phải)
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Cột trái: 4 kỹ năng
                                SizedBox(
                                  width: 220,
                                  child: ListView.separated(
                                    itemCount: SkillCatalog.all.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                                    itemBuilder: (context, index) {
                                      final skill = SkillCatalog.all[index];
                                      final currentLevel = _player.getSkillLevel(skill.id);
                                      final isLocked = playerLevel < skill.requiredCharacterLevel;
                                      final isSelected = _selectedSkill.id == skill.id;

                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _selectedSkill = skill),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 100),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0x66FFD54F)
                                                  : const Color(0x44000000),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFFFFD54F)
                                                    : (isLocked
                                                        ? const Color(0x44EF5350)
                                                        : const Color(0x448D6E63)),
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // Icon kỹ năng
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0x44000000),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(
                                                      color: isLocked
                                                          ? const Color(0x88EF5350)
                                                          : const Color(0x88FFD54F),
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    skill.iconAssetPath,
                                                    fit: BoxFit.contain,
                                                    filterQuality: FilterQuality.none,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // Thông tin kỹ năng tóm tắt
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        skill.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GameTypography.pixel(
                                                          color: isLocked ? const Color(0xFFB0BEC5) : Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Row(
                                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                         children: [
                                                           Text(
                                                             currentLevel == 0
                                                                 ? 'Chưa học (Cấp 0)'
                                                                 : 'Cấp $currentLevel / ${skill.maxSkillLevel}',
                                                             style: GameTypography.pixel(
                                                               color: currentLevel == 0
                                                                   ? const Color(0xFFB0BEC5)
                                                                   : const Color(0xFFFFD54F),
                                                               fontSize: 12,
                                                               fontWeight: FontWeight.bold,
                                                             ),
                                                           ),
                                                           if (isLocked)
                                                             Text(
                                                               'Lv.${skill.requiredCharacterLevel}',
                                                               style: GameTypography.pixel(
                                                                 color: const Color(0xFFEF5350),
                                                                 fontSize: 11,
                                                                 fontWeight: FontWeight.bold,
                                                               ),
                                                             )
                                                           else if (currentLevel == 0)
                                                             Text(
                                                               'Có thể học',
                                                               style: GameTypography.pixel(
                                                                 color: const Color(0xFFFFD54F),
                                                                 fontSize: 11,
                                                                 fontWeight: FontWeight.bold,
                                                               ),
                                                             )
                                                           else
                                                             Text(
                                                               'Đã mở',
                                                               style: GameTypography.pixel(
                                                                 color: const Color(0xFF81C784),
                                                                 fontSize: 11,
                                                               ),
                                                             ),
                                                         ],
                                                       ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Cột phải: Khung soi chiêu chi tiết 9-slice
                                Expanded(
                                  child: _buildSkillDetailPane(playerLevel, skillPoints),
                                ),
                              ],
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
                        onTap: () => widget.game.closeSkillTree(),
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
                  // Mũi tên nhấp nhô trỏ thẳng vào nút Thoát [X] khi đã nâng kỹ năng xong
                  if (widget.game.tutorialManager.currentStep == PrologueStep.exitSkillTree)
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
                                    'Bấm [X] để tiếp tục!',
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

  Widget _buildSkillDetailPane(int playerLevel, int skillPoints) {
    final skill = _selectedSkill;
    final currentLevel = _player.getSkillLevel(skill.id);
    final isMax = currentLevel >= skill.maxSkillLevel;
    final isLocked = playerLevel < skill.requiredCharacterLevel;
    final canUpgrade = _player.canUpgradeSkill(skill);

    final currentData = skill.getDataForLevel(currentLevel == 0 ? 1 : currentLevel);
    final nextData = isMax ? null : skill.getDataForLevel(currentLevel + 1);

    return NineSliceBox.inspectPanel(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tiêu đề chiêu đang soi
          Row(
            children: [
              Image.asset(
                skill.iconAssetPath,
                width: 26,
                height: 26,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLevel == 0
                          ? '${skill.name} (Chưa học - Tối đa Cấp ${skill.maxSkillLevel})'
                          : '${skill.name} (Cấp $currentLevel / ${skill.maxSkillLevel})',
                      style: GameTypography.pixel(
                        color: const Color(0xFFFFD54F),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        shadows: const [Shadow(blurRadius: 1, color: Colors.black)],
                      ),
                    ),
                    if (isLocked)
                      Text(
                        'Chưa mở khóa - Yêu cầu Level ${skill.requiredCharacterLevel}',
                        style: GameTypography.pixel(
                          color: const Color(0xFFFF5252),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Vùng cuộn thông tin (Mô tả chi tiết + Bảng so sánh Cấp hiện tại vs Cấp kế tiếp)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x55000000),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mô tả kỹ năng
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x33000000),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0x22FFFFFF)),
                      ),
                      child: Text(
                        skill.description,
                        style: GameTypography.pixel(
                          color: const Color(0xFFE0E0E0),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'SO SÁNH CHỈ SỐ KỸ NĂNG:',
                      style: GameTypography.pixel(
                        color: const Color(0xFF81D4FA),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Hồi chiêu
                    _buildStatCompareRow(
                      label: 'Hồi chiêu',
                      currentVal: '${currentData.cooldown}s',
                      nextVal: nextData != null ? '${nextData.cooldown}s' : null,
                    ),

                    // Năng lượng
                    _buildStatCompareRow(
                      label: 'Tiêu hao MP',
                      currentVal: '${currentData.manaCost.toInt()} MP',
                      nextVal: nextData != null ? '${nextData.manaCost.toInt()} MP' : null,
                    ),

                    // Sát thương
                    _buildStatCompareRow(
                      label: 'Sát thương',
                      currentVal: '${(currentData.powerMultiplier * 100).toInt()}% ATK + ${currentData.flatBonusDamage.toInt()}',
                      nextVal: nextData != null
                          ? '${(nextData.powerMultiplier * 100).toInt()}% ATK + ${nextData.flatBonusDamage.toInt()}'
                          : null,
                    ),

                    // Đẩy lùi
                    if (currentData.knockbackDistance > 0 || (nextData?.knockbackDistance ?? 0) > 0)
                      _buildStatCompareRow(
                        label: 'Đẩy lùi',
                        currentVal: '${currentData.knockbackDistance.toInt()}px',
                        nextVal: nextData != null ? '${nextData.knockbackDistance.toInt()}px' : null,
                      ),

                    // Xuyên giáp
                    if (currentData.bonusArmorPenetration > 0 || (nextData?.bonusArmorPenetration ?? 0) > 0)
                      _buildStatCompareRow(
                        label: 'Xuyên giáp',
                        currentVal: '+${currentData.bonusArmorPenetration.toInt()}',
                        nextVal: nextData != null ? '+${nextData.bonusArmorPenetration.toInt()}' : null,
                      ),

                    // Làm chậm
                    if (currentData.slowPercent > 0 || (nextData?.slowPercent ?? 0) > 0)
                      _buildStatCompareRow(
                        label: 'Làm chậm',
                        currentVal: '${(currentData.slowPercent * 100).toInt()}% (${currentData.slowDuration}s)',
                        nextVal: nextData != null
                            ? '${(nextData.slowPercent * 100).toInt()}% (${nextData.slowDuration}s)'
                            : null,
                      ),

                    // Thiêu đốt
                    if (currentData.burnPercent > 0 || (nextData?.burnPercent ?? 0) > 0)
                      _buildStatCompareRow(
                        label: 'Thiêu đốt',
                        currentVal: '${(currentData.burnPercent * 100).toInt()}%/s (${currentData.burnDuration}s)',
                        nextVal: nextData != null
                            ? '${(nextData.burnPercent * 100).toInt()}%/s (${nextData.burnDuration}s)'
                            : null,
                      ),

                    // Choáng
                    if (currentData.stunDuration > 0 || (nextData?.stunDuration ?? 0) > 0)
                      _buildStatCompareRow(
                        label: 'Gây choáng',
                        currentVal: '${currentData.stunDuration}s',
                        nextVal: nextData != null ? '${nextData.stunDuration}s' : null,
                      ),

                    // Buff giáp & Kháng chí mạng
                    if (currentData.buffArmor > 0 || (nextData?.buffArmor ?? 0) > 0)
                      _buildStatCompareRow(
                        label: 'Buff Hộ thể',
                        currentVal: '+${currentData.buffArmor.toInt()} Giáp, +${currentData.buffCritResistance.toInt()} Kháng crit',
                        nextVal: nextData != null
                            ? '+${nextData.buffArmor.toInt()} Giáp, +${nextData.buffCritResistance.toInt()} Kháng crit'
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Nút Nâng Cấp
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.game.tutorialManager.currentStep == PrologueStep.upgradeSkill && canUpgrade)
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final bounce = sin(_bounceController.value * pi) * 2.5;
                      return Transform.translate(
                        offset: Offset(0, bounce),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xEE2E7D32),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                            boxShadow: const [
                              BoxShadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_downward, color: Color(0xFFFFD54F), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Bấm vào đây để nâng cấp!',
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
                isMax
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x66FFD54F),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Text(
                          'ĐÃ ĐẠT CẤP TỐI ĐA (MAX LEVEL)',
                          style: GameTypography.pixel(
                            color: const Color(0xFFFFD54F),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : NineSliceButton(
                        text: isLocked
                            ? 'Cần Level ${skill.requiredCharacterLevel}'
                            : (currentLevel == 0 ? 'Học Kỹ Năng (1 Điểm)' : 'Nâng Cấp (1 Điểm)'),
                        width: 175,
                        height: 30,
                        enabled: canUpgrade,
                        onPressed: canUpgrade
                            ? () {
                                _player.upgradeSkill(skill);
                                widget.game.tutorialManager.onSkillUpgraded();
                                setState(() {});
                              }
                            : null,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCompareRow({
    required String label,
    required String currentVal,
    String? nextVal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              '$label:',
              style: GameTypography.pixel(
                color: const Color(0xFFB0BEC5),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  currentVal,
                  style: GameTypography.pixel(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (nextVal != null && nextVal != currentVal) ...[
                  Text(
                    ' -> ',
                    style: GameTypography.pixel(
                      color: const Color(0xFFFFD54F),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    nextVal,
                    style: GameTypography.pixel(
                      color: const Color(0xFF81C784),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(blurRadius: 1, color: Colors.black)],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
