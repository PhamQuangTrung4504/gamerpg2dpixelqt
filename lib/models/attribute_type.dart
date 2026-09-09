/// Các thuộc tính có thể nâng cấp bằng Điểm Tiềm Năng (Attribute Points)
enum AttributeType {
  maxHp,
  hpRegen,
  maxMp,
  mpRegen,
  attackPower,
  defense;

  /// Tên hiển thị tiếng Việt
  String get displayName {
    switch (this) {
      case AttributeType.maxHp:
        return 'Máu tối đa';
      case AttributeType.hpRegen:
        return 'Hồi máu';
      case AttributeType.maxMp:
        return 'Năng lượng';
      case AttributeType.mpRegen:
        return 'Hồi năng lượng';
      case AttributeType.attackPower:
        return 'Sức mạnh';
      case AttributeType.defense:
        return 'Giáp phòng thủ';
    }
  }

  /// Định mức tăng mỗi điểm tiềm năng
  double get increaseAmount {
    switch (this) {
      case AttributeType.maxHp:
        return 20.0;
      case AttributeType.hpRegen:
        return 1.0;
      case AttributeType.maxMp:
        return 20.0;
      case AttributeType.mpRegen:
        return 1.0;
      case AttributeType.attackPower:
        return 3.0;
      case AttributeType.defense:
        return 1.0;
    }
  }

  /// Chuỗi hiển thị định mức tăng (ví dụ: "+20 HP", "+1 HP/s")
  String get increaseText {
    switch (this) {
      case AttributeType.maxHp:
        return '+20 HP';
      case AttributeType.hpRegen:
        return '+1 HP/s';
      case AttributeType.maxMp:
        return '+20 MP';
      case AttributeType.mpRegen:
        return '+1 MP/s';
      case AttributeType.attackPower:
        return '+3 ATK';
      case AttributeType.defense:
        return '+1 DEF';
    }
  }
}
