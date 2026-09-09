import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/core/exp_manager.dart';

void main() {
  group('ExpManager Tests', () {
    test('Initial state: Level 1, 0 EXP, 0 skill points, needs 20 EXP', () {
      final manager = ExpManager();
      expect(manager.currentLevel, equals(1));
      expect(manager.currentExp, equals(0));
      expect(manager.skillPoints, equals(0));
      expect(manager.expRequiredForNextLevel, equals(20));
      expect(manager.expProgress, equals(0.0));
      expect(manager.isMaxLevel, isFalse);
    });

    test('EXP Overflow: 18 / 20 EXP + 10 EXP -> Level 2 with 8 / 45 EXP and 1 skill point', () {
      int levelUpCalls = 0;
      final manager = ExpManager(
        initialLevel: 1,
        initialExp: 18,
        onLevelUp: (newLevel, points) {
          levelUpCalls++;
        },
      );

      manager.addExp(10); // 18 + 10 = 28 -> Level 2 with 8 overflow

      expect(manager.currentLevel, equals(2));
      expect(manager.currentExp, equals(8));
      expect(manager.expRequiredForNextLevel, equals(45));
      expect(manager.skillPoints, equals(1));
      expect(levelUpCalls, equals(1));
    });

    test('Multi-level jump overflow', () {
      // Lv 1->2: 20 EXP
      // Lv 2->3: 45 EXP
      // Total to reach Lv 3 with 5 leftover: 20 + 45 + 5 = 70 EXP
      int levelUpCalls = 0;
      final manager = ExpManager(
        onLevelUp: (newLevel, points) {
          levelUpCalls++;
        },
      );

      manager.addExp(70);

      expect(manager.currentLevel, equals(3));
      expect(manager.currentExp, equals(5));
      expect(manager.expRequiredForNextLevel, equals(80));
      expect(manager.skillPoints, equals(2));
      expect(levelUpCalls, equals(2));
    });

    test('Using skill points', () {
      final manager = ExpManager(initialSkillPoints: 2);
      expect(manager.useSkillPoint(), isTrue);
      expect(manager.skillPoints, equals(1));
      expect(manager.useSkillPoint(), isTrue);
      expect(manager.skillPoints, equals(0));
      expect(manager.useSkillPoint(), isFalse);
    });

    test('Max level boundary at 25', () {
      final manager = ExpManager(initialLevel: 24, initialExp: 26999);
      manager.addExp(1); // 27000 exp reached -> Level 25

      expect(manager.currentLevel, equals(25));
      expect(manager.isMaxLevel, isTrue);
      expect(manager.expRequiredForNextLevel, equals(0));
      expect(manager.expProgress, equals(1.0));

      // Adding more exp at max level should not change level or error
      manager.addExp(1000);
      expect(manager.currentLevel, equals(25));
    });
  });
}
