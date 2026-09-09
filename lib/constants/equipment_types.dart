/// Các loại trang bị trong game
enum EquipmentType {
  sword,       // Kiếm (Vũ khí)
  helmet,      // Mũ
  armor,       // Giáp
  pants,       // Quần
  shoes,       // Giầy
  necklace,    // Dây chuyền
  ring,        // Nhẫn
  glasses,     // Kính
  wings,       // Cánh
  tome;        // Bí kíp

  /// Tên định danh trong asset (kiem, mu, giap, quan, giay, day_chuyen, nhan, kinh, canh, bi_kip)
  String get assetName {
    switch (this) {
      case EquipmentType.sword:
        return 'kiem';
      case EquipmentType.helmet:
        return 'mu';
      case EquipmentType.armor:
        return 'giap';
      case EquipmentType.pants:
        return 'quan';
      case EquipmentType.shoes:
        return 'giay';
      case EquipmentType.necklace:
        return 'day_chuyen';
      case EquipmentType.ring:
        return 'nhan';
      case EquipmentType.glasses:
        return 'kinh';
      case EquipmentType.wings:
        return 'canh';
      case EquipmentType.tome:
        return 'bi_kip';
    }
  }

  /// Tên tiếng Việt hiển thị
  String get vietnameseName {
    switch (this) {
      case EquipmentType.sword:
        return 'Kiếm';
      case EquipmentType.helmet:
        return 'Mũ';
      case EquipmentType.armor:
        return 'Giáp';
      case EquipmentType.pants:
        return 'Quần';
      case EquipmentType.shoes:
        return 'Giầy';
      case EquipmentType.necklace:
        return 'Dây chuyền';
      case EquipmentType.ring:
        return 'Nhẫn';
      case EquipmentType.glasses:
        return 'Kính';
      case EquipmentType.wings:
        return 'Cánh';
      case EquipmentType.tome:
        return 'Bí kíp';
    }
  }

  /// Có lớp sprite hiển thị trên người nhân vật hay không
  /// (Nhẫn và Bí kíp không có animation layer trực tiếp trên người)
  bool get hasVisualLayer =>
      this != EquipmentType.ring && this != EquipmentType.tome;

  /// Thứ tự vẽ (Z-Index) tương đối so với thân nhân vật (Body có priority = 10)
  int get renderPriority {
    switch (this) {
      case EquipmentType.wings:
        return 5; // Cánh nằm sau lưng nhân vật
      case EquipmentType.pants:
        return 12; // Quần mặc trên thân
      case EquipmentType.shoes:
        return 14; // Giầy
      case EquipmentType.armor:
        return 16; // Giáp ngoài
      case EquipmentType.necklace:
        return 18; // Dây chuyền
      case EquipmentType.helmet:
        return 20; // Mũ
      case EquipmentType.glasses:
        return 22; // Kính đeo trên mặt
      case EquipmentType.sword:
        return 25; // Kiếm trên tay phía trước
      case EquipmentType.ring:
      case EquipmentType.tome:
        return 0;
    }
  }
}

/// Chất liệu / Phẩm chất trang bị
enum EquipmentMaterial {
  wood,        // Gỗ
  iron,        // Sắt
  silver,      // Bạc
  gold,        // Vàng
  emerald,     // Lục bảo
  diamond,     // Kim cương
  special;     // Đặc biệt (Kính, Cánh, Bí kíp)

  /// Tên định danh trong asset (go, sat, bac, vang, luc_bao, kim_cuong, hoặc rỗng nếu đặc biệt)
  String get assetSuffix {
    switch (this) {
      case EquipmentMaterial.wood:
        return 'go';
      case EquipmentMaterial.iron:
        return 'sat';
      case EquipmentMaterial.silver:
        return 'bac';
      case EquipmentMaterial.gold:
        return 'vang';
      case EquipmentMaterial.emerald:
        return 'luc_bao';
      case EquipmentMaterial.diamond:
        return 'kim_cuong';
      case EquipmentMaterial.special:
        return '';
    }
  }

  /// Tên tiếng Việt hiển thị
  String get vietnameseName {
    switch (this) {
      case EquipmentMaterial.wood:
        return 'Gỗ';
      case EquipmentMaterial.iron:
        return 'Sắt';
      case EquipmentMaterial.silver:
        return 'Bạc';
      case EquipmentMaterial.gold:
        return 'Vàng';
      case EquipmentMaterial.emerald:
        return 'Lục Bảo';
      case EquipmentMaterial.diamond:
        return 'Kim Cương';
      case EquipmentMaterial.special:
        return 'Đặc Biệt';
    }
  }
}
