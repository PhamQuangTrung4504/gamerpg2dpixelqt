import 'character_stats.dart';

/// Chủng loại quái vật
enum MonsterType {
  slime,
  bat,
  wolf,
  ghost;

  /// Tên định danh trong asset (slime, doi, soi, ma)
  String get assetName {
    switch (this) {
      case MonsterType.slime:
        return 'quai_slime';
      case MonsterType.bat:
        return 'quai_doi';
      case MonsterType.wolf:
        return 'quai_soi';
      case MonsterType.ghost:
        return 'quai_ma';
    }
  }

  /// Tên tiếng Việt hiển thị
  String get vietnameseName {
    switch (this) {
      case MonsterType.slime:
        return 'Slime';
      case MonsterType.bat:
        return 'Dơi';
      case MonsterType.wolf:
        return 'Sói';
      case MonsterType.ghost:
        return 'Bóng Ma';
    }
  }

  /// Kích thước frame gốc (Dơi: 24x24, Slime: 24x24, Sói: 24x24, Ma: 32x32)
  double get frameSize {
    switch (this) {
      case MonsterType.slime:
      case MonsterType.bat:
      case MonsterType.wolf:
        return 24.0;
      case MonsterType.ghost:
        return 32.0;
    }
  }
}

/// Dữ liệu quái vật
class MonsterData {
  final String id;
  final String name;
  final MonsterType type;
  final int level;
  final CharacterStats stats;
  final double moveSpeed;
  final int minGoldDrop;
  final int maxGoldDrop;
  final int expReward;

  const MonsterData({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.stats,
    required this.moveSpeed,
    required this.minGoldDrop,
    required this.maxGoldDrop,
    required this.expReward,
  });
}

/// Cơ sở dữ liệu 25 cấp độ quái vật chuẩn xác từ tài liệu thiết kế
class MonsterCatalog {
  MonsterCatalog._();

