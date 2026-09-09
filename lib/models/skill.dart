/// Thông số của một cấp độ kỹ năng cụ thể
class SkillLevelData {
  final int level;
  final double cooldown; // Thời gian hồi chiêu (giây)
  final double manaCost; // Tiêu hao năng lượng
  final double powerMultiplier; // Hệ số % sức mạnh (ví dụ 1.0 = 100%, 1.25 = 125%)
  final double flatBonusDamage; // Sát thương cộng thêm phẳng
  final double knockbackDistance; // Đẩy lùi (pixel)
  final double bonusArmorPenetration; // Thêm xuyên giáp
  final double burnPercent; // % máu thiêu đốt
  final double burnDuration; // Thời gian thiêu đốt (giây)
  final int hitCount; // Số lần gây sát thương (hit)
  final double slowPercent; // % làm chậm
  final double slowDuration; // Thời gian làm chậm
  final double stunDuration; // Thời gian gây choáng (giây)
  final double buffArmor; // Giáp cộng thêm khi buff
  final double buffCritResistance; // Kháng chí mạng cộng thêm khi buff
  final double buffDodge; // Né đòn cộng thêm khi buff
  final double buffDuration; // Thời gian hiệu lực buff (giây)
  final double armorIgnorePercent; // % bỏ qua giáp mục tiêu

  const SkillLevelData({
    required this.level,
    required this.cooldown,
    required this.manaCost,
    required this.powerMultiplier,
    this.flatBonusDamage = 0,
    this.knockbackDistance = 0,
    this.bonusArmorPenetration = 0,
    this.burnPercent = 0,
    this.burnDuration = 0,
    this.hitCount = 1,
    this.slowPercent = 0,
    this.slowDuration = 0,
    this.stunDuration = 0,
    this.buffArmor = 0,
    this.buffCritResistance = 0,
    this.buffDodge = 0,
    this.buffDuration = 0,
    this.armorIgnorePercent = 0,
  });
}

/// Dữ liệu kỹ năng
class Skill {
  final String id;
  final String name;
  final String description;
  final int requiredCharacterLevel;
  final int maxSkillLevel;
  final String iconAssetPath;
  final String buttonAssetPath;
  final List<SkillLevelData> levels;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredCharacterLevel,
    required this.maxSkillLevel,
    required this.iconAssetPath,
    required this.buttonAssetPath,
    required this.levels,
  });

  SkillLevelData getDataForLevel(int level) {
    final clamped = level.clamp(1, maxSkillLevel);
    return levels[clamped - 1];
  }
}

/// Cơ sở dữ liệu 4 kỹ năng chuẩn theo tài liệu thiết kế
class SkillCatalog {
  SkillCatalog._();

  // --- KỸ NĂNG 1: ĐÁNH THƯỜNG ---
  static const Skill danhThuong = Skill(
    id: 'skill_danh_thuong',
    name: 'Đánh Thường',
    description: 'Kiếm sĩ vung kiếm chém hình bán nguyệt góc 120 độ trước mặt, gây sát thương vật lý.',
    requiredCharacterLevel: 1,
    maxSkillLevel: 5,
    iconAssetPath: 'assets/ki_nang/tan_cong_thuong_32x32.png',
    buttonAssetPath: 'assets/nut_tan_cong/nut_tan_cong_32x32.png',
    levels: [
      SkillLevelData(level: 1, cooldown: 0.40, manaCost: 0, powerMultiplier: 1.00, flatBonusDamage: 0),
      SkillLevelData(level: 2, cooldown: 0.38, manaCost: 0, powerMultiplier: 1.05, flatBonusDamage: 2),
      SkillLevelData(level: 3, cooldown: 0.36, manaCost: 0, powerMultiplier: 1.10, flatBonusDamage: 5),
      SkillLevelData(level: 4, cooldown: 0.34, manaCost: 0, powerMultiplier: 1.15, flatBonusDamage: 9),
      SkillLevelData(level: 5, cooldown: 0.30, manaCost: 0, powerMultiplier: 1.25, flatBonusDamage: 15, bonusArmorPenetration: 10),
    ],
  );

  // --- KỸ NĂNG 2: LIỆT HỎA ĐOẠT MỆNH ---
  static const Skill lietHoaDoatMenh = Skill(
    id: 'skill_liet_hoa',
    name: 'Liệt Hỏa Đoạt Mệnh',
    description: 'Phóng ra luồng kiếm khí hình lưỡi liềm rực lửa bay thẳng cự ly 250px, xuyên qua kẻ địch.',
    requiredCharacterLevel: 6,
    maxSkillLevel: 5,
    iconAssetPath: 'assets/ki_nang/ki_nang_1_liet_hoa_doat_menh_32x32.png',
    buttonAssetPath: 'assets/nut_tan_cong/nut_ki_nang_1_liet_hoa_doat_menh_32x32.png',
    levels: [
      SkillLevelData(level: 1, cooldown: 3.5, manaCost: 12, powerMultiplier: 1.40, flatBonusDamage: 20, knockbackDistance: 15),
      SkillLevelData(level: 2, cooldown: 3.3, manaCost: 14, powerMultiplier: 1.55, flatBonusDamage: 35, knockbackDistance: 18),
      SkillLevelData(level: 3, cooldown: 3.1, manaCost: 16, powerMultiplier: 1.70, flatBonusDamage: 55, knockbackDistance: 20),
      SkillLevelData(level: 4, cooldown: 2.8, manaCost: 18, powerMultiplier: 1.85, flatBonusDamage: 80, knockbackDistance: 22),
      SkillLevelData(level: 5, cooldown: 2.5, manaCost: 20, powerMultiplier: 2.10, flatBonusDamage: 120, knockbackDistance: 25, burnPercent: 0.05, burnDuration: 2.0),
    ],
  );

