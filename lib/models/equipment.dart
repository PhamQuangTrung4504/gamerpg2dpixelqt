import '../constants/equipment_types.dart';
import 'character_stats.dart';

/// Dữ liệu của một món trang bị
class Equipment {
  final String id;
  final String name;
  final EquipmentType type;
  final EquipmentMaterial material;
  final int requiredLevel;
  final CharacterStats stats;
  final double dropRatePercent;
  final int buyPrice;
  final int sellPrice;

  const Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.material,
    required this.requiredLevel,
    required this.stats,
    required this.dropRatePercent,
    required this.buyPrice,
    required this.sellPrice,
  });

  /// Tên định danh file (ví dụ: kiem_sat, giap_vang, canh...)
  String get itemIdentifier {
    if (material == EquipmentMaterial.special) {
      return type.assetName;
    }
    return '${type.assetName}_${material.assetSuffix}';
  }

  /// Đường dẫn icon hiển thị ô trang bị / hành trang
  String get iconAssetPath => 'assets/o_trang_bi/o_trang_bi_$itemIdentifier.png';

  /// Đường dẫn vật phẩm rơi trên mặt đất
  String get dropAssetPath => 'assets/trang_bi_roi/vat_pham_${id}_roi_16x16.png';
}

/// Danh mục toàn bộ 38 trang bị chuẩn xác theo tài liệu thiết kế
class EquipmentCatalog {
  EquipmentCatalog._();

  // --- KIẾM (SWORDS) ---
  static const Equipment kiemGo = Equipment(
    id: 'kiem_go',
    name: 'Kiếm Gỗ',
    type: EquipmentType.sword,
    material: EquipmentMaterial.wood,
    requiredLevel: 2,
    stats: CharacterStats(attackPower: 10),
    dropRatePercent: 100.0, // Hướng dẫn tân thủ
    buyPrice: 10,
    sellPrice: 5,
  );

