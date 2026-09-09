import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/core/exp_manager.dart';
import 'package:gamerpg2dpixelqt/game/components/player_component.dart';
import 'package:gamerpg2dpixelqt/models/attribute_type.dart';
import 'package:gamerpg2dpixelqt/models/character_stats.dart';
import 'package:gamerpg2dpixelqt/models/equipment.dart';
import 'package:gamerpg2dpixelqt/models/skill.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attribute Points & Level-Up Progression Tests', () {
    test('ExpManager grants +3 attribute points and +1 skill point upon level-up', () {
      final expManager = ExpManager();
      expect(expManager.attributePoints, equals(0));
      expect(expManager.skillPoints, equals(0));

      // Level 1 -> 2 requires 20 EXP
      expManager.addExp(20);
      expect(expManager.currentLevel, equals(2));
      expect(expManager.skillPoints, equals(1));
      expect(expManager.attributePoints, equals(3));

      // Level 2 -> 3 requires 45 EXP
      expManager.addExp(45);
      expect(expManager.currentLevel, equals(3));
      expect(expManager.skillPoints, equals(2));
      expect(expManager.attributePoints, equals(6));
    });

    test('ExpManager multi-level jump grants cumulative points', () {
      final expManager = ExpManager();
      // Level 1: needs 20, Level 2: needs 45, Level 3: needs 80 -> total 145 for 3 levels (to Level 4)
      expManager.addExp(145);
      expect(expManager.currentLevel, equals(4));
      expect(expManager.skillPoints, equals(3));
      expect(expManager.attributePoints, equals(9));
    });

    test('Using attribute points decrements available points', () {
      final expManager = ExpManager(initialAttributePoints: 3);
      expect(expManager.useAttributePoint(), isTrue);
      expect(expManager.attributePoints, equals(2));
      expect(expManager.useAttributePoint(), isTrue);
      expect(expManager.useAttributePoint(), isTrue);
      expect(expManager.useAttributePoint(), isFalse); // Empty
      expect(expManager.attributePoints, equals(0));
    });
  });

  group('PlayerComponent Attribute Upgrading & Stat Recalculation Tests', () {
    test('Upgrading attributes increases base stats and recalculates total stats accurately', () {
      final player = PlayerComponent();
      final initialHp = player.stats.maxHp;
      final initialAtk = player.stats.attackPower;
      final initialDef = player.stats.defense;

      // Add 6 attribute points
      player.expManager.addAttributePoints(6);
      expect(player.attributePoints, equals(6));

      // 1. Nâng Máu (+20 HP)
      expect(player.upgradeAttribute(AttributeType.maxHp), isTrue);
      expect(player.stats.maxHp, equals(initialHp + 20));

      // 2. Nâng Hồi máu (+1 HP/s)
      expect(player.upgradeAttribute(AttributeType.hpRegen), isTrue);
      expect(player.stats.hpRegen, equals(CharacterStats.initialBase.hpRegen + 1));

      // 3. Nâng Năng lượng (+20 MP)
      expect(player.upgradeAttribute(AttributeType.maxMp), isTrue);
      expect(player.stats.maxMp, equals(CharacterStats.initialBase.maxMp + 20));

      // 4. Nâng Hồi năng lượng (+1 MP/s)
      expect(player.upgradeAttribute(AttributeType.mpRegen), isTrue);
      expect(player.stats.mpRegen, equals(CharacterStats.initialBase.mpRegen + 1));

      // 5. Nâng Sức mạnh (+3 ATK)
      expect(player.upgradeAttribute(AttributeType.attackPower), isTrue);
      expect(player.stats.attackPower, equals(initialAtk + 3));

      // 6. Nâng Giáp (+1 DEF)
      expect(player.upgradeAttribute(AttributeType.defense), isTrue);
      expect(player.stats.defense, equals(initialDef + 1));

      // Hết điểm tiềm năng
      expect(player.attributePoints, equals(0));
      expect(player.upgradeAttribute(AttributeType.attackPower), isFalse);
    });

    test('Coolness multiplier applies to upgraded base stats', () {
      final player = PlayerComponent();
      player.expManager.addAttributePoints(2);

      // Upgrade attack power twice (+6 ATK) -> base attack becomes 10 + 6 = 16
      player.upgradeAttribute(AttributeType.attackPower);
      player.upgradeAttribute(AttributeType.attackPower);

      // Equip an item with coolness, e.g. Kính (10 coolness = +10% to all stats)
      player.addToInventory(EquipmentCatalog.kinh);
      player.equipFromInventory(EquipmentCatalog.kinh);

      // Base attack (16) + wooden sword (10) + kính (30) = 56 raw attack.
      // With 3 coolness (+3%): 56 * 1.03 = 57.68 -> rounded to 58.0
      expect(player.stats.attackPower, equals(58.0));
    });
  });

  group('Skill Tree Progression & Level-Requirement Tests', () {
    test('Default skill levels are 1 for all skills', () {
      final player = PlayerComponent();
      expect(player.getSkillLevel(SkillCatalog.danhThuong.id), equals(1));
      expect(player.getSkillLevel(SkillCatalog.lietHoaDoatMenh.id), equals(1));
      expect(player.getSkillLevel(SkillCatalog.vanKiemQuyTong.id), equals(1));
      expect(player.getSkillLevel(SkillCatalog.nguKiemPhiKiem.id), equals(1));
    });

    test('Cannot upgrade skill if required character level is not met', () {
      final player = PlayerComponent(); // Level 1
      player.expManager.addExp(20); // Level 2, 1 skill point

      // Skill 1 (Đánh thường): required level 1 -> Can upgrade
      expect(player.canUpgradeSkill(SkillCatalog.danhThuong), isTrue);

      // Skill 2 (Liệt Hỏa Đoạt Mệnh): required level 6 -> Locked
      expect(player.canUpgradeSkill(SkillCatalog.lietHoaDoatMenh), isFalse);
      expect(player.upgradeSkill(SkillCatalog.lietHoaDoatMenh), isFalse);

      // Skill 3 (Vạn Kiếm Quy Tông): required level 11 -> Locked
      expect(player.canUpgradeSkill(SkillCatalog.vanKiemQuyTong), isFalse);

      // Skill 4 (Ngự Kiếm Hộ Thể): required level 16 -> Locked
      expect(player.canUpgradeSkill(SkillCatalog.nguKiemPhiKiem), isFalse);
    });

    test('Can upgrade skill when character reaches required level and has skill points', () {
      final player = PlayerComponent();
      // Level 1 -> 6 requires 20 + 45 + 80 + 130 + 200 = 475 EXP
      player.expManager.addExp(475);
      expect(player.expManager.currentLevel, equals(6));
      expect(player.expManager.skillPoints, equals(5));

      // Now Liệt Hỏa Đoạt Mệnh (required level 6) can be upgraded!
      expect(player.canUpgradeSkill(SkillCatalog.lietHoaDoatMenh), isTrue);
      expect(player.upgradeSkill(SkillCatalog.lietHoaDoatMenh), isTrue);
      expect(player.getSkillLevel(SkillCatalog.lietHoaDoatMenh.id), equals(2));
      expect(player.expManager.skillPoints, equals(4));

      // Vạn Kiếm Quy Tông (required level 11) is still locked
      expect(player.canUpgradeSkill(SkillCatalog.vanKiemQuyTong), isFalse);
    });

    test('Skill cannot be upgraded beyond maxSkillLevel', () {
      final player = PlayerComponent();
      // Level up to level 6 and grant 10 skill points
      player.expManager.addExp(475);
      for (int i = 0; i < 5; i++) {
        player.expManager.addExp(2000);
      }

      // Upgrade Đánh thường to max (maxSkillLevel = 5)
      for (int i = 1; i < 5; i++) {
        expect(player.upgradeSkill(SkillCatalog.danhThuong), isTrue);
      }
      expect(player.getSkillLevel(SkillCatalog.danhThuong.id), equals(5));

      // At level 5 (max), upgrade returns false
      expect(player.canUpgradeSkill(SkillCatalog.danhThuong), isFalse);
      expect(player.upgradeSkill(SkillCatalog.danhThuong), isFalse);
    });
  });
}
