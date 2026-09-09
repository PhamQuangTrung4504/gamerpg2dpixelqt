import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/core/combat_calculator.dart';
import 'package:gamerpg2dpixelqt/models/character_stats.dart';
import 'package:gamerpg2dpixelqt/models/skill.dart';

void main() {
  group('CombatCalculator Tests', () {
    test('Dodge check: When dodge succeeds, damage is 0 and isDodged is true', () {
      const attacker = CharacterStats(attackPower: 50);
      const defender = CharacterStats(defense: 10, dodge: 25);

      final result = CombatCalculator.calculateDamage(
        attacker: attacker,
        defender: defender,
        forceDodge: true,
      );

      expect(result.isDodged, isTrue);
      expect(result.damageDealt, equals(0));
      expect(result.lifeStealed, equals(0));
    });

    test('Basic damage calculation: Attack 50 vs Defense 10 -> Damage 40', () {
      const attacker = CharacterStats(attackPower: 50);
      const defender = CharacterStats(defense: 10);

      final result = CombatCalculator.calculateDamage(
        attacker: attacker,
        defender: defender,
        forceDodge: false,
        forceCrit: false,
      );

      expect(result.isDodged, isFalse);
      expect(result.isCrit, isFalse);
      expect(result.damageDealt, equals(40));
    });

    test('Armor penetration reduces effective defense', () {
      // Defender has 20 defense, attacker has 15 armor penetration -> effective defense = 5
      // Attack 50 - 5 = 45 damage
      const attacker = CharacterStats(attackPower: 50, armorPenetration: 15);
      const defender = CharacterStats(defense: 20);

      final result = CombatCalculator.calculateDamage(
        attacker: attacker,
        defender: defender,
        forceDodge: false,
        forceCrit: false,
      );

      expect(result.damageDealt, equals(45));
    });

    test('Critical damage and crit resistance interaction', () {
      // Attacker: ATK 50, critDamage 10 -> raw crit bonus = 10 * 2 = 20
      // Defender: DEF 10, critResistance 5 -> effective crit bonus = 20 - 5 = 15
      // Total raw damage: 50 + 15 = 65. Minus defense 10 = 55 damage
      const attacker = CharacterStats(attackPower: 50, critDamage: 10);
      const defender = CharacterStats(defense: 10, critResistance: 5);

      final result = CombatCalculator.calculateDamage(
        attacker: attacker,
        defender: defender,
        forceDodge: false,
        forceCrit: true,
      );

      expect(result.isCrit, isTrue);
      expect(result.damageDealt, equals(55));
    });

    test('Life Steal, Mana Steal, and Reflect Damage', () {
      // Attacker: ATK 100, lifeSteal 5%, manaSteal 10%
      // Defender: DEF 0, reflectDamage 4%
      // Final Damage = 100
      // Life Steal = 100 * 5% = 5 HP
      // Mana Steal = 100 * 10% = 10 MP
      // Reflect Damage = 100 * 4% = 4 HP
      const attacker = CharacterStats(attackPower: 100, lifeSteal: 5, manaSteal: 10);
      const defender = CharacterStats(defense: 0, reflectDamage: 4);

      final result = CombatCalculator.calculateDamage(
        attacker: attacker,
        defender: defender,
        forceDodge: false,
        forceCrit: false,
      );

      expect(result.damageDealt, equals(100));
      expect(result.lifeStealed, equals(5));
      expect(result.manaStealed, equals(10));
      expect(result.reflectedDamage, equals(4));
    });

    test('Skill multiplier and flat damage bonus', () {
      // Skill: Liệt Hỏa Đoạt Mệnh Lv 1 (powerMultiplier: 1.40, flatBonusDamage: 20)
      // Attacker ATK: 50. Base attack = 50 * 1.4 + 20 = 90
      // Defender DEF: 10 -> Damage = 80
      const attacker = CharacterStats(attackPower: 50);
      const defender = CharacterStats(defense: 10);
      final skillData = SkillCatalog.lietHoaDoatMenh.getDataForLevel(1);

      final result = CombatCalculator.calculateDamage(
        attacker: attacker,
        defender: defender,
        skillData: skillData,
        forceDodge: false,
        forceCrit: false,
      );

      expect(result.damageDealt, equals(80));
    });
  });
}
