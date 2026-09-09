import 'package:flame/components.dart';

/// Hằng số toàn cục cho Game
class GameConstants {
  GameConstants._();

  // --- Kích thước Bản đồ ---
  static const double mapWidth = 1254.0;
  static const double mapHeight = 1254.0;
  static final Vector2 mapSize = Vector2(mapWidth, mapHeight);

  // --- Kích thước Sprite Pixel Art chuẩn ---
  static const double characterFrameWidth = 32.0;
  static const double characterFrameHeight = 32.0;
  static final Vector2 characterSize = Vector2(characterFrameWidth, characterFrameHeight);

  // --- Animation Timing ---
  static const double idleStepTime = 0.35;
  static const double moveStepTime = 0.18;
  static const double attackStepTime = 0.15;
  static const int characterFrameCount = 2;

  // --- Tốc độ di chuyển cơ bản (tăng lên 130.0 để kiting linh hoạt trước Dơi 85 và Sói 70) ---
  static const double playerBaseSpeed = 130.0;

  // --- Cấp độ nhân vật ---
  static const int minLevel = 1;
  static const int maxLevel = 25;

  // --- Joystick ---
  static const double joystickRadius = 50.0;
  static const double joystickKnobRadius = 20.0;

  // --- Camera & Zoom ---
  static const double defaultZoom = 2.0;

  // --- Chu kỳ hồi phục HP & MP ---
  static const double regenIntervalSeconds = 1.0;
}