  static const Equipment kiemSat = Equipment(
    id: 'kiem_sat',
    name: 'Kiếm Sắt',
    type: EquipmentType.sword,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(attackPower: 20, critDamage: 1),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment kiemBac = Equipment(
    id: 'kiem_bac',
    name: 'Kiếm Bạc',
    type: EquipmentType.sword,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(attackPower: 40, critDamage: 2, armorPenetration: 3),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment kiemVang = Equipment(
    id: 'kiem_vang',
    name: 'Kiếm Vàng',
    type: EquipmentType.sword,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(attackPower: 80, critDamage: 4, armorPenetration: 6, lifeSteal: 3, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment kiemLucBao = Equipment(
    id: 'kiem_luc_bao',
    name: 'Kiếm Lục Bảo',
    type: EquipmentType.sword,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(attackPower: 160, critDamage: 6, armorPenetration: 12, lifeSteal: 6, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment kiemKimCuong = Equipment(
    id: 'kiem_kim_cuong',
    name: 'Kiếm Kim Cương',
    type: EquipmentType.sword,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(attackPower: 320, critDamage: 10, armorPenetration: 24, lifeSteal: 9, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- MŨ (HELMETS) ---
  static const Equipment muSat = Equipment(
    id: 'mu_sat',
    name: 'Mũ Sắt',
    type: EquipmentType.helmet,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(maxHp: 50, defense: 5),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment muBac = Equipment(
    id: 'mu_bac',
    name: 'Mũ Bạc',
    type: EquipmentType.helmet,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(maxHp: 100, defense: 10, critResistance: 1),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment muVang = Equipment(
    id: 'mu_vang',
    name: 'Mũ Vàng',
    type: EquipmentType.helmet,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(maxHp: 200, defense: 20, critResistance: 2, reflectDamage: 2, dodge: 1, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment muLucBao = Equipment(
    id: 'mu_luc_bao',
    name: 'Mũ Lục Bảo',
    type: EquipmentType.helmet,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(maxHp: 400, defense: 40, critResistance: 4, reflectDamage: 4, dodge: 2, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment muKimCuong = Equipment(
    id: 'mu_kim_cuong',
    name: 'Mũ Kim Cương',
    type: EquipmentType.helmet,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(maxHp: 800, defense: 80, critResistance: 8, reflectDamage: 8, dodge: 4, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- GIÁP (ARMORS) ---
  static const Equipment giapSat = Equipment(
    id: 'giap_sat',
    name: 'Giáp Sắt',
    type: EquipmentType.armor,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(maxHp: 70, defense: 8),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment giapBac = Equipment(
    id: 'giap_bac',
    name: 'Giáp Bạc',
    type: EquipmentType.armor,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(maxHp: 140, defense: 16, critResistance: 2),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment giapVang = Equipment(
    id: 'giap_vang',
    name: 'Giáp Vàng',
    type: EquipmentType.armor,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(maxHp: 280, defense: 32, critResistance: 4, reflectDamage: 4, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment giapLucBao = Equipment(
    id: 'giap_luc_bao',
    name: 'Giáp Lục Bảo',
    type: EquipmentType.armor,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(maxHp: 560, defense: 64, critResistance: 6, reflectDamage: 6, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment giapKimCuong = Equipment(
    id: 'giap_kim_cuong',
    name: 'Giáp Kim Cương',
    type: EquipmentType.armor,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(maxHp: 1120, defense: 128, critResistance: 10, reflectDamage: 10, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- QUẦN (PANTS) ---
  static const Equipment quanSat = Equipment(
    id: 'quan_sat',
    name: 'Quần Sắt',
    type: EquipmentType.pants,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(maxHp: 50, defense: 6, hpRegen: 1),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment quanBac = Equipment(
    id: 'quan_bac',
    name: 'Quần Bạc',
    type: EquipmentType.pants,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(maxHp: 100, defense: 12, hpRegen: 2, critResistance: 1),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment quanVang = Equipment(
    id: 'quan_vang',
    name: 'Quần Vàng',
    type: EquipmentType.pants,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(maxHp: 200, defense: 24, hpRegen: 4, critResistance: 2, dodge: 2, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment quanLucBao = Equipment(
    id: 'quan_luc_bao',
    name: 'Quần Lục Bảo',
    type: EquipmentType.pants,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(maxHp: 400, defense: 48, hpRegen: 8, critResistance: 4, dodge: 3, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment quanKimCuong = Equipment(
    id: 'quan_kim_cuong',
    name: 'Quần Kim Cương',
    type: EquipmentType.pants,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(maxHp: 800, defense: 96, hpRegen: 16, critResistance: 8, dodge: 5, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- GIẦY (SHOES) ---
  static const Equipment giaySat = Equipment(
    id: 'giay_sat',
    name: 'Giầy Sắt',
    type: EquipmentType.shoes,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(maxHp: 30, defense: 3, dodge: 1),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment giayBac = Equipment(
    id: 'giay_bac',
    name: 'Giầy Bạc',
    type: EquipmentType.shoes,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(maxHp: 60, defense: 6, dodge: 2, critResistance: 1),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment giayVang = Equipment(
    id: 'giay_vang',
    name: 'Giầy Vàng',
    type: EquipmentType.shoes,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(maxHp: 120, defense: 12, dodge: 4, reflectDamage: 1, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment giayLucBao = Equipment(
    id: 'giay_luc_bao',
    name: 'Giầy Lục Bảo',
    type: EquipmentType.shoes,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(maxHp: 240, defense: 24, dodge: 6, reflectDamage: 2, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment giayKimCuong = Equipment(
    id: 'giay_kim_cuong',
    name: 'Giầy Kim Cương',
    type: EquipmentType.shoes,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(maxHp: 480, defense: 48, dodge: 8, reflectDamage: 4, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- DÂY CHUYỀN (NECKLACES) ---
  static const Equipment dayChuyenSat = Equipment(
    id: 'day_chuyen_sat',
    name: 'Dây Chuyền Sắt',
    type: EquipmentType.necklace,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(maxMp: 30, mpRegen: 1, manaSteal: 1, attackPower: 5),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment dayChuyenBac = Equipment(
    id: 'day_chuyen_bac',
    name: 'Dây Chuyền Bạc',
    type: EquipmentType.necklace,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(maxMp: 60, mpRegen: 2, manaSteal: 2, attackPower: 10, critResistance: 1),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment dayChuyenVang = Equipment(
    id: 'day_chuyen_vang',
    name: 'Dây Chuyền Vàng',
    type: EquipmentType.necklace,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(maxMp: 120, mpRegen: 4, manaSteal: 4, attackPower: 20, critResistance: 2, hpRegen: 1, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment dayChuyenLucBao = Equipment(
    id: 'day_chuyen_luc_bao',
    name: 'Dây Chuyền Lục Bảo',
    type: EquipmentType.necklace,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(maxMp: 240, mpRegen: 8, manaSteal: 6, attackPower: 40, critResistance: 4, hpRegen: 2, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment dayChuyenKimCuong = Equipment(
    id: 'day_chuyen_kim_cuong',
    name: 'Dây Chuyền Kim Cương',
    type: EquipmentType.necklace,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(maxMp: 480, mpRegen: 16, manaSteal: 10, attackPower: 80, critResistance: 8, hpRegen: 4, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- NHẪN (RINGS) ---
  static const Equipment nhanSat = Equipment(
    id: 'nhan_sat',
    name: 'Nhẫn Sắt',
    type: EquipmentType.ring,
    material: EquipmentMaterial.iron,
    requiredLevel: 5,
    stats: CharacterStats(attackPower: 10, critDamage: 2, manaSteal: 1),
    dropRatePercent: 20.0,
    buyPrice: 50,
    sellPrice: 25,
  );

  static const Equipment nhanBac = Equipment(
    id: 'nhan_bac',
    name: 'Nhẫn Bạc',
    type: EquipmentType.ring,
    material: EquipmentMaterial.silver,
    requiredLevel: 10,
    stats: CharacterStats(attackPower: 20, critDamage: 4, armorPenetration: 3, manaSteal: 2),
    dropRatePercent: 10.0,
    buyPrice: 250,
    sellPrice: 125,
  );

  static const Equipment nhanVang = Equipment(
    id: 'nhan_vang',
    name: 'Nhẫn Vàng',
    type: EquipmentType.ring,
    material: EquipmentMaterial.gold,
    requiredLevel: 15,
    stats: CharacterStats(attackPower: 40, critDamage: 6, armorPenetration: 6, lifeSteal: 2, manaSteal: 3, coolness: 1),
    dropRatePercent: 4.0,
    buyPrice: 1200,
    sellPrice: 600,
  );

  static const Equipment nhanLucBao = Equipment(
    id: 'nhan_luc_bao',
    name: 'Nhẫn Lục Bảo',
    type: EquipmentType.ring,
    material: EquipmentMaterial.emerald,
    requiredLevel: 20,
    stats: CharacterStats(attackPower: 80, critDamage: 10, armorPenetration: 12, lifeSteal: 4, manaSteal: 5, coolness: 2),
    dropRatePercent: 1.5,
    buyPrice: 5000,
    sellPrice: 2500,
  );

  static const Equipment nhanKimCuong = Equipment(
    id: 'nhan_kim_cuong',
    name: 'Nhẫn Kim Cương',
    type: EquipmentType.ring,
    material: EquipmentMaterial.diamond,
    requiredLevel: 25,
    stats: CharacterStats(attackPower: 160, critDamage: 18, armorPenetration: 24, lifeSteal: 6, manaSteal: 8, coolness: 3),
    dropRatePercent: 0.5,
    buyPrice: 25000,
    sellPrice: 12500,
  );

  // --- TRANG BỊ ĐẶC BIỆT ---
  static const Equipment kinh = Equipment(
    id: 'kinh',
    name: 'Kính',
    type: EquipmentType.glasses,
    material: EquipmentMaterial.special,
    requiredLevel: 15,
    stats: CharacterStats(
      maxHp: 150,
      maxMp: 150,
      attackPower: 30,
      defense: 15,
      armorPenetration: 5,
      lifeSteal: 1,
      manaSteal: 2,
      critDamage: 1,
      critResistance: 1,
      dodge: 1,
      coolness: 3,
    ),
    dropRatePercent: 1.0,
    buyPrice: 8000,
    sellPrice: 4000,
  );

  static const Equipment canh = Equipment(
    id: 'canh',
    name: 'Cánh',
    type: EquipmentType.wings,
    material: EquipmentMaterial.special,
    requiredLevel: 20,
    stats: CharacterStats(
      maxHp: 300,
      hpRegen: 6,
      maxMp: 300,
      mpRegen: 6,
      attackPower: 120,
      critDamage: 8,
      defense: 60,
      armorPenetration: 12,
      lifeSteal: 4,
      manaSteal: 4,
      reflectDamage: 4,
      critResistance: 4,
      dodge: 5,
      coolness: 5,
    ),
    dropRatePercent: 0.3,
    buyPrice: 35000,
    sellPrice: 17500,
  );

  static const Equipment biKip = Equipment(
    id: 'bi_kip',
    name: 'Bí Kíp',
    type: EquipmentType.tome,
    material: EquipmentMaterial.special,
    requiredLevel: 25,
    stats: CharacterStats(
      maxHp: 400,
      hpRegen: 12,
      maxMp: 400,
      mpRegen: 12,
      attackPower: 160,
      critDamage: 12,
      defense: 80,
      armorPenetration: 16,
      lifeSteal: 6,
      manaSteal: 6,
      reflectDamage: 6,
      critResistance: 6,
      dodge: 4,
      coolness: 6,
    ),
    dropRatePercent: 0.2,
    buyPrice: 60000,
    sellPrice: 30000,
  );

  /// Danh sách toàn bộ 38 trang bị
  static const List<Equipment> all = [
    kiemGo, kiemSat, kiemBac, kiemVang, kiemLucBao, kiemKimCuong,
    muSat, muBac, muVang, muLucBao, muKimCuong,
    giapSat, giapBac, giapVang, giapLucBao, giapKimCuong,
    quanSat, quanBac, quanVang, quanLucBao, quanKimCuong,
    giaySat, giayBac, giayVang, giayLucBao, giayKimCuong,
    dayChuyenSat, dayChuyenBac, dayChuyenVang, dayChuyenLucBao, dayChuyenKimCuong,
    nhanSat, nhanBac, nhanVang, nhanLucBao, nhanKimCuong,
    kinh, canh, biKip,
  ];

  /// Tra cứu trang bị theo ID
  static Equipment? getById(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
