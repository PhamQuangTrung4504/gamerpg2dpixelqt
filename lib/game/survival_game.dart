import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/game_constants.dart';
import 'components/game_hud.dart';
import 'components/game_map.dart';
import 'components/joystick.dart';
import 'components/player_component.dart';

/// Lớp điều khiển chính của trò chơi (FlameGame)
class SurvivalGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  late final PlayerComponent player;
  late final JoystickComponent joystick;
  late final GameHud hud;

  final Set<LogicalKeyboardKey> _keysPressed = {};

  SurvivalGame()
      : super(
          camera: CameraComponent(),
        );

  @override
  Color backgroundColor() => const Color(0xFF141414);

  @override
  Future<void> onLoad() async {
    // Đặt prefix rỗng để tương thích trực tiếp toàn bộ đường dẫn 'assets/...'
    images.prefix = '';

    await super.onLoad();

    // 1. Thêm bản đồ vào thế giới (World)
    final map = GameMapComponent();
    await world.add(map);

    // 2. Thêm nhân vật chính (Player) ở trung tâm bản đồ
    player = PlayerComponent(
      initialPosition: Vector2(GameConstants.mapWidth / 2, GameConstants.mapHeight / 2),
    );
    await world.add(player);

    // 3. Cấu hình Camera zoom 2.0x, follow Player và giới hạn trong biên bản đồ 1254x1254 (tránh khoảng trống đen)
    camera.viewfinder.zoom = 2.0;
    camera.follow(player);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      considerViewport: true,
    );

    // 4. Thêm Joystick ảo lên Viewport
    joystick = await GameJoystick.create(this);
    camera.viewport.add(joystick);

    // 5. Thêm HUD hiển thị HP/MP/EXP và các nút kỹ năng lên Viewport
    hud = GameHud();
    camera.viewport.add(hud);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Cập nhật lại giới hạn Camera phù hợp với kích thước Viewport mới
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      considerViewport: true,
    );
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);

    // Nhấn Space để tấn công
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.performAttack();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Kết hợp input từ Joystick và Bàn phím
    final keyboardMovement = Vector2.zero();
    if (_keysPressed.contains(LogicalKeyboardKey.keyW) || _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      keyboardMovement.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) || _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      keyboardMovement.y += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) || _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      keyboardMovement.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) || _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      keyboardMovement.x += 1;
    }

    if (!joystick.delta.isZero()) {
      player.velocity = joystick.relativeDelta.normalized();
    } else if (!keyboardMovement.isZero()) {
      player.velocity = keyboardMovement.normalized();
    } else {
      player.velocity = Vector2.zero();
    }
  }
}
