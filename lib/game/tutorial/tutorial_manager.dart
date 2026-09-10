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

/// Các giai đoạn trong kịch bản mở đầu tân thủ (Linear Tutorial Sequence - 5 giai đoạn)
enum PrologueStep {
  none,
  // Giai đoạn 1: Già Làng & Lia Camera
  elderDialogue,          // 1.1 Già Làng nói chuyện qua hộp thoại Typewriter, quái đứng im
  cameraPan,              // 1.2 Lia camera sang 4 Slime (1.5s), nhìn (1.0s), lia về Player (1.5s)
  // Giai đoạn 2: Tiêu Diệt Quái & Nhặt Kiếm Gỗ
  combat,                 // 2.1 Chiến đấu tiêu diệt 4 Slime
  pickupSword,            // 2.2 Nhặt Kiếm Gỗ 100% rơi từ con Slime cuối
  // Giai đoạn 3: Hướng Dẫn Trang Bị Vũ Khí
  openInventory,          // 3.1 Mũi tên chỉ icon Rương Đồ góc trên bên phải
  equipSword,             // 3.2 Mở Túi Đồ, chỉ Kiếm Gỗ & nút "Trang Bị"
  exitInventory,          // 3.3 Đã trang bị Kiếm Gỗ, chỉ nút [X] để đóng Túi Đồ
  // Giai đoạn 4: Hướng Dẫn Nâng Kỹ Năng
  openSkillTree,          // 4.1 Mũi tên chỉ icon Kỹ Năng góc trên bên phải
  upgradeSkill,           // 4.2 Mở Bảng Kỹ Năng, chỉ nút "Học Kỹ Năng / Nâng Cấp"
  exitSkillTree,          // 4.3 Đã nâng kỹ năng, chỉ nút [X] để đóng Bảng Kỹ Năng
  // Giai đoạn 5: Hướng Dẫn Nâng Thuộc Tính & Vào Trận
  openStats,              // 5.1 Mũi tên chỉ icon Thuộc Tính góc trên bên phải
  upgradeStats,           // 5.2 Mở Bảng Thuộc Tính, chỉ các nút [+]
  exitStats,              // 5.3 Đã cộng điểm, chỉ nút [X] để đóng Bảng Thuộc Tính
  completed,              // Hoàn tất tân thủ, kích hoạt spawner và timer sinh tồn!
}

enum _CameraPanPhase {
  none,
  panToSlimes,
  observeSlimes,
  panToPlayer,
}

/// Bộ điều phối cốt truyện và hướng dẫn tân thủ
class TutorialManager extends Component with HasGameReference<SurvivalGame>, ChangeNotifier {
  PrologueStep _currentStep = PrologueStep.none;
  String _currentHintText = '';
  String? _levelUpHint;

  VillageElderNpcComponent? _elderNpc;
  final List<MonsterComponent> _tutorialSlimes = [];
  Vector2 _lastSlimeDeathPosition = Vector2.zero();
  Vector2 _clusterCenter = Vector2.zero();

  // Biến điều khiển lia camera
  _CameraPanPhase _cameraPanPhase = _CameraPanPhase.none;
  double _cameraPanTimer = 0.0;
  Vector2 _panStartPos = Vector2.zero();
  Vector2 _panTargetPos = Vector2.zero();

  PrologueStep get currentStep => _currentStep;
  String get currentHintText => _currentHintText;
  String? get levelUpHint => _levelUpHint;
  bool get isTutorialActive => _currentStep != PrologueStep.none && _currentStep != PrologueStep.completed;
  bool get isPanning => _currentStep == PrologueStep.cameraPan;
  List<MonsterComponent> get tutorialSlimes => List.unmodifiable(_tutorialSlimes);

