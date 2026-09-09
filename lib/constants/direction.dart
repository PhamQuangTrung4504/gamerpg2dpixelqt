import 'package:flame/components.dart';

/// Hướng của thực thể (Nhân vật, Quái vật...)
enum GameDirection {
  down,
  left,
  up,
  right;

  /// Kiểm tra có đang quay sang trái không
  bool get isLeft => this == GameDirection.left;

  /// Kiểm tra có đang quay sang phải không
  bool get isRight => this == GameDirection.right;

  /// Kiểm tra có đang quay lên trên không
  bool get isUp => this == GameDirection.up;

  /// Kiểm tra có đang quay xuống dưới không
  bool get isDown => this == GameDirection.down;

  /// Suffix tương ứng trong tên file hình ảnh (phia_duoi, phia_trai, phia_tren).
  /// Lưu ý: Hướng 'right' sẽ dùng sprite của 'phia_trai' kèm flip ngang (scale.x = -1).
  String get assetSuffix {
    switch (this) {
      case GameDirection.down:
        return 'phia_duoi';
      case GameDirection.left:
      case GameDirection.right:
        return 'phia_trai';
      case GameDirection.up:
        return 'phia_tren';
    }
  }

  /// Tên suffix ngắn cho thư mục (duoi, trai, tren) dùng cho trang bị tấn công
  String get shortSuffix {
    switch (this) {
      case GameDirection.down:
        return 'duoi';
      case GameDirection.left:
      case GameDirection.right:
        return 'trai';
      case GameDirection.up:
        return 'tren';
    }
  }

  /// Vector hướng đơn vị 2D tương ứng
  Vector2 toVector2() {
    switch (this) {
      case GameDirection.down:
        return Vector2(0, 1);
      case GameDirection.left:
        return Vector2(-1, 0);
      case GameDirection.up:
        return Vector2(0, -1);
      case GameDirection.right:
        return Vector2(1, 0);
    }
  }

  /// Xác định hướng từ vector vận tốc di chuyển
  static GameDirection fromVector2(Vector2 movement) {
    if (movement.x.abs() > movement.y.abs()) {
      return movement.x > 0 ? GameDirection.right : GameDirection.left;
    } else if (movement.y != 0) {
      return movement.y > 0 ? GameDirection.down : GameDirection.up;
    }
    return GameDirection.down;
  }
}
