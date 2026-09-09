import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import '../../constants/equipment_types.dart';
import '../../models/equipment.dart';
import '../../models/monster.dart';
import '../components/drop_item_component.dart';
import '../components/monster_component.dart';
import '../components/npc/village_elder_npc.dart';
import '../survival_game.dart';

/// Các giai đoạn trong kịch bản mở đầu tân thủ (Prologue / Tutorial)
enum PrologueStep {
  none,
  dialogue,      // 1. Gặp Trưởng Làng & nghe câu chuyện
  cameraPan,     // 2. Lia camera xem 4 con Slime đầu tiên
  combat,        // 3. Hướng dẫn di chuyển và chiến đấu tiêu diệt 4 Slime
  pickupSword,   // 4a. Nhặt Kiếm Gỗ 100% rơi từ con Slime cuối
  equipSword,    // 4b. Mở túi đồ và trang bị Kiếm Gỗ (mũi tên chỉ dẫn)
  completed,     // Hoàn tất, kích hoạt bộ sinh quái sinh tồn vô tận
}

/// Bộ điều phối cốt truyện và hướng dẫn tân thủ
class TutorialManager extends Component with HasGameReference<SurvivalGame>, ChangeNotifier {
  PrologueStep _currentStep = PrologueStep.none;
  String _currentHintText = '';

  VillageElderNpcComponent? _elderNpc;
  final List<MonsterComponent> _tutorialSlimes = [];
  Vector2 _lastSlimeDeathPosition = Vector2.zero();

  // Biến phục vụ cinematic lia Camera
  double _panTimer = 0.0;
  Vector2 _panStart = Vector2.zero();
  Vector2 _panTarget = Vector2.zero();
  bool _isPanning = false;

  PrologueStep get currentStep => _currentStep;
  String get currentHintText => _currentHintText;
  bool get isTutorialActive => _currentStep != PrologueStep.none && _currentStep != PrologueStep.completed;
  bool get isPanning => _isPanning;
  List<MonsterComponent> get tutorialSlimes => List.unmodifiable(_tutorialSlimes);

  /// Bắt đầu kịch bản tân thủ
  void start() {
    _currentStep = PrologueStep.dialogue;
    _currentHintText = '';

    // 1. Tạo NPC Trưởng Làng đứng cạnh người chơi
    _elderNpc = VillageElderNpcComponent(
      position: game.player.position + Vector2(40, -10),
    );
    game.world.add(_elderNpc!);

    // 2. Mở Hộp thoại cốt truyện Trưởng Làng
    game.overlays.add('PrologueDialogueOverlay');
    notifyListeners();
  }

