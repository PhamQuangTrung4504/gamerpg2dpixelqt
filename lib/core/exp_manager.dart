import '../constants/game_constants.dart';

/// Quản lý điểm kinh nghiệm (EXP), thăng cấp và EXP Overflow
class ExpManager {
  int _currentLevel;
  int _currentExp;
  int _skillPoints;

  /// Callback khi nhân vật thăng cấp: level mới, số điểm kỹ năng nhận được
  void Function(int newLevel, int skillPointsGained)? onLevelUp;

  ExpManager({
    int initialLevel = 1,
    int initialExp = 0,
    int initialSkillPoints = 0,
    this.onLevelUp,
  })  : _currentLevel = initialLevel.clamp(GameConstants.minLevel, GameConstants.maxLevel),
        _currentExp = initialExp,
        _skillPoints = initialSkillPoints;

  /// Bảng EXP yêu cầu từ cấp hiện tại lên cấp tiếp theo
  /// Chỉ số index i tương ứng với cấp độ (1 -> 24)
  static const Map<int, int> expTable = {
    1: 20,
    2: 45,
    3: 80,
    4: 130,
    5: 200,
    6: 300,
    7: 430,
    8: 600,
    9: 820,
    10: 1100,
    11: 1450,
    12: 1900,
    13: 2450,
    14: 3100,
    15: 3900,
    16: 4850,
    17: 5950,
    18: 7200,
    19: 8600,
    20: 10500,
    21: 13000,
    22: 16500,
    23: 21000,
    24: 27000,
  };

  int get currentLevel => _currentLevel;
  int get currentExp => _currentExp;
  int get skillPoints => _skillPoints;
  bool get isMaxLevel => _currentLevel >= GameConstants.maxLevel;

  /// Lấy lượng EXP yêu cầu để từ cấp hiện tại lên cấp tiếp theo
  int get expRequiredForNextLevel {
    if (isMaxLevel) return 0;
    return expTable[_currentLevel] ?? 27000;
  }

  /// Tỉ lệ phần trăm tiến trình EXP hiện tại (0.0 đến 1.0)
  double get expProgress {
    if (isMaxLevel) return 1.0;
    final required = expRequiredForNextLevel;
    if (required <= 0) return 1.0;
    return (_currentExp / required).clamp(0.0, 1.0);
  }

  /// Nhận thêm kinh nghiệm với thuật toán EXP Overflow:
  /// Giữ nguyên điểm dư khi vượt mốc và chuyển sang cấp mới.
  void addExp(int amount) {
    if (amount <= 0 || isMaxLevel) return;

    _currentExp += amount;

    // Xử lý thăng cấp (có thể thăng nhiều cấp nếu nhận lượng lớn EXP)
    while (!isMaxLevel && _currentExp >= expRequiredForNextLevel) {
      final required = expRequiredForNextLevel;
      _currentExp -= required; // Chuyển phần dư sang mốc mới
      _currentLevel++;
      _skillPoints++; // Thưởng 1 điểm kỹ năng

      onLevelUp?.call(_currentLevel, 1);
    }

    // Nếu đã chạm cấp tối đa, khóa exp ở mức tối đa
    if (isMaxLevel) {
      _currentExp = 0;
    }
  }

  /// Sử dụng điểm kỹ năng
  bool useSkillPoint() {
    if (_skillPoints > 0) {
      _skillPoints--;
      return true;
    }
    return false;
  }

  /// Reset tiến trình
  void reset({int level = 1, int exp = 0, int skillPoints = 0}) {
    _currentLevel = level;
    _currentExp = exp;
    _skillPoints = skillPoints;
  }
}
