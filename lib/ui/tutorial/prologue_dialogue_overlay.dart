import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/game_typography.dart';
import '../../game/survival_game.dart';
import '../inventory/nine_slice_box.dart';

/// Modal hộp thoại cốt truyện Trưởng Làng với hiệu ứng chữ chạy (Typewriter Effect)
class PrologueDialogueOverlay extends StatefulWidget {
  final SurvivalGame game;

  const PrologueDialogueOverlay({super.key, required this.game});

  @override
  State<PrologueDialogueOverlay> createState() => _PrologueDialogueOverlayState();
}

class _PrologueDialogueOverlayState extends State<PrologueDialogueOverlay>
    with SingleTickerProviderStateMixin {
  final List<String> _dialogueLines = [
    'Chào dũng sĩ trẻ! Rừng thiêng đang bị thế lực hắc ám xâm chiếm...',
    'Hãy cẩn thận! Lũ quái vật Slime đầu tiên đã xuất hiện ở phía trước!',
  ];

  int _currentLineIndex = 0;
  String _displayedText = '';
  bool _isTyping = false;
  Timer? _typewriterTimer;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _startTypewriter();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTypewriter() {
    _typewriterTimer?.cancel();
    final fullText = _dialogueLines[_currentLineIndex];
    _displayedText = '';
    _isTyping = true;
    int charIndex = 0;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (charIndex < fullText.length) {
        setState(() {
          _displayedText += fullText[charIndex];
          charIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  void _handleTap() {
    if (_isTyping) {
      // Nếu đang gõ dở: Hiện ngay lập tức toàn bộ câu
      _typewriterTimer?.cancel();
      setState(() {
        _displayedText = _dialogueLines[_currentLineIndex];
        _isTyping = false;
      });
    } else {
      // Nếu câu đã gõ xong: Chuyển sang câu tiếp theo hoặc kết thúc
      if (_currentLineIndex < _dialogueLines.length - 1) {
        setState(() {
          _currentLineIndex++;
        });
        _startTypewriter();
      } else {
        _completeDialogue();
      }
    }
  }

  Future<void> _completeDialogue() async {
    await _fadeController.reverse();
    if (mounted) {
      widget.game.overlays.remove('PrologueDialogueOverlay');
      widget.game.tutorialManager.onDialogueFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Stack(
            children: [
              // Hộp thoại đặt ở cạnh dưới màn hình, chỉ nhận sự kiện chạm trên chính hộp thoại
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boxWidth = (constraints.maxWidth * 0.9).clamp(320.0, 720.0);

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleTap,
                        child: SizedBox(
                          width: boxWidth,
                          height: 135,
                          child: NineSliceBox.largePanel(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Ảnh chân dung Trưởng Làng
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0x66000000),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFFFD54F),
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black54, blurRadius: 4),
                                    ],
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: Image.asset(
                                        'assets/npc/truong_lang_dung_im_noi_chuyen.png',
                                        fit: BoxFit.none,
                                        alignment: Alignment.topLeft,
                                        filterQuality: FilterQuality.none,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.person,
                                          color: Color(0xFFFFD54F),
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                          const SizedBox(width: 14),

                          // Nội dung hội thoại
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Tên NPC
                                Text(
                                  'TRƯỞNG LÀNG',
                                  style: GameTypography.pixel(
                                    color: const Color(0xFFFFD54F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // Câu thoại chữ gõ dần
                                Expanded(
                                  child: Text(
                                    _displayedText,
                                    style: GameTypography.pixel(
                                      color: Colors.white,
                                      fontSize: 15,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 1,
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Gợi ý bấm tiếp tục
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    _isTyping ? 'Nhấp để hiện nhanh ▶' : 'Nhấp để tiếp tục ▶',
                                    style: GameTypography.pixel(
                                      color: const Color(0xFF81D4FA),
                                      fontSize: 12,
                                    ),
                                  ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
