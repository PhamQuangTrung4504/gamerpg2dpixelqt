import 'dart:math';
import 'package:flame/components.dart';
import '../constants/game_constants.dart';
import '../models/monster.dart';
import 'components/monster_component.dart';
import 'survival_game.dart';

/// Bộ điều phối sinh quái vật tự động (Monster Spawner) theo tiến trình người chơi
class MonsterSpawnerComponent extends Component with HasGameReference<SurvivalGame> {
  static const double spawnInterval = 1.8; // Cứ 1.8 giây thử sinh quái một lần
  static const int maxMonstersOnMap = 25; // Giới hạn số lượng quái để tối ưu 60 FPS
  static const double minSpawnDistance = 300.0;
  static const double maxSpawnDistance = 450.0;

  double _timer = 0.0;
  final Random _rng = Random();

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    if (_timer >= spawnInterval) {
      _timer = 0.0;
      _trySpawnMonster();
    }
  }

  void _trySpawnMonster() {
    final currentMonsters = game.world.children.whereType<MonsterComponent>().toList();
    if (currentMonsters.length >= maxMonstersOnMap) {
      return;
    }

    final player = game.player;
    final playerPos = player.position;

    // 1. Tính toán vị trí sinh ngẫu nhiên ở viền ngoài tầm nhìn (300px - 450px)
    final angle = _rng.nextDouble() * 2 * pi;
    final distance = minSpawnDistance + _rng.nextDouble() * (maxSpawnDistance - minSpawnDistance);
    final spawnX = (playerPos.x + cos(angle) * distance).clamp(32.0, GameConstants.mapWidth - 32.0);
    final spawnY = (playerPos.y + sin(angle) * distance).clamp(32.0, GameConstants.mapHeight - 32.0);
    final spawnPos = Vector2(spawnX, spawnY);

    // 2. Xác định cấp độ quái dựa trên cấp độ người chơi (cho phép dao động nhẹ +-1 cấp)
    final playerLevel = player.expManager.currentLevel;
    final variance = _rng.nextInt(3) - 1; // -1, 0, 1
    final targetLevel = (playerLevel + variance).clamp(1, 25);

    final monsterData = MonsterCatalog.getByLevel(targetLevel) ?? MonsterCatalog.all.first;

    // 3. Tạo quái và thêm vào World
    final monster = MonsterComponent(
      monsterData: monsterData,
      initialPosition: spawnPos,
    );
    game.world.add(monster);
  }

  /// Sinh ngay lập tức một đợt quái ban đầu quanh người chơi
  void spawnInitialWave(int count) {
    for (int i = 0; i < count; i++) {
      _trySpawnMonster();
    }
  }
}
