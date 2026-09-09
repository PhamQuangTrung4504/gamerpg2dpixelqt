import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../core/asset_paths.dart';
import '../../core/game_typography.dart';
import '../survival_game.dart';

/// HUD hiển thị thanh máu (HP), năng lượng (MP), kinh nghiệm (EXP) và các nút kỹ năng
class GameHud extends PositionComponent with HasGameReference<SurvivalGame> {
  bool _isInitialized = false;

  TextComponent? _levelText;
  TextComponent? _hpText;
  TextComponent? _mpText;
  TextComponent? _expText;

  SpriteComponent? _hudBarBg;
  SpriteComponent? _expBarBg;

  // Nút tấn công & kỹ năng & chức năng
  HudActionButton? _attackBtn;
  HudActionButton? _skill1Btn;
  HudActionButton? _skill2Btn;
  HudActionButton? _skill3Btn;
  HudActionButton? _inventoryBtn;
  HudActionButton? _skillTreeBtn;
  HudActionButton? _statsBtn;

  final Paint _hpFillPaint = Paint()..color = const Color(0xFFE53935);
  final Paint _mpFillPaint = Paint()..color = const Color(0xFF1E88E5);
  final Paint _expFillPaint = Paint()..color = const Color(0xFF43A047);
  final Paint _barBgPaint = Paint()..color = const Color(0xFF212121);

  // Tọa độ lề trên trái của cụm HUD (dời sang phải thêm 5px: từ x:16 -> x:21)
  static const double hudOriginX = 21.0;
  static const double hudOriginY = 16.0;
  static const double expOriginX = 21.0;
  static const double expOriginY = 69.0;

  // Kích thước chuẩn tỉ lệ 2.2x cho HUD và 2.6x cho EXP (rộng 120-130px)
  static const double hudWidth = 128.0;
  static const double hudHeight = 48.0;
  static const double expWidth = 120.0;
  static const double expHeight = 23.0;

  // Tọa độ các khe cắm thanh máu/mana/exp (tương đối theo lề mới 21px)
  static const double hpSlotX = 54.0;
  static const double hpSlotY = 25.0;
  static const double hpSlotW = 81.0;
  static const double hpSlotH = 9.0;

  static const double mpSlotX = 54.0;
  static const double mpSlotY = 45.0;
  static const double mpSlotW = 81.0;
  static const double mpSlotH = 9.0;

  static const double expSlotX = 65.0;
  static const double expSlotY = 77.0;
  static const double expSlotW = 60.0;
  static const double expSlotH = 8.0;

  GameHud() : super(priority: 100);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Khung HUD chính (58x22 px -> scale 2.2x = 128x48 px, lề mới x: 21, y: 16)
    final hudSprite = await game.loadSprite(AssetPaths.hudBar);
    _hudBarBg = SpriteComponent(
      sprite: hudSprite,
      position: Vector2(hudOriginX, hudOriginY),
      size: Vector2(hudWidth, hudHeight),
    );
    add(_hudBarBg!);

    // 2. Khung EXP (46x9 px -> scale 2.6x = 120x23 px, ngay dưới HUD chính x: 21, y: 69)
    final expSprite = await game.loadSprite(AssetPaths.expBar);
    _expBarBg = SpriteComponent(
      sprite: expSprite,
      position: Vector2(expOriginX, expOriginY),
      size: Vector2(expWidth, expHeight),
    );
    add(_expBarBg!);