  static const List<MonsterData> all = [
    // --- SLIME (Lv 1 - 5) ---
    MonsterData(
      id: 'slime_lv1',
      name: 'Slime',
      type: MonsterType.slime,
      level: 1,
      stats: CharacterStats(maxHp: 30, attackPower: 5, defense: 0, armorPenetration: 0),
      moveSpeed: 40.0,
      minGoldDrop: 1,
      maxGoldDrop: 2,
      expReward: 5,
    ),
    MonsterData(
      id: 'slime_lv2',
      name: 'Slime',
      type: MonsterType.slime,
      level: 2,
      stats: CharacterStats(maxHp: 40, attackPower: 7, defense: 0, armorPenetration: 0),
      moveSpeed: 40.0,
      minGoldDrop: 2,
      maxGoldDrop: 3,
      expReward: 7,
    ),
    MonsterData(
      id: 'slime_lv3',
      name: 'Slime',
      type: MonsterType.slime,
      level: 3,
      stats: CharacterStats(maxHp: 50, attackPower: 9, defense: 0, armorPenetration: 0),
      moveSpeed: 40.0,
      minGoldDrop: 3,
      maxGoldDrop: 4,
      expReward: 10,
    ),
    MonsterData(
      id: 'slime_lv4',
      name: 'Slime',
      type: MonsterType.slime,
      level: 4,
      stats: CharacterStats(maxHp: 60, attackPower: 12, defense: 1, armorPenetration: 0),
      moveSpeed: 40.0,
      minGoldDrop: 4,
      maxGoldDrop: 5,
      expReward: 14,
    ),
    MonsterData(
      id: 'slime_lv5',
      name: 'Slime',
      type: MonsterType.slime,
      level: 5,
      stats: CharacterStats(maxHp: 75, attackPower: 15, defense: 2, armorPenetration: 1),
      moveSpeed: 40.0,
      minGoldDrop: 5,
      maxGoldDrop: 6,
      expReward: 18,
    ),

    // --- DƠI (Lv 6 - 10) ---
    MonsterData(
      id: 'bat_lv6',
      name: 'Dơi',
      type: MonsterType.bat,
      level: 6,
      stats: CharacterStats(maxHp: 110, attackPower: 25, defense: 6, armorPenetration: 5, dodge: 3),
      moveSpeed: 85.0,
      minGoldDrop: 5,
      maxGoldDrop: 8,
      expReward: 25,
    ),
    MonsterData(
      id: 'bat_lv7',
      name: 'Dơi',
      type: MonsterType.bat,
      level: 7,
      stats: CharacterStats(maxHp: 140, attackPower: 32, defense: 9, armorPenetration: 8, dodge: 3),
      moveSpeed: 85.0,
      minGoldDrop: 7,
      maxGoldDrop: 10,
      expReward: 32,
    ),
    MonsterData(
      id: 'bat_lv8',
      name: 'Dơi',
      type: MonsterType.bat,
      level: 8,
      stats: CharacterStats(maxHp: 175, attackPower: 40, defense: 12, armorPenetration: 11, dodge: 4),
      moveSpeed: 85.0,
      minGoldDrop: 9,
      maxGoldDrop: 13,
      expReward: 40,
    ),
    MonsterData(
      id: 'bat_lv9',
      name: 'Dơi',
      type: MonsterType.bat,
      level: 9,
      stats: CharacterStats(maxHp: 215, attackPower: 48, defense: 15, armorPenetration: 14, dodge: 4),
      moveSpeed: 85.0,
      minGoldDrop: 12,
      maxGoldDrop: 16,
      expReward: 50,
    ),
    MonsterData(
      id: 'bat_lv10',
      name: 'Dơi',
      type: MonsterType.bat,
      level: 10,
      stats: CharacterStats(maxHp: 260, attackPower: 58, defense: 18, armorPenetration: 18, dodge: 5),
      moveSpeed: 85.0,
      minGoldDrop: 15,
      maxGoldDrop: 20,
      expReward: 62,
    ),

    // --- SÓI (Lv 11 - 19) ---
    MonsterData(
      id: 'wolf_lv11',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 11,
      stats: CharacterStats(maxHp: 380, attackPower: 85, critDamage: 8, defense: 26, armorPenetration: 25, lifeSteal: 2),
      moveSpeed: 70.0,
      minGoldDrop: 20,
      maxGoldDrop: 28,
      expReward: 80,
    ),
    MonsterData(
      id: 'wolf_lv12',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 12,
      stats: CharacterStats(maxHp: 460, attackPower: 102, critDamage: 10, defense: 32, armorPenetration: 32, lifeSteal: 2),
      moveSpeed: 70.0,
      minGoldDrop: 25,
      maxGoldDrop: 35,
      expReward: 98,
    ),
    MonsterData(
      id: 'wolf_lv13',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 13,
      stats: CharacterStats(maxHp: 550, attackPower: 120, critDamage: 12, defense: 38, armorPenetration: 40, lifeSteal: 2),
      moveSpeed: 70.0,
      minGoldDrop: 32,
      maxGoldDrop: 44,
      expReward: 120,
    ),
    MonsterData(
      id: 'wolf_lv14',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 14,
      stats: CharacterStats(maxHp: 650, attackPower: 140, critDamage: 14, defense: 44, armorPenetration: 48, lifeSteal: 3),
      moveSpeed: 70.0,
      minGoldDrop: 40,
      maxGoldDrop: 55,
      expReward: 145,
    ),
    MonsterData(
      id: 'wolf_lv15',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 15,
      stats: CharacterStats(maxHp: 760, attackPower: 162, critDamage: 16, defense: 50, armorPenetration: 58, lifeSteal: 3),
      moveSpeed: 70.0,
      minGoldDrop: 50,
      maxGoldDrop: 68,
      expReward: 175,
    ),
    MonsterData(
      id: 'wolf_lv16',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 16,
      stats: CharacterStats(maxHp: 880, attackPower: 185, critDamage: 18, defense: 58, armorPenetration: 68, lifeSteal: 3),
      moveSpeed: 70.0,
      minGoldDrop: 62,
      maxGoldDrop: 82,
      expReward: 210,
    ),
    MonsterData(
      id: 'wolf_lv17',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 17,
      stats: CharacterStats(maxHp: 1010, attackPower: 210, critDamage: 20, defense: 66, armorPenetration: 78, lifeSteal: 4),
      moveSpeed: 70.0,
      minGoldDrop: 75,
      maxGoldDrop: 98,
      expReward: 250,
    ),
    MonsterData(
      id: 'wolf_lv18',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 18,
      stats: CharacterStats(maxHp: 1150, attackPower: 238, critDamage: 22, defense: 74, armorPenetration: 90, lifeSteal: 4),
      moveSpeed: 70.0,
      minGoldDrop: 90,
      maxGoldDrop: 115,
      expReward: 295,
    ),
    MonsterData(
      id: 'wolf_lv19',
      name: 'Sói',
      type: MonsterType.wolf,
      level: 19,
      stats: CharacterStats(maxHp: 1300, attackPower: 268, critDamage: 25, defense: 82, armorPenetration: 102, lifeSteal: 4),
      moveSpeed: 70.0,
      minGoldDrop: 108,
      maxGoldDrop: 135,
      expReward: 350,
    ),

    // --- BÓNG MA (Lv 20 - 25) ---
    MonsterData(
      id: 'ghost_lv20',
      name: 'Bóng Ma',
      type: MonsterType.ghost,
      level: 20,
      stats: CharacterStats(maxHp: 1600, attackPower: 360, critDamage: 22, critResistance: 8, defense: 110, armorPenetration: 140, reflectDamage: 5, dodge: 8),
      moveSpeed: 55.0,
      minGoldDrop: 130,
      maxGoldDrop: 170,
      expReward: 420,
    ),
    MonsterData(
      id: 'ghost_lv21',
      name: 'Bóng Ma',
      type: MonsterType.ghost,
      level: 21,
      stats: CharacterStats(maxHp: 1950, attackPower: 430, critDamage: 26, critResistance: 10, defense: 130, armorPenetration: 175, reflectDamage: 6, dodge: 9),
      moveSpeed: 55.0,
      minGoldDrop: 160,
      maxGoldDrop: 210,
      expReward: 500,
    ),
    MonsterData(
      id: 'ghost_lv22',
      name: 'Bóng Ma',
      type: MonsterType.ghost,
      level: 22,
      stats: CharacterStats(maxHp: 2350, attackPower: 510, critDamage: 30, critResistance: 12, defense: 150, armorPenetration: 215, reflectDamage: 7, dodge: 10),
      moveSpeed: 55.0,
      minGoldDrop: 200,
      maxGoldDrop: 260,
      expReward: 590,
    ),
    MonsterData(
      id: 'ghost_lv23',
      name: 'Bóng Ma',
      type: MonsterType.ghost,
      level: 23,
      stats: CharacterStats(maxHp: 2800, attackPower: 600, critDamage: 35, critResistance: 14, defense: 175, armorPenetration: 260, reflectDamage: 8, dodge: 11),
      moveSpeed: 55.0,
      minGoldDrop: 250,
      maxGoldDrop: 320,
      expReward: 700,
    ),
    MonsterData(
      id: 'ghost_lv24',
      name: 'Bóng Ma',
      type: MonsterType.ghost,
      level: 24,
      stats: CharacterStats(maxHp: 3300, attackPower: 700, critDamage: 40, critResistance: 16, defense: 200, armorPenetration: 310, reflectDamage: 9, dodge: 12),
      moveSpeed: 55.0,
      minGoldDrop: 310,
      maxGoldDrop: 400,
      expReward: 830,
    ),
    MonsterData(
      id: 'ghost_lv25',
      name: 'Bóng Ma',
      type: MonsterType.ghost,
      level: 25,
      stats: CharacterStats(maxHp: 3900, attackPower: 820, critDamage: 46, critResistance: 18, defense: 230, armorPenetration: 370, reflectDamage: 10, dodge: 13),
      moveSpeed: 55.0,
      minGoldDrop: 380,
      maxGoldDrop: 500,
      expReward: 1000,
    ),
  ];

  static MonsterData? getByLevel(int level) {
    try {
      return all.firstWhere((m) => m.level == level);
    } catch (_) {
      return null;
    }
  }
}