  /// Bắt đầu kịch bản tân thủ: Giai đoạn 1 - Già Làng xuất hiện nói chuyện
  void start() {
    _currentStep = PrologueStep.elderDialogue;
    _currentHintText = '';

    final playerPos = game.player.position;

    // 1. Thêm NPC Già Làng đứng cạnh người chơi
    _elderNpc = VillageElderNpcComponent(
      position: playerPos + Vector2(40, -10),
    );
    game.world.add(_elderNpc!);

    // 2. Tạo 4 con Slime Cấp 1 xuất hiện phía trước mặt người chơi
    _clusterCenter = playerPos + Vector2(180, 0);
    final offsets = [
      Vector2(-20, -20),
      Vector2(20, -20),
      Vector2(-20, 20),
      Vector2(20, 20),
    ];

    final slimeData = MonsterCatalog.getByLevel(1) ?? MonsterCatalog.all.first;
    _tutorialSlimes.clear();

    for (int i = 0; i < 4; i++) {
      final spawnPos = _clusterCenter + offsets[i];
      final slime = MonsterComponent(
        monsterData: slimeData,
        initialPosition: spawnPos,
      );
      // Quái đứng yên tại chỗ, tuyệt đối không di chuyển lại gần người chơi lúc này
      slime.isAiActive = false;
      _tutorialSlimes.add(slime);
      game.world.add(slime);
    }

    _lastSlimeDeathPosition = _clusterCenter.clone();

    // 3. Mở hộp thoại Già Làng (Typewriter)
    game.overlays.add('PrologueDialogueOverlay');
    notifyListeners();
  }

