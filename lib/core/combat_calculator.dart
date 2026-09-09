import 'dart:math';
import '../models/character_stats.dart';
import '../models/skill.dart';

/// Kết quả của một lần tính toán giao tranh
class CombatResult {
  final double damageDealt; // Sát thương thực tế gây ra lên mục tiêu
  final bool isDodged; // Mục tiêu có né đòn thành công không
  final bool isCrit; // Đòn đánh có chí mạng không
  final double lifeStealed; // Lượng máu hồi lại cho người tấn công
  final double manaStealed; // Lượng năng lượng hồi lại cho người tấn công
  final double reflectedDamage; // Sát thương phản ngược lại người tấn công

  const CombatResult({
    required this.damageDealt,
    required this.isDodged,
    required this.isCrit,
    required this.lifeStealed,
    required this.manaStealed,
    required this.reflectedDamage,
  });

  static const CombatResult dodged = CombatResult(
    damageDealt: 0,
    isDodged: true,
    isCrit: false,
    lifeStealed: 0,
    manaStealed: 0,
    reflectedDamage: 0,
  );
}

/// Bộ tính toán chiến đấu chuẩn xác theo công thức thiết kế
class CombatCalculator {
  static final Random _defaultRandom = Random();

  /// Tính toán kết quả sát thương giữa bên tấn công và bên phòng thủ
  static CombatResult calculateDamage({
    required CharacterStats attacker,
    required CharacterStats defender,
    SkillLevelData? skillData,
    Random? rng,
    bool? forceCrit,
    bool? forceDodge,
  }) {
    final random = rng ?? _defaultRandom;

    // 1. Kiểm tra Né đòn: "1 né đòn = 1% tỉ lệ né đòn tấn công nhận phải"
    final dodgeChance = defender.dodge.clamp(0.0, 75.0);
    final isDodged = forceDodge ?? (dodgeChance > 0 && (random.nextDouble() * 100.0 < dodgeChance));
    if (isDodged) {
      return CombatResult.dodged;
    }

    // 2. Hệ số kỹ năng
    final powerMultiplier = skillData?.powerMultiplier ?? 1.0;
    final flatBonusDamage = skillData?.flatBonusDamage ?? 0.0;
    final skillPenetration = skillData?.bonusArmorPenetration ?? 0.0;
    final armorIgnorePercent = skillData?.armorIgnorePercent ?? 0.0;

    // Sát thương cơ bản: powerMultiplier * attackPower + flatBonusDamage
    final baseAttack = (attacker.attackPower * powerMultiplier) + flatBonusDamage;

    // 3. Kiểm tra Chí mạng: "1 sức mạnh tấn công chí mạng gây thiệt hại 2 máu"
    // "1 kháng chí mạng sẽ giảm 1 sát thương chí mạng"
    final critChance = attacker.critDamage > 0 ? min(75.0, 5.0 + attacker.critDamage * 1.5) : 0.0;
    final isCrit = forceCrit ?? (critChance > 0 && (random.nextDouble() * 100.0 < critChance));

    double critBonusDamage = 0.0;
    if (isCrit && attacker.critDamage > 0) {
      // 1 điểm chí mạng = 2 sát thương, trừ đi kháng chí mạng của đối phương
      final rawCritBonus = attacker.critDamage * 2.0;
      critBonusDamage = max(0.0, rawCritBonus - defender.critResistance);
    }

    final rawDamage = baseAttack + critBonusDamage;

    // 4. Tính giáp & xuyên giáp:
    // "1 giáp giảm 1 tấn công lên bản thân"
    // "1 xuyên giáp bỏ qua 1 giáp kẻ địch"
    final totalPenetration = attacker.armorPenetration + skillPenetration;
    double effectiveDefense = max(0.0, defender.defense - totalPenetration);
    if (armorIgnorePercent > 0) {
      effectiveDefense = effectiveDefense * (1.0 - armorIgnorePercent);
    }

    // 5. Sát thương thực tế (tối thiểu là 1 điểm nếu không né)
    final finalDamage = max(1.0, (rawDamage - effectiveDefense).roundToDouble());

    // 6. Hút máu: "1 hút máu = 1% hút máu, gây thiệt hại 100 máu thì hồi 1 máu"
    final lifeStealed = attacker.lifeSteal > 0
        ? (finalDamage * (attacker.lifeSteal / 100.0)).roundToDouble()
        : 0.0;

    // 7. Hút năng lượng: "1 hút năng lượng = 1% hút năng lượng, gây thiệt hại 100 máu thì hồi 1 năng lượng"
    final manaStealed = attacker.manaSteal > 0
        ? (finalDamage * (attacker.manaSteal / 100.0)).roundToDouble()
        : 0.0;

    // 8. Phản sát thương: "1 phản sát thương = 1% phản sát, nhận thiệt hại 100 máu thì phản lại 1 máu"
    final reflectedDamage = defender.reflectDamage > 0
        ? (finalDamage * (defender.reflectDamage / 100.0)).roundToDouble()
        : 0.0;

    return CombatResult(
      damageDealt: finalDamage,
      isDodged: false,
      isCrit: isCrit,
      lifeStealed: lifeStealed,
      manaStealed: manaStealed,
      reflectedDamage: reflectedDamage,
    );
  }
}