    // 3. Text Level - Căn chính giữa ô badge bên góc trái thanh EXP (tách khỏi cụm icon tím phía trên)
    _levelText = TextComponent(
      text: 'Lv. 1',
      position: Vector2(expOriginX + 22.0, expOriginY + expHeight / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GameTypography.pixel(
          color: const Color(0xFFFFD54F),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(-1, -1)),
          ],
        ),
      ),
    );
    add(_levelText!);

    // 4. Text HP (nằm lọt vào lõi thanh máu)
    _hpText = TextComponent(
      text: '100 / 100',
      position: Vector2(hpSlotX + hpSlotW / 2, hpSlotY + hpSlotH / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GameTypography.pixel(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
        ),
      ),
    );
    add(_hpText!);

    // 5. Text MP (nằm lọt vào lõi thanh năng lượng)
    _mpText = TextComponent(
      text: '100 / 100',
      position: Vector2(mpSlotX + mpSlotW / 2, mpSlotY + mpSlotH / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GameTypography.pixel(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
        ),
      ),
    );
    add(_mpText!);

    // 6. Text EXP (nằm lọt vào lõi thanh exp)
    _expText = TextComponent(
      text: '0 / 20',
      position: Vector2(expSlotX + expSlotW / 2, expSlotY + expSlotH / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GameTypography.pixel(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
        ),
      ),
    );
    add(_expText!);

    // 7. Các nút Tấn công & Kỹ năng (Neo góc dưới bên phải, tăng kích thước 20%)
    final attackSprite = await game.loadSprite(AssetPaths.attackButton);
    final s1Sprite = await game.loadSprite(AssetPaths.skill1Button);
    final s2Sprite = await game.loadSprite(AssetPaths.skill2Button);
    final s3Sprite = await game.loadSprite(AssetPaths.skill3Button);

    _attackBtn = HudActionButton(
      sprite: attackSprite,
      size: Vector2.all(67.0),
      cooldownRemaining: () => game.player.attackCooldownRemaining,
      totalCooldown: 0.40,
      onPressed: () => game.player.performAttack(),
    );

    _skill1Btn = HudActionButton(
      sprite: s1Sprite,
      size: Vector2.all(48.0),
      cooldownRemaining: () => game.player.skill1CooldownRemaining,
      totalCooldown: 3.5,
      onPressed: () => game.player.useSkill1(),
    );

    _skill2Btn = HudActionButton(
      sprite: s2Sprite,
      size: Vector2.all(48.0),
      cooldownRemaining: () => game.player.skill2CooldownRemaining,
      totalCooldown: 7.0,
      onPressed: () => game.player.useSkill2(),
    );

    _skill3Btn = HudActionButton(
      sprite: s3Sprite,
      size: Vector2.all(48.0),
      cooldownRemaining: () => game.player.skill3CooldownRemaining,
      totalCooldown: 12.0,
      onPressed: () => game.player.useSkill3(),
    );

    // 8. Ba nút chức năng góc trên bên phải màn hình (Rương đồ, Kỹ năng, Thuộc tính)
    final chestSprite = await game.loadSprite(AssetPaths.iconInventory);
    _inventoryBtn = HudActionButton(
      sprite: chestSprite,
      size: Vector2.all(36.0),
      onPressed: () => game.openInventory(),
    );

    final skillTreeSprite = await game.loadSprite(AssetPaths.iconSkill);
    _skillTreeBtn = HudActionButton(
      sprite: skillTreeSprite,
      size: Vector2.all(36.0),
      onPressed: () => game.openSkillTree(),
      hasNotification: () => game.player.expManager.skillPoints > 0,
    );

    final statsSprite = await game.loadSprite(AssetPaths.iconStats);
    _statsBtn = HudActionButton(
      sprite: statsSprite,
      size: Vector2.all(36.0),
      onPressed: () => game.openStats(),
      hasNotification: () => game.player.attributePoints > 0,
    );

    add(_attackBtn!);
    add(_skill1Btn!);
    add(_skill2Btn!);
    add(_skill3Btn!);
    add(_statsBtn!);
    add(_skillTreeBtn!);
    add(_inventoryBtn!);

    _isInitialized = true;
    _repositionButtons();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isInitialized) {
      _repositionButtons();
    }
  }

  /// Định vị lại cụm nút tấn công & kỹ năng theo góc dưới phải (bottom-right)
  void _repositionButtons() {
    if (!_isInitialized ||
        _attackBtn == null ||
        _skill1Btn == null ||
        _skill2Btn == null ||
        _skill3Btn == null) {
      return;
    }

    final screenSize = game.size;
    if (screenSize.x <= 0 || screenSize.y <= 0) return;

    // 3 nút chức năng ở góc trên bên phải: xếp thẳng hàng ngang
    // Từ phải sang trái: Rương đồ, Kỹ năng, Thuộc tính
    const topMargin = 20.0;
    const btnSize = 36.0;
    const rightMargin = 24.0;
    const btnGap = 8.0;
    const centerY = topMargin + btnSize / 2; // 38.0

    if (_inventoryBtn != null) {
      _inventoryBtn!.size = Vector2.all(btnSize);
      _inventoryBtn!.position = Vector2(screenSize.x - rightMargin - btnSize / 2, centerY);
    }

    if (_skillTreeBtn != null) {
      _skillTreeBtn!.size = Vector2.all(btnSize);
      _skillTreeBtn!.position = Vector2(screenSize.x - rightMargin - btnSize * 1.5 - btnGap, centerY);
    }

    if (_statsBtn != null) {
      _statsBtn!.size = Vector2.all(btnSize);
      _statsBtn!.position = Vector2(screenSize.x - rightMargin - btnSize * 2.5 - btnGap * 2, centerY);
    }

    // Nút đánh thường: tăng 20% lên 67px, cách mép phải và dưới 42px
    const attackBtnSize = 67.0;
    const attackRadius = attackBtnSize / 2; // 33.5px
    const margin = 42.0;

    final attackCenter = Vector2(
      screenSize.x - margin - attackRadius,
      screenSize.y - margin - attackRadius,
    );

    _attackBtn!.size = Vector2.all(attackBtnSize);
    _attackBtn!.position = attackCenter;

    // 3 nút kỹ năng: tăng 20% lên 48px, xếp hình cánh cung quanh nút tấn công
    const skillBtnSize = 48.0;
    const arcRadius = 82.0; // Bán kính cánh cung cách đều tránh đè viền

    _skill1Btn!.size = Vector2.all(skillBtnSize);
    _skill1Btn!.position = attackCenter + Vector2(-arcRadius, 6);

    _skill2Btn!.size = Vector2.all(skillBtnSize);
    _skill2Btn!.position = attackCenter + Vector2(-arcRadius * 0.707, -arcRadius * 0.707);

    _skill3Btn!.size = Vector2.all(skillBtnSize);
    _skill3Btn!.position = attackCenter + Vector2(6, -arcRadius);
  }

  @override
  void render(Canvas canvas) {
    if (!_isInitialized) return;

    final player = game.player;
    final maxHp = player.stats.maxHp;
    final maxMp = player.stats.maxMp;

    final hpRatio = (maxHp > 0 ? player.currentHp / maxHp : 0.0).clamp(0.0, 1.0);
    final mpRatio = (maxMp > 0 ? player.currentMp / maxMp : 0.0).clamp(0.0, 1.0);
    final expRatio = player.expManager.expProgress;

    // 1. Render lõi thanh máu (vị trí chuẩn xác trong khe HUD)
    final hpBgRect = const Rect.fromLTWH(hpSlotX, hpSlotY, hpSlotW, hpSlotH);
    final hpBarRect = Rect.fromLTWH(hpSlotX, hpSlotY, hpSlotW * hpRatio, hpSlotH);
    canvas.drawRect(hpBgRect, _barBgPaint);
    canvas.drawRect(hpBarRect, _hpFillPaint);

    // 2. Render lõi thanh năng lượng (vị trí chuẩn xác trong khe HUD)
    final mpBgRect = const Rect.fromLTWH(mpSlotX, mpSlotY, mpSlotW, mpSlotH);
    final mpBarRect = Rect.fromLTWH(mpSlotX, mpSlotY, mpSlotW * mpRatio, mpSlotH);
    canvas.drawRect(mpBgRect, _barBgPaint);
    canvas.drawRect(mpBarRect, _mpFillPaint);

    // 3. Render lõi thanh exp
    final expBgRect = const Rect.fromLTWH(expSlotX, expSlotY, expSlotW, expSlotH);
    final expBarRect = Rect.fromLTWH(expSlotX, expSlotY, expSlotW * expRatio, expSlotH);
    canvas.drawRect(expBgRect, _barBgPaint);
    canvas.drawRect(expBarRect, _expFillPaint);

    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!_isInitialized) return;

    super.update(dt);
    final player = game.player;

    _levelText?.text = 'Lv. ${player.expManager.currentLevel}';
    _hpText?.text = '${player.currentHp.toInt()} / ${player.stats.maxHp.toInt()}';
    _mpText?.text = '${player.currentMp.toInt()} / ${player.stats.maxMp.toInt()}';
    if (player.expManager.isMaxLevel) {
      _expText?.text = 'MAX';
    } else {
      _expText?.text = '${player.expManager.currentExp} / ${player.expManager.expRequiredForNextLevel}';
    }
  }
}