  /// Khi người chơi đọc xong hộp thoại của Già Làng
  void onDialogueFinished() {
    if (_currentStep == PrologueStep.elderDialogue) {
      _currentStep = PrologueStep.cameraPan;
      _cameraPanPhase = _CameraPanPhase.panToSlimes;
      _cameraPanTimer = 0.0;
      _panStartPos = game.player.position.clone();
      _panTargetPos = _clusterCenter.clone();

      // Tách camera khỏi người chơi để bắt đầu lia mượt
      game.camera.stop();
      notifyListeners();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // --- GIAI ĐOẠN 1.2: LIA CAMERA (CAMERA PAN) ---
    if (_currentStep == PrologueStep.cameraPan) {
      _cameraPanTimer += dt;

      if (_cameraPanPhase == _CameraPanPhase.panToSlimes) {
        // Lia sang cụm 4 con Slime trong 1.5 giây
        final progress = (_cameraPanTimer / 1.5).clamp(0.0, 1.0);
        final curveVal = Curves.easeInOut.transform(progress);
        game.camera.viewfinder.position = _panStartPos + (_panTargetPos - _panStartPos) * curveVal;

        if (progress >= 1.0) {
          _cameraPanPhase = _CameraPanPhase.observeSlimes;
          _cameraPanTimer = 0.0;
        }
      } else if (_cameraPanPhase == _CameraPanPhase.observeSlimes) {
        // Dừng lại 1.0 giây để quan sát lũ quái
        game.camera.viewfinder.position = _panTargetPos;

        if (_cameraPanTimer >= 1.0) {
          _cameraPanPhase = _CameraPanPhase.panToPlayer;
          _cameraPanTimer = 0.0;
        }
      } else if (_cameraPanPhase == _CameraPanPhase.panToPlayer) {
        // Lia trở lại tâm nhân vật trong 1.5 giây
        final progress = (_cameraPanTimer / 1.5).clamp(0.0, 1.0);
        final curveVal = Curves.easeInOut.transform(progress);
        final playerCurrentPos = game.player.position;
        game.camera.viewfinder.position = _panTargetPos + (playerCurrentPos - _panTargetPos) * curveVal;

        if (progress >= 1.0) {
          _cameraPanPhase = _CameraPanPhase.none;
          // Gắn camera bám theo nhân vật
          game.camera.follow(game.player);

          // Già Làng biến mất
          if (_elderNpc != null) {
            _elderNpc!.removeFromParent();
            _elderNpc = null;
          }

          // 4 con Slime kích hoạt AI bắt đầu di chuyển tấn công
          for (final slime in _tutorialSlimes) {
            slime.isAiActive = true;
          }

          // Chuyển sang Giai đoạn 2: Chiến đấu tiêu diệt quái
          _currentStep = PrologueStep.combat;
          _currentHintText = 'Dùng Cần gạt ảo (Joystick) hoặc phím WASD để tiếp cận và nhấn Nút Đánh (hoặc phím Space) để tiêu diệt chúng!';
          game.overlays.add('TutorialHintOverlay');
          notifyListeners();
        }
      }
      return;
    }

    // --- GIAI ĐOẠN 2: CHIẾN ĐẤU VỚI 4 SLIME ---
    if (_currentStep == PrologueStep.combat) {
      _tutorialSlimes.removeWhere((slime) {
        if (slime.isDead || slime.currentHp <= 0 || slime.isRemoving || slime.isRemoved) {
          _lastSlimeDeathPosition = slime.position.clone();
          return true;
        }
        return false;
      });

      if (_tutorialSlimes.isNotEmpty) {
        const combatHint = 'Dùng Cần gạt ảo (Joystick) hoặc phím WASD để tiếp cận và nhấn Nút Đánh (hoặc phím Space) để tiêu diệt chúng!';
        if (_currentHintText != combatHint) {
          _currentHintText = combatHint;
          notifyListeners();
        }
      } else {
        // Toàn bộ 4 Slime đã bị tiêu diệt
        // Đảm bảo người chơi đủ EXP lên thẳng Cấp 2 (1 điểm kỹ năng + 3 điểm tiềm năng)
        if (game.player.expManager.currentLevel < 2) {
          game.player.expManager.addExp(20);
        }

        _currentStep = PrologueStep.pickupSword;
        _currentHintText = 'Nhặt Kiếm Gỗ trên mặt đất!';

        // Sinh Kiếm Gỗ chắc chắn 100% kèm hào quang tại vị trí con quái cuối chết
        final dropSword = DropItemComponent.equipment(
          position: _lastSlimeDeathPosition,
          equipment: EquipmentCatalog.kiemGo,
          onCollectedCallback: _onWoodenSwordCollected,
        );
        game.world.add(dropSword);

        notifyListeners();
      }
    }

    // Theo dõi tự động nếu người chơi mặc kiếm khi đang ở bước equip
    if (_currentStep == PrologueStep.equipSword) {
      if (game.player.equippedItems.containsKey(EquipmentType.sword)) {
        onSwordEquipped();
      }
    }
  }

  /// Giai đoạn 2 -> 3: Người chơi nhặt được Kiếm Gỗ
  void _onWoodenSwordCollected() {
    _currentStep = PrologueStep.openInventory;
    _currentHintText = 'Đã nhặt được Kiếm Gỗ! Hãy mở Rương Đồ để trang bị vũ khí!';
    notifyListeners();
  }

  /// Khi người chơi mở Túi Đồ
  void onInventoryOpened() {
    if (_currentStep == PrologueStep.openInventory) {
      _currentStep = PrologueStep.equipSword;
      _currentHintText = 'Hãy chọn Kiếm Gỗ trong Túi Đồ và nhấn nút "Trang Bị"!';
      notifyListeners();
    }
  }

  /// Giai đoạn 3: Bấm nút "Trang Bị" Kiếm Gỗ thành công
  void onSwordEquipped() {
    if (_currentStep != PrologueStep.exitInventory && _currentStep != PrologueStep.completed) {
      _currentStep = PrologueStep.exitInventory;
      _currentHintText = 'Trang bị thành công! Nhấn [X] để tiếp tục hướng dẫn!';
      notifyListeners();
    }
  }

  /// Giai đoạn 3 -> 4: Đóng Túi Đồ
  void onInventoryClosed() {
    if (_currentStep == PrologueStep.exitInventory ||
        (_currentStep == PrologueStep.equipSword && game.player.equippedItems.containsKey(EquipmentType.sword))) {
      _currentStep = PrologueStep.openSkillTree;
      _currentHintText = 'Bạn có 1 Điểm Kỹ Năng! Hãy mở Bảng Kỹ Năng để học chiêu thức!';
      notifyListeners();
    }
  }

  /// Khi người chơi mở Bảng Kỹ Năng
  void onSkillTreeOpened() {
    if (_currentStep == PrologueStep.openSkillTree) {
      _currentStep = PrologueStep.upgradeSkill;
      _currentHintText = 'Chọn kỹ năng và nhấn nút "Học Kỹ Năng / Nâng Cấp"!';
      notifyListeners();
    }
  }

  /// Giai đoạn 4: Nâng cấp kỹ năng thành công
  void onSkillUpgraded() {
    if (_currentStep == PrologueStep.upgradeSkill) {
      _currentStep = PrologueStep.exitSkillTree;
      _currentHintText = 'Học kỹ năng thành công! Nhấn [X] để tiếp tục hướng dẫn!';
      notifyListeners();
    }
  }

  /// Giai đoạn 4 -> 5: Đóng Bảng Kỹ Năng
  void onSkillTreeClosed() {
    if (_currentStep == PrologueStep.exitSkillTree ||
        (_currentStep == PrologueStep.upgradeSkill && game.player.expManager.skillPoints == 0)) {
      _currentStep = PrologueStep.openStats;
      _currentHintText = 'Bạn có Điểm Tiềm Năng! Mở Bảng Thuộc Tính để gia tăng sức mạnh!';
      notifyListeners();
    }
  }

  /// Khi người chơi mở Bảng Thuộc Tính
  void onStatsOpened() {
    if (_currentStep == PrologueStep.openStats) {
      _currentStep = PrologueStep.upgradeStats;
      _currentHintText = 'Nhấn nút [+] để cộng điểm vào Máu, Sức mạnh hoặc Giáp!';
      notifyListeners();
    }
  }

  /// Giai đoạn 5: Cộng điểm thuộc tính thành công
  void onStatUpgraded() {
    if (_currentStep == PrologueStep.upgradeStats) {
      _currentStep = PrologueStep.exitStats;
      _currentHintText = 'Cộng điểm thành công! Nhấn [X] để hoàn thành tân thủ!';
      notifyListeners();
    }
  }

  /// Giai đoạn 5: Đóng Bảng Thuộc Tính -> Hoàn tất kịch bản tân thủ!
  void onStatsClosed() {
    if (_currentStep == PrologueStep.exitStats ||
        (_currentStep == PrologueStep.upgradeStats && game.player.attributePoints < 3)) {
      completeTutorial();
    }
  }

  /// Hoàn tất toàn bộ kịch bản hướng dẫn tân thủ
  void completeTutorial() {
    if (_currentStep == PrologueStep.completed) return;
    _currentStep = PrologueStep.completed;
    _currentHintText = 'Hoàn thành tân thủ! Bắt đầu hành trình sinh tồn!';
    notifyListeners();

    // Mở cổng kích hoạt bộ sinh quái tự động cho thế giới sinh tồn chính
    game.spawner.isEnabled = true;
    game.spawner.spawnInitialWave(3);
    game.isSurvivalTimerActive = true;

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

  /// Gợi ý thăng cấp chung trong quá trình sinh tồn
  void triggerLevelUpHint() {
    _levelUpHint = 'Thăng cấp! Bạn nhận được điểm nâng cấp. Hãy nhấp vào biểu tượng Kỹ Năng và Thuộc Tính để gia tăng sức mạnh!';
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 7000), () {
      if (_levelUpHint != null) {
        _levelUpHint = null;
        notifyListeners();
      }
    });
  }
}
