import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/core/combat_calculator.dart';
import 'package:gamerpg2dpixelqt/game/components/floating_text_component.dart';
import 'package:gamerpg2dpixelqt/game/components/monster_component.dart';
import 'package:gamerpg2dpixelqt/game/components/player_component.dart';
import 'package:gamerpg2dpixelqt/models/monster.dart';
import 'package:gamerpg2dpixelqt/models/skill.dart';

void main() {
  group('Phase 2 - Monster System & Combat Loop Tests', () {
    test('MonsterCatalog contains all 4 species with correct frame sizes and stats', () {
      final slime = MonsterCatalog.getByLevel(1);
      expect(slime, isNotNull);
      expect(slime!.type, MonsterType.slime);
      expect(slime.type.frameSize, 24.0);
      expect(slime.stats.maxHp, 30.0);
      expect(slime.stats.attackPower, 5.0);

      final bat = MonsterCatalog.getByLevel(6);
      expect(bat, isNotNull);
      expect(bat!.type, MonsterType.bat);
      expect(bat.type.frameSize, 24.0);
      expect(bat.stats.maxHp, 110.0);
      expect(bat.moveSpeed, 85.0);

      final wolf = MonsterCatalog.getByLevel(11);
      expect(wolf, isNotNull);
      expect(wolf!.type, MonsterType.wolf);
      expect(wolf.type.frameSize, 24.0);
      expect(wolf.stats.maxHp, 380.0);
      expect(wolf.moveSpeed, 70.0);

      final ghost = MonsterCatalog.getByLevel(20);
      expect(ghost, isNotNull);
      expect(ghost!.type, MonsterType.ghost);
      expect(ghost.type.frameSize, 32.0);
      expect(ghost.stats.maxHp, 1600.0);
      expect(ghost.moveSpeed, 55.0);
    });

    test('MonsterComponent initialization and taking damage / dying', () {
      final monsterData = MonsterCatalog.getByLevel(1)!;
      final monster = MonsterComponent(
        monsterData: monsterData,
        initialPosition: Vector2(100, 100),
      );

      expect(monster.anchor, Anchor.center);
      expect(monster.size, Vector2.all(24.0));
      expect(monster.currentHp, 30.0);
      expect(monster.isDead, isFalse);

      // Nhận 10 sát thương
      monster.takeDamage(10.0);
      expect(monster.currentHp, 20.0);
      expect(monster.isDead, isFalse);

      // Nhận sát thương kết liễu
      monster.takeDamage(25.0);
      expect(monster.currentHp, 0.0);
      expect(monster.isDead, isTrue);
    });

    test('Player active skills, MP consumption and Cooldown management', () {
      final player = PlayerComponent(unlockAllSkills: true);
      expect(player.currentMp, 100.0);
      expect(player.attackCooldownRemaining, 0.0);
      expect(player.skill1CooldownRemaining, 0.0);
      expect(player.skill2CooldownRemaining, 0.0);
      expect(player.skill3CooldownRemaining, 0.0);

      // 1. Đòn đánh thường (Tiêu hao 0 MP, hồi chiêu 0.4s)
      final attackSuccess = player.performAttack();
      expect(attackSuccess, isTrue);
      expect(player.attackCooldownRemaining, greaterThan(0.0));
      // Ra đòn liên tiếp khi chưa hồi chiêu -> false
      expect(player.performAttack(), isFalse);

      // 2. Kỹ năng 1 - Liệt Hỏa Đoạt Mệnh (Tiêu hao 12 MP, hồi chiêu 3.5s)
      final s1Success = player.useSkill1();
      expect(s1Success, isTrue);
      expect(player.currentMp, 88.0); // 100 - 12
      expect(player.skill1CooldownRemaining, 3.5);
      expect(player.useSkill1(), isFalse);

      // 3. Kỹ năng 2 - Vạn Kiếm Quy Tông (Tiêu hao 30 MP, hồi chiêu 7.0s)
      final s2Success = player.useSkill2();
      expect(s2Success, isTrue);
      expect(player.currentMp, 58.0); // 88 - 30
      expect(player.skill2CooldownRemaining, 7.0);
      expect(player.useSkill2(), isFalse);

      // 4. Kỹ năng 3 - Ngự Kiếm Hộ Thể (Tiêu hao 60 MP -> hiện còn 58 MP không đủ)
      expect(player.useSkill3(), isFalse);

      // Hồi mana cho đủ 60
      player.healMp(20.0);
      expect(player.currentMp, 78.0);
      final s3Success = player.useSkill3();
      expect(s3Success, isTrue);
      expect(player.currentMp, 18.0); // 78 - 60
      expect(player.skill3CooldownRemaining, 12.0);

      // 5. Kiểm tra thời gian hồi chiêu giảm theo dt
      player.update(1.0);
      expect(player.attackCooldownRemaining, 0.0); // 0.4s - 1.0s <= 0
      expect(player.skill1CooldownRemaining, 2.5); // 3.5s - 1.0s
      expect(player.skill2CooldownRemaining, 6.0); // 7.0s - 1.0s
      expect(player.skill3CooldownRemaining, 11.0); // 12.0s - 1.0s
    });

    test('Temporary Buff increases defense and crit resistance and expires correctly', () {
      final player = PlayerComponent();
      final baseDefense = player.stats.defense;
      final baseCritRes = player.stats.critResistance;

      // Áp dụng buff +15 Giáp, +5 Kháng chí mạng trong 3 giây
      player.applyTemporaryBuff(
        extraArmor: 15.0,
        extraCritResistance: 5.0,
        duration: 3.0,
      );

      expect(player.stats.defense, baseDefense + 15.0);
      expect(player.stats.critResistance, baseCritRes + 5.0);

      // Cập nhật 2 giây -> buff vẫn còn
      player.update(2.0);
      expect(player.stats.defense, baseDefense + 15.0);

      // Cập nhật thêm 1.5 giây -> buff hết hạn, hoàn về chỉ số gốc
      player.update(1.5);
      expect(player.stats.defense, baseDefense);
      expect(player.stats.critResistance, baseCritRes);
    });

    test('Drop item and player wallet/exp collection', () {
      final player = PlayerComponent();
      expect(player.gold, 0);

      player.addGold(50);
      expect(player.gold, 50);

      player.addGold(25);
      expect(player.gold, 75);

      player.expManager.addExp(20);
      expect(player.expManager.currentLevel, greaterThanOrEqualTo(2));
    });

    test('CombatCalculator correctly damages monsters with player skills', () {
      final player = PlayerComponent();
      final slime = MonsterCatalog.getByLevel(1)!;

      // Đánh thường
      final normalHit = CombatCalculator.calculateDamage(
        attacker: player.stats,
        defender: slime.stats,
        skillData: SkillCatalog.danhThuong.getDataForLevel(1),
        forceCrit: false,
        forceDodge: false,
      );
      expect(normalHit.damageDealt, greaterThanOrEqualTo(10.0));
      expect(normalHit.isDodged, isFalse);

      // Liệt Hỏa Đoạt Mệnh (140% + 20)
      final s1Hit = CombatCalculator.calculateDamage(
        attacker: player.stats,
        defender: slime.stats,
        skillData: SkillCatalog.lietHoaDoatMenh.getDataForLevel(1),
        forceCrit: false,
        forceDodge: false,
      );
      // 10 * 1.4 + 20 = 34
      expect(s1Hit.damageDealt, greaterThanOrEqualTo(34.0));
    });

    test('FloatingTextComponent factories create valid configurations', () {
      final dmgText = FloatingTextComponent.damage(
        position: Vector2(100, 100),
        amount: 45.0,
        isCrit: true,
      );
      expect(dmgText.text, 'CRIT! -45');
      expect(dmgText.fontSize, 14.0);

      final missText = FloatingTextComponent.miss(position: Vector2(100, 100));
      expect(missText.text, 'MISS');

      final healText = FloatingTextComponent.heal(position: Vector2(100, 100), amount: 15.0);
      expect(healText.text, '+15 HP');

      final manaText = FloatingTextComponent.mana(position: Vector2(100, 100), amount: 8.0);
      expect(manaText.text, '+8 MP');
    });
  });
}