/// Nút HUD tương tác có hiệu ứng nhấp và chấm đỏ thông báo
class HudActionButton extends SpriteComponent with TapCallbacks {
  final VoidCallback onPressed;
  final double Function()? cooldownRemaining;
  final double totalCooldown;
  final bool Function()? hasNotification;

  double _blinkTimer = 0.0;
  bool _blinkVisible = true;

  final Paint _cooldownOverlayPaint = Paint()
    ..color = const Color(0x99000000)
    ..style = PaintingStyle.fill;

  final Paint _badgePaint = Paint()
    ..color = const Color(0xFFFF1744)
    ..style = PaintingStyle.fill;

  final Paint _badgeBorderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  HudActionButton({
    required Sprite sprite,
    required Vector2 size,
    required this.onPressed,
    this.cooldownRemaining,
    this.totalCooldown = 1.0,
    this.hasNotification,
  }) : super(
          sprite: sprite,
          size: size,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (hasNotification?.call() == true) {
      _blinkTimer += dt;
      if (_blinkTimer >= 0.4) {
        _blinkTimer = 0.0;
        _blinkVisible = !_blinkVisible;
      }
    } else {
      _blinkVisible = false;
      _blinkTimer = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final cd = cooldownRemaining?.call() ?? 0.0;
    if (cd > 0 && totalCooldown > 0) {
      final ratio = (cd / totalCooldown).clamp(0.0, 1.0);
      // Vẽ lớp phủ bóng mờ bán kính tương ứng tiến trình hồi chiêu
      final rect = Rect.fromLTWH(0, 0, size.x, size.y * ratio);
      canvas.drawRect(rect, _cooldownOverlayPaint);

      // Hiển thị số giây hồi chiêu còn lại
      final cdText = cd >= 1.0 ? cd.toStringAsFixed(0) : cd.toStringAsFixed(1);
      final tp = TextPainter(
        text: TextSpan(
          text: cdText,
          style: GameTypography.pixel(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2),
      );
    }

    // Chấm đỏ thông báo (badge notification) nhấp nháy trên góc phải trên của nút
    if (hasNotification?.call() == true && _blinkVisible) {
      final badgeCenter = Offset(size.x - 4, 4);
      canvas.drawCircle(badgeCenter, 4.5, _badgePaint);
      canvas.drawCircle(badgeCenter, 4.5, _badgeBorderPaint);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if ((cooldownRemaining?.call() ?? 0.0) <= 0) {
      scale = Vector2.all(0.9);
      onPressed();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}
