import '../constants/direction.dart';
import '../constants/player_state.dart';

/// Bộ giải mã đường dẫn tập trung, an toàn kiểu (Type-safe Asset Paths Resolver)
class AssetPaths {
  AssetPaths._();

  // --- BẢN ĐỒ ---
  static const String map1 = 'assets/ban_do/ban_do_1_1254x1254.png';

  // --- NHÂN VẬT CHÍNH ---
  static String characterBody({
    required CharacterState state,
    required GameDirection direction,
  }) {
    final folder = state.folderName;
    final action = state.actionName;
    final dirSuffix = direction.assetSuffix;
    return 'assets/nhan_vat_chinh/$folder/nhan_vat_chinh_${action}_$dirSuffix.png';
  }

  // --- LỚP TRANG BỊ TRÊN NGƯỜI NHÂN VẬT ---
  static String equipmentLayer({
    required String itemIdentifier,
    required CharacterState state,
    required GameDirection direction,
  }) {
    final dirSuffix = direction.assetSuffix;
    switch (state) {
      case CharacterState.idle:
        return 'assets/trang_bi/dung_im/trang_bi_dung_im_$dirSuffix/${itemIdentifier}_dung_im_$dirSuffix.png';
      case CharacterState.move:
        return 'assets/trang_bi/di_chuyen/trang_bi_di_chuyen_$dirSuffix/${itemIdentifier}_di_chuyen_$dirSuffix.png';
      case CharacterState.attack:
        final shortDir = direction.shortSuffix;
        return 'assets/trang_bi/tan_cong/trang_bi_tan_cong_$shortDir/${itemIdentifier}_tan_cong_$dirSuffix.png';
    }
  }

  // --- QUÁI VẬT ---
  static String monster({
    required String monsterAssetName,
    required CharacterState state,
  }) {
    final action = state.actionName;
    return 'assets/quai_vat/${monsterAssetName}_${action}_phia_trai.png';
  }

  // --- ĐIỀU KHIỂN & JOYSTICK ---
  static const String joystickBackground = 'assets/nut_di_chuyen/vong_dieu_khien_64x64.png';
  static const String joystickKnob = 'assets/nut_di_chuyen/nut_dieu_khien_24x24.png';

  // --- NÚT TẤN CÔNG & KỸ NĂNG ---
  static const String attackButton = 'assets/nut_tan_cong/nut_tan_cong_32x32.png';
  static const String skill1Button = 'assets/nut_tan_cong/nut_ki_nang_1_liet_hoa_doat_menh_32x32.png';
  static const String skill2Button = 'assets/nut_tan_cong/nut_ki_nang_2_van_kiem_quy_tong_32x32.png';
  static const String skill3Button = 'assets/nut_tan_cong/nut_ki_nang_3_ho_kiem_phi_kiem_32x32.png';

  // --- HUD & GIAO DIỆN ---
  static const String hudBar = 'assets/hud/thanh_hud_58x22.png';
  static const String expBar = 'assets/hud/thanh_exp_46x9.png';
  static const String panelFrame9Slice = 'assets/hud/khung_bang_lon_9slice_48x48.png';
  static const String inspectFrame9Slice = 'assets/hud/khung_soi_do_9slice_32x32.png';
  static const String button9Slice = 'assets/nut_bam/nut_bam_9slice_48x24.png';
  static const String statPlusButton = 'assets/nut_bam/nut_cong_thuoc_tinh_24x24.png';

  // --- ICONS ---
  static const String iconSkill = 'assets/icons/icon_ki_nang_24x24.png';
  static const String iconInventory = 'assets/icons/icon_ruong_do_24x24.png';
  static const String iconStats = 'assets/icons/icon_thuoc_tinh_24x24.png';

  // --- VẬT PHẨM & RƠI ĐỒ ---
  static const String itemExp = 'assets/vat_pham/vat_pham_kinh_nghiem_16x16.png';
  static const String itemGold = 'assets/vat_pham/vat_pham_vang_16x16.png';
  static const String dropHalo = 'assets/trang_bi_roi/hao_quang_vat_pham_48x48.png';

  // --- HIỆU ỨNG KỸ NĂNG THI TRIỂN ---
  static const String fxBasicSlash = 'assets/ki_nang/thi_trien_tan_cong_thuong_32x32.png';
  static const String fxSkill1Flame = 'assets/ki_nang/thi_trien_ki_nang_1_liet_hoa_doat_menh_32x32.png';
  static const String fxSkill1FlameAnim = 'assets/ki_nang/thi_trien_ki_nang_1_liet_hoa_doat_menh_hoat_anh_1_32x32.png';
  static const String fxSkill2SwordArray = 'assets/ki_nang/thi_trien_ki_nang_2_van_kiem_quy_tong_192x32.png';
  static const String fxSkill3FlyingSword = 'assets/ki_nang/thi_trien_ki_nang_3_ho_kiem_phi_kiem_24x24.png';
  static const String fxShield = 'assets/ki_nang/hieu_ung_khien_64x32.png';
}
