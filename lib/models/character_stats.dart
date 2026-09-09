import 'dart:math';

/// Chỉ số thuộc tính của nhân vật/thực thể
class CharacterStats {
  final double maxHp;
  final double hpRegen; // 1 hồi máu = +1 máu / giây
  final double maxMp;
  final double mpRegen; // 1 hồi năng lượng = +1 hồi năng lượng / giây
  final double attackPower; // 1 sức mạnh = 1 sát thương tấn công
  final double critDamage; // Điểm chí mạng (tăng sát thương khi chí mạng)
  final double defense; // 1 giáp = giảm 1 sát thương nhận phải
  final double armorPenetration; // 1 xuyên giáp = bỏ qua 1 giáp kẻ địch
  final double lifeSteal; // 1 hút máu = 1% hút máu
  final double manaSteal; // 1 hút năng lượng = 1% hút năng lượng
  final double reflectDamage; // 1 phản sát thương = 1% phản sát
  final double critResistance; // 1 kháng chí mạng = giảm 1 sát thương chí mạng
  final double dodge; // 1 né đòn = 1% tỉ lệ né đòn
  final double coolness; // 1 ngầu = +1% toàn bộ chỉ số (không cộng vào ngầu)

  const CharacterStats({
    this.maxHp = 0,
    this.hpRegen = 0,
    this.maxMp = 0,
    this.mpRegen = 0,
    this.attackPower = 0,
    this.critDamage = 0,
    this.defense = 0,
    this.armorPenetration = 0,
    this.lifeSteal = 0,
    this.manaSteal = 0,
    this.reflectDamage = 0,
    this.critResistance = 0,
    this.dodge = 0,
    this.coolness = 0,
  });

  /// Chỉ số cơ bản ban đầu của nhân vật chính
  static const CharacterStats initialBase = CharacterStats(
    maxHp: 100,
    hpRegen: 2,
    maxMp: 100,
    mpRegen: 2,
    attackPower: 10,
    critDamage: 0,
    defense: 2,
    armorPenetration: 0,
    lifeSteal: 0,
    manaSteal: 0,
    reflectDamage: 0,
    critResistance: 0,
    dodge: 0,
    coolness: 0,
  );

  /// Chỉ số rỗng
  static const CharacterStats zero = CharacterStats();

  /// Cộng hai bộ chỉ số phẳng (raw addition)
  CharacterStats operator +(CharacterStats other) {
    return CharacterStats(
      maxHp: maxHp + other.maxHp,
      hpRegen: hpRegen + other.hpRegen,
      maxMp: maxMp + other.maxMp,
      mpRegen: mpRegen + other.mpRegen,
      attackPower: attackPower + other.attackPower,
      critDamage: critDamage + other.critDamage,
      defense: defense + other.defense,
      armorPenetration: armorPenetration + other.armorPenetration,
      lifeSteal: lifeSteal + other.lifeSteal,
      manaSteal: manaSteal + other.manaSteal,
      reflectDamage: reflectDamage + other.reflectDamage,
      critResistance: critResistance + other.critResistance,
      dodge: dodge + other.dodge,
      coolness: coolness + other.coolness,
    );
  }

  /// Tính toán chỉ số tổng thể sau khi áp dụng hiệu ứng của chỉ số "Ngầu"
  /// Quy tắc: 1 Ngầu = +1% toàn bộ chỉ số, không tự cộng dồn vào chính chỉ số Ngầu.
  CharacterStats applyCoolnessMultiplier() {
    if (coolness <= 0) return this;
    final multiplier = 1.0 + (coolness * 0.01);
    return CharacterStats(
      maxHp: (maxHp * multiplier).roundToDouble(),
      hpRegen: (hpRegen * multiplier).roundToDouble(),
      maxMp: (maxMp * multiplier).roundToDouble(),
      mpRegen: (mpRegen * multiplier).roundToDouble(),
      attackPower: (attackPower * multiplier).roundToDouble(),
      critDamage: (critDamage * multiplier).roundToDouble(),
      defense: (defense * multiplier).roundToDouble(),
      armorPenetration: (armorPenetration * multiplier).roundToDouble(),
      lifeSteal: (lifeSteal * multiplier).roundToDouble(),
      manaSteal: (manaSteal * multiplier).roundToDouble(),
      reflectDamage: (reflectDamage * multiplier).roundToDouble(),
      critResistance: (critResistance * multiplier).roundToDouble(),
      dodge: min(75.0, (dodge * multiplier).roundToDouble()), // Né đòn giới hạn hợp lý
      coolness: coolness, // Không nhân vào chỉ số ngầu
    );
  }

  CharacterStats copyWith({
    double? maxHp,
    double? hpRegen,
    double? maxMp,
    double? mpRegen,
    double? attackPower,
    double? critDamage,
    double? defense,
    double? armorPenetration,
    double? lifeSteal,
    double? manaSteal,
    double? reflectDamage,
    double? critResistance,
    double? dodge,
    double? coolness,
  }) {
    return CharacterStats(
      maxHp: maxHp ?? this.maxHp,
      hpRegen: hpRegen ?? this.hpRegen,
      maxMp: maxMp ?? this.maxMp,
      mpRegen: mpRegen ?? this.mpRegen,
      attackPower: attackPower ?? this.attackPower,
      critDamage: critDamage ?? this.critDamage,
      defense: defense ?? this.defense,
      armorPenetration: armorPenetration ?? this.armorPenetration,
      lifeSteal: lifeSteal ?? this.lifeSteal,
      manaSteal: manaSteal ?? this.manaSteal,
      reflectDamage: reflectDamage ?? this.reflectDamage,
      critResistance: critResistance ?? this.critResistance,
      dodge: dodge ?? this.dodge,
      coolness: coolness ?? this.coolness,
    );
  }

  @override
  String toString() {
    return 'CharacterStats(HP: $maxHp, MP: $maxMp, ATK: $attackPower, DEF: $defense, Crit: $critDamage, Pen: $armorPenetration, Dodge: $dodge%, Coolness: $coolness)';
  }
}
