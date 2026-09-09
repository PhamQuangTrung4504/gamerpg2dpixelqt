import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/models/character_stats.dart';
import 'package:gamerpg2dpixelqt/models/equipment.dart';
import 'package:gamerpg2dpixelqt/models/monster.dart';

void main() {
  group('CharacterStats & Catalog Tests', () {
    test('Initial base stats match design specification', () {
      const base = CharacterStats.initialBase;
      expect(base.maxHp, equals(100));
      expect(base.hpRegen, equals(2));
      expect(base.maxMp, equals(100));
      expect(base.mpRegen, equals(2));
      expect(base.attackPower, equals(10));
      expect(base.critDamage, equals(0));
      expect(base.defense, equals(2));
      expect(base.armorPenetration, equals(0));
      expect(base.lifeSteal, equals(0));
      expect(base.manaSteal, equals(0));
      expect(base.reflectDamage, equals(0));
      expect(base.critResistance, equals(0));
      expect(base.dodge, equals(0));
      expect(base.coolness, equals(0));
    });

    test('Coolness multiplier: 10 coolness = +10% on all stats (not on coolness itself)', () {
      const stats = CharacterStats(
        maxHp: 100,
        attackPower: 50,
        defense: 20,
        coolness: 10,
      );

      final modified = stats.applyCoolnessMultiplier();

      expect(modified.maxHp, equals(110)); // 100 * 1.10 = 110
      expect(modified.attackPower, equals(55)); // 50 * 1.10 = 55
      expect(modified.defense, equals(22)); // 20 * 1.10 = 22
      expect(modified.coolness, equals(10)); // Not multiplied
    });

    test('Equipment catalog contains all 39 items with valid stats', () {
      expect(EquipmentCatalog.all.length, equals(39));

      // Check Kiếm gỗ
      final kiemGo = EquipmentCatalog.getById('kiem_go');
      expect(kiemGo, isNotNull);
      expect(kiemGo!.stats.attackPower, equals(10));
      expect(kiemGo.requiredLevel, equals(2));

      // Check Cánh
      final canh = EquipmentCatalog.getById('canh');
      expect(canh, isNotNull);
      expect(canh!.stats.maxHp, equals(300));
      expect(canh.stats.coolness, equals(5));
      expect(canh.buyPrice, equals(35000));
      expect(canh.sellPrice, equals(17500));
    });

    test('Monster catalog contains 25 monster levels', () {
      expect(MonsterCatalog.all.length, equals(25));

      final slime1 = MonsterCatalog.getByLevel(1);
      expect(slime1, isNotNull);
      expect(slime1!.stats.maxHp, equals(30));
      expect(slime1.expReward, equals(5));

      final ghost25 = MonsterCatalog.getByLevel(25);
      expect(ghost25, isNotNull);
      expect(ghost25!.stats.maxHp, equals(3900));
      expect(ghost25.expReward, equals(1000));
    });
  });
}