  // --- KỸ NĂNG 3: VẠN KIẾM QUY TÔNG ---
  static const Skill vanKiemQuyTong = Skill(
    id: 'skill_van_kiem',
    name: 'Vạn Kiếm Quy Tông',
    description: 'Kích hoạt kiếm trận bán kính 90px, triệu hồi 3 cự kiếm ánh sáng từ trên không cắm xuống.',
    requiredCharacterLevel: 11,
    maxSkillLevel: 6,
    iconAssetPath: 'assets/ki_nang/ki_nang_2_van_kiem_quy_tong_32x32.png',
    buttonAssetPath: 'assets/nut_tan_cong/nut_ki_nang_2_van_kiem_quy_tong_32x32.png',
    levels: [
      SkillLevelData(level: 1, cooldown: 7.0, manaCost: 30, powerMultiplier: 0.70, flatBonusDamage: 25, hitCount: 3, slowPercent: 0.30, slowDuration: 2.0),
      SkillLevelData(level: 2, cooldown: 6.7, manaCost: 34, powerMultiplier: 0.75, flatBonusDamage: 35, hitCount: 3, slowPercent: 0.30, slowDuration: 2.0),
      SkillLevelData(level: 3, cooldown: 6.4, manaCost: 38, powerMultiplier: 0.80, flatBonusDamage: 50, hitCount: 3, slowPercent: 0.30, slowDuration: 2.0),
      SkillLevelData(level: 4, cooldown: 6.0, manaCost: 42, powerMultiplier: 0.85, flatBonusDamage: 70, hitCount: 3, slowPercent: 0.30, slowDuration: 2.0),
      SkillLevelData(level: 5, cooldown: 5.6, manaCost: 46, powerMultiplier: 0.90, flatBonusDamage: 95, hitCount: 3, slowPercent: 0.30, slowDuration: 2.5),
      SkillLevelData(level: 6, cooldown: 5.0, manaCost: 50, powerMultiplier: 1.00, flatBonusDamage: 130, hitCount: 3, slowPercent: 0.35, slowDuration: 2.5, stunDuration: 1.0),
    ],
  );

  // --- KỸ NĂNG 4: NGỰ KIẾM HỘ THỂ / PHI KIẾM ---
  static const Skill nguKiemPhiKiem = Skill(
    id: 'skill_ngu_kiem',
    name: 'Ngự Kiếm Hộ Thể / Phi Kiếm',
    description: 'Tạo 6 phi kiếm xoay quanh phòng vệ 3s, sau đó tự động lao vào kẻ địch gần nhất.',
    requiredCharacterLevel: 16,
    maxSkillLevel: 5,
    iconAssetPath: 'assets/ki_nang/ki_nang_3_ho_kiem_phi_kiem_32x32.png',
    buttonAssetPath: 'assets/nut_tan_cong/nut_ki_nang_3_ho_kiem_phi_kiem_32x32.png',
    levels: [
      SkillLevelData(level: 1, cooldown: 12.0, manaCost: 60, powerMultiplier: 0.50, flatBonusDamage: 30, hitCount: 6, buffArmor: 15, buffCritResistance: 5, buffDuration: 3.0),
      SkillLevelData(level: 2, cooldown: 11.4, manaCost: 70, powerMultiplier: 0.55, flatBonusDamage: 45, hitCount: 6, buffArmor: 25, buffCritResistance: 8, buffDuration: 3.0),
      SkillLevelData(level: 3, cooldown: 10.8, manaCost: 80, powerMultiplier: 0.60, flatBonusDamage: 65, hitCount: 6, buffArmor: 40, buffCritResistance: 12, buffDuration: 3.0),
      SkillLevelData(level: 4, cooldown: 10.0, manaCost: 90, powerMultiplier: 0.65, flatBonusDamage: 90, hitCount: 6, buffArmor: 60, buffCritResistance: 18, buffDuration: 3.0),
      SkillLevelData(level: 5, cooldown: 9.0, manaCost: 100, powerMultiplier: 0.75, flatBonusDamage: 120, hitCount: 6, buffArmor: 90, buffCritResistance: 25, buffDodge: 5, buffDuration: 3.0, armorIgnorePercent: 0.30),
    ],
  );

  static const List<Skill> all = [
    danhThuong,
    lietHoaDoatMenh,
    vanKiemQuyTong,
    nguKiemPhiKiem,
  ];
}
