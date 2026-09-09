import 'direction.dart';

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

  /// Thứ tự vẽ (Z-Index / Dynamic Priority) theo hướng nhìn của nhân vật:
  /// - Hướng down, left, right (nhìn phía trước / nghiêng):
  ///   + Cánh & Kiếm sau lưng: priority = 10 (dưới thân)
  ///   + Thân (Body): priority = 20
  ///   + Quần, Giáp, Giày, Mũ, Phụ kiện: priority = 30 (đè lên thân)
  /// - Hướng up (nhìn từ sau lưng):
  ///   + Thân (Body): priority = 10
  ///   + Quần, Giáp, Giày, Mũ: priority = 20
  ///   + Cánh & Kiếm: priority = 40 (vẽ đè lên trên cùng để lộ rõ kiếm/cánh sau lưng)
  int getRenderPriority(GameDirection direction) {
    if (direction == GameDirection.up) {
      switch (this) {
        case EquipmentType.sword:
        case EquipmentType.wings:
          return 40;
        case EquipmentType.pants:
        case EquipmentType.armor:
        case EquipmentType.shoes:
        case EquipmentType.helmet:
        case EquipmentType.glasses:
        case EquipmentType.necklace:
          return 20;
        case EquipmentType.ring:
        case EquipmentType.tome:
          return 0;
      }
    } else {
      switch (this) {
        case EquipmentType.sword:
        case EquipmentType.wings:
          return 10;
        case EquipmentType.pants:
        case EquipmentType.armor:
        case EquipmentType.shoes:
        case EquipmentType.helmet:
        case EquipmentType.glasses:
        case EquipmentType.necklace:
          return 30;
        case EquipmentType.ring:
        case EquipmentType.tome:
          return 0;
      }
    }
  }

  /// Priority mặc định khi nhìn thẳng phía trước (hướng down)
  int get renderPriority => getRenderPriority(GameDirection.down);
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
