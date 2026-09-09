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

  /// Thứ tự vẽ (Z-Index / Render Priority) tương đối giữa thân và các lớp trang bị
  /// - 1. Lớp sau lưng: Kiếm (5), Cánh (10)
  /// - 2. Thân nhân vật chính: BodyComponent (20)
  /// - 3. Lớp phụ kiện sát người: Dây chuyền (25), Kính (30)
  /// - 4. Lớp trang phục bên ngoài: Áo giáp, Mũ, Quần, Giày (40)
  int get renderPriority {
    switch (this) {
      case EquipmentType.sword:
        return 5; // Kiếm nằm sau lưng/sau nhân vật
      case EquipmentType.wings:
        return 10; // Cánh nằm sau nhân vật, trước kiếm
      case EquipmentType.necklace:
        return 25; // Dây chuyền sát người
      case EquipmentType.glasses:
        return 30; // Kính đeo trên mặt
      case EquipmentType.armor:
      case EquipmentType.helmet:
      case EquipmentType.pants:
      case EquipmentType.shoes:
        return 40; // Trang phục ngoài cùng phủ lên thân và phụ kiện
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
