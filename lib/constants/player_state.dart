/// Trạng thái hoạt động của nhân vật
enum CharacterState {
  idle,
  move,
  attack;

  /// Tên thư mục và tiền tố tương ứng trong assets
  String get folderName {
    switch (this) {
      case CharacterState.idle:
        return 'dung_im';
      case CharacterState.move:
        return 'di_chuyen';
      case CharacterState.attack:
        return 'tan_cong';
    }
  }

  /// Tiền tố hành động cho tên file
  String get actionName {
    switch (this) {
      case CharacterState.idle:
        return 'dung_im';
      case CharacterState.move:
        return 'di_chuyen';
      case CharacterState.attack:
        return 'tan_cong';
    }
  }
}