  /// Gọi khi người chơi kết thúc hội thoại với Trưởng Làng
  void onDialogueFinished() {
    _currentStep = PrologueStep.cameraPan;
    notifyListeners();

    // 1. Tạo 4 con Slime Cấp 1 theo cụm cách người chơi ~220px
    final playerPos = game.player.position;
    final clusterCenter = playerPos + Vector2(220, -30);

    final offsets = [
      Vector2(-25, -20),
      Vector2(25, -20),
      Vector2(-20, 25),
      Vector2(25, 25),
    ];

    final slimeData = MonsterCatalog.getByLevel(1) ?? MonsterCatalog.all.first;
    _tutorialSlimes.clear();

    for (int i = 0; i < 4; i++) {
      final spawnPos = clusterCenter + offsets[i];
      final slime = MonsterComponent(
        monsterData: slimeData,
        initialPosition: spawnPos,
      );
      _tutorialSlimes.add(slime);
      game.world.add(slime);
    }

    _lastSlimeDeathPosition = clusterCenter.clone();

    // 2. Bắt đầu Cinematic lia Camera
    _panStart = playerPos.clone();
    _panTarget = clusterCenter.clone();
    _panTimer = 0.0;
    _isPanning = true;

    // Tách Camera khỏi Player để điều khiển thủ công
    game.camera.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // --- 1. XỬ LÝ LIA CAMERA (BƯỚC 2) ---
    if (_isPanning) {
      _panTimer += dt;

      if (_panTimer < 1.2) {
        // Giai đoạn 1: Lia từ Player sang tâm quái (1.2s)
        final t = Curves.easeInOutCubic.transform((_panTimer / 1.2).clamp(0.0, 1.0));
        game.camera.viewfinder.position = _panStart + (_panTarget - _panStart) * t;
      } else if (_panTimer < 2.2) {
        // Giai đoạn 2: Giữ yên ở tâm quái để người chơi quan sát (1.0s)
        game.camera.viewfinder.position = _panTarget;
      } else if (_panTimer < 3.4) {
        // Giai đoạn 3: Lia từ tâm quái quay trở lại Player (1.2s)
        final t = Curves.easeInOutCubic.transform(((_panTimer - 2.2) / 1.2).clamp(0.0, 1.0));
        game.camera.viewfinder.position = _panTarget + (_panStart - _panTarget) * t;
      } else {
        // Hoàn tất lia camera -> Khóa lại vào Player và chuyển sang Bước 3
        _isPanning = false;
        game.camera.viewfinder.position = _panStart;
        game.camera.follow(game.player);

        _currentStep = PrologueStep.combat;
        _currentHintText = 'Dùng Cần gạt ảo (Joystick) hoặc phím WASD để tiếp cận kẻ địch!';
        game.overlays.add('TutorialHintOverlay');
        notifyListeners();
      }
      return;
    }

    // --- 2. XỬ LÝ CHIẾN ĐẤU VỚI 4 SLIME (BƯỚC 3) ---
    if (_currentStep == PrologueStep.combat) {
      // Dọn dẹp những con quái đã bị tiêu diệt
      _tutorialSlimes.removeWhere((slime) {
        if (slime.isDead || slime.currentHp <= 0 || slime.isRemoving || slime.isRemoved) {
          _lastSlimeDeathPosition = slime.position.clone();
          return true;
        }
        return false;
      });

      if (_tutorialSlimes.isNotEmpty) {
        // Cập nhật gợi ý: Nếu ở gần quái (<= 120px) thì gợi ý bấm nút tấn công
        double minDistance = double.infinity;
        for (final slime in _tutorialSlimes) {
          final dist = (slime.position - game.player.position).length;
          if (dist < minDistance) {
            minDistance = dist;
          }
        }

        final newHint = minDistance <= 120.0
            ? 'Nhấn Nút Tấn công (hoặc Phím Space) để vung kiếm tiêu diệt chúng!'
            : 'Dùng Cần gạt ảo (Joystick) hoặc phím WASD để tiếp cận kẻ địch!';

        if (_currentHintText != newHint) {
          _currentHintText = newHint;
          notifyListeners();
        }
      } else {
        // Toàn bộ 4 Slime đã bị tiêu diệt -> Bước 4: Rớt Kiếm Gỗ
        _currentStep = PrologueStep.pickupSword;
        _currentHintText = 'Nhặt Kiếm Gỗ trên mặt đất!';

        // Sinh Kiếm Gỗ chắc chắn 100% tại vị trí con quái cuối chết
        final dropSword = DropItemComponent.equipment(
          position: _lastSlimeDeathPosition,
          equipment: EquipmentCatalog.kiemGo,
          onCollectedCallback: _onWoodenSwordCollected,
        );
        game.world.add(dropSword);

        notifyListeners();
      }
    }

    // --- 3. THEO DÕI NGƯỜI CHƠI MẶC TRANG BỊ KIẾM GỖ (BƯỚC 4b) ---
    if (_currentStep == PrologueStep.equipSword) {
      if (game.player.equippedItems.containsKey(EquipmentType.sword)) {
        _completeTutorial();
      }
    }
  }

  /// Gọi khi người chơi nhặt được Kiếm Gỗ
  void _onWoodenSwordCollected() {
    _currentStep = PrologueStep.equipSword;
    _currentHintText = 'Nhặt được Kiếm Gỗ! Mở túi đồ để trang bị ngay!';
    notifyListeners();
  }

  /// Hoàn tất toàn bộ kịch bản hướng dẫn
  void _completeTutorial() {
    _currentStep = PrologueStep.completed;
    _currentHintText = 'Tuyệt vời! Hành trình sinh tồn thực sự bắt đầu ngay bây giờ!';
    notifyListeners();

    // Mở cổng kích hoạt bộ sinh quái tự động cho thế giới sinh tồn chính
    game.spawner.isEnabled = true;
    game.spawner.spawnInitialWave(3);

    // Tự động tắt banner sau 4 giây
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (_currentStep == PrologueStep.completed) {
        _currentStep = PrologueStep.none;
        _currentHintText = '';
        game.overlays.remove('TutorialHintOverlay');
        notifyListeners();
      }
    });
  }
}
