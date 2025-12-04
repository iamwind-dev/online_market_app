import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_state.dart';

class SellerUserCubit extends Cubit<SellerUserState> {
  SellerUserCubit() : super(SellerUserState.initial());

  /// Khởi tạo và load thông tin người bán
  Future<void> loadUserInfo() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data theo Figma design
      const mockSellerInfo = SellerInfo(
        id: '1',
        fullName: 'Nguyễn Ngọc Phương Nhi',
        phoneNumber: '039821031',
        bankName: 'AB BANK',
        accountNumber: '0397521031',
        marketName: 'Bắc Mỹ An',
        stallNumber: 'STK12',
        categories: ['Cá', 'thịt', 'rau', 'gà', 'ốc'],
        avatarUrl: 'assets/img/seller_home_avatar.png',
      );

      emit(state.copyWith(
        isLoading: false,
        sellerInfo: mockSellerInfo,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông tin: ${e.toString()}',
      ));
    }
  }

  /// Chỉnh sửa thông tin cá nhân
  void editPersonalInfo() {
    // TODO: Navigate to edit personal info screen
  }

  /// Chỉnh sửa thông tin chợ
  void editMarketInfo() {
    // TODO: Navigate to edit market info screen
  }

  /// Chỉnh sửa số lô
  void editStallNumber() {
    // TODO: Navigate to edit stall screen
  }

  /// Chỉnh sửa số tài khoản
  void editAccountNumber() {
    // TODO: Navigate to edit account screen
  }

  /// Chỉnh sửa ngân hàng
  void editBankInfo() {
    // TODO: Navigate to edit bank screen
  }

  /// Chỉnh sửa số điện thoại
  void editPhoneNumber() {
    // TODO: Navigate to edit phone screen
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      // Simulate logout API call
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Clear user session and navigate to login
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Không thể đăng xuất: ${e.toString()}',
      ));
    }
  }

  /// Quay lại
  void goBack() {
    // TODO: Navigate back
  }

  /// Chuyển tab bottom navigation
  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  /// Refresh dữ liệu
  Future<void> refreshData() async {
    await loadUserInfo();
  }
}
