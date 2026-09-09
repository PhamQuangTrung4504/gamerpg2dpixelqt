import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/game_typography.dart';

/// Hiệu ứng số nhảy (Floating Damage/Heal/Info Text) bay lên và mờ dần
class FloatingTextComponent extends PositionComponent {
  final String text;
  final Color baseColor;
  final double duration;
  final double fontSize;
  double _elapsed = 0.0;

  late final TextComponent _textComponent;

  FloatingTextComponent({
    required this.text,
    required Vector2 position,
    this.baseColor = Colors.red,
    this.duration = 0.75,
    this.fontSize = 12.0,
  }) : super(
          position: position,
          anchor: Anchor.center,
          priority: 300,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _textComponent = TextComponent(
      text: text,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GameTypography.pixel(
          color: baseColor,
          fontSize: fontSize + 2, // Tăng nhẹ 2px để nét font pixel hiển thị sắc nét
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(-1, -1)),
          ],
        ),
      ),
    );
    await add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // Bay dần lên trên
    position.y -= 32.0 * dt;

    // Tính toán độ mờ dần (Fade out)
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = ((1.0 - progress) * 255).round().clamp(0, 255);

    _textComponent.textRenderer = TextPaint(
      style: GameTypography.pixel(
        color: baseColor.withAlpha(alpha),
        fontSize: fontSize + 2,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.black.withAlpha(alpha),
            offset: const Offset(1, 1),
          ),
          Shadow(
            blurRadius: 2,
            color: Colors.black.withAlpha(alpha),
            offset: const Offset(-1, -1),
          ),
        ],
      ),
    );

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  // --- Factory Helpers ---

  /// Sát thương thông thường (Màu đỏ) hoặc Chí mạng (Màu vàng đậm, phóng to)
  static FloatingTextComponent damage({
    required Vector2 position,
    required double amount,
    bool isCrit = false,
  }) {
    final text = isCrit ? 'CRIT! -${amount.round()}' : '-${amount.round()}';
    final color = isCrit ? const Color(0xFFFFD54F) : const Color(0xFFEF5350);
    final fontSize = isCrit ? 14.0 : 11.0;
    return FloatingTextComponent(
      text: text,
      position: position,
      baseColor: color,
      fontSize: fontSize,
      duration: isCrit ? 0.9 : 0.7,
    );
  }

  /// Né đòn (Màu xám)
  static FloatingTextComponent miss({required Vector2 position}) {
    return FloatingTextComponent(
      text: 'MISS',
      position: position,
      baseColor: const Color(0xFFBDBDBD),
      fontSize: 11.0,
      duration: 0.65,
    );
  }

  /// Hút máu / Hồi máu (Màu xanh lá)
  static FloatingTextComponent heal({
    required Vector2 position,
    required double amount,
  }) {
    return FloatingTextComponent(
      text: '+${amount.round()} HP',
      position: position,
      baseColor: const Color(0xFF66BB6A),
      fontSize: 11.0,
      duration: 0.75,
    );
  }

  /// Hút năng lượng / Hồi mana (Màu xanh dương)
  static FloatingTextComponent mana({
    required Vector2 position,
    required double amount,
  }) {
    return FloatingTextComponent(
      text: '+${amount.round()} MP',
      position: position,
      baseColor: const Color(0xFF42A5F5),
      fontSize: 11.0,
      duration: 0.75,
    );
  }

  /// Thông báo nhận Exp, Vàng, Đồ (Màu vàng kim / hổ phách)
  static FloatingTextComponent info({
    required Vector2 position,
    required String text,
    Color color = const Color(0xFFFFCA28),
  }) {
    return FloatingTextComponent(
      text: text,
      position: position,
      baseColor: color,
      fontSize: 11.0,
      duration: 0.85,
    );
  }
}
