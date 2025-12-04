import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/user_profile_service.dart';

part 'edit_profile_state.dart';

/// Cubit quản lý logic cho Edit Profile
class EditProfileCubit extends Cubit<EditProfileState> {
  final UserProfileService _profileService = UserProfileService();
  
  EditProfileCubit() : super(EditProfileInitial());

  /// Load thông tin user hiện tại từ API
  Future<void> loadProfile() async {
    emit(EditProfileLoading());

    try {
      final response = await _profileService.getProfile();
      final data = response.data;

      if (isClosed) return;

      emit(EditProfileLoaded(
        maNguoiDung: data.maNguoiDung,
        tenDangNhap: data.tenDangNhap,
        name: data.tenNguoiDung,
        phone: data.sdt ?? '',
        address: data.diaChi ?? '',
        gioiTinh: data.gioiTinh,
        soTaiKhoan: data.soTaiKhoan,
        nganHang: data.nganHang,
        canNang: data.canNang,
        chieuCao: data.chieuCao,
      ));
    } catch (e) {
      if (!isClosed) {
        emit(EditProfileError(message: 'Không thể tải thông tin: $e'));
      }
    }
  }

  /// Cập nhật tên
  void updateName(String name) {
    final currentState = state;
    if (currentState is EditProfileLoaded) {
      emit(currentState.copyWith(name: name));
    }
  }

  /// Cập nhật số điện thoại
  void updatePhone(String phone) {
    final currentState = state;
    if (currentState is EditProfileLoaded) {
      emit(currentState.copyWith(phone: phone));
    }
  }

  /// Cập nhật địa chỉ
  void updateAddress(String address) {
    final currentState = state;
    if (currentState is EditProfileLoaded) {
      emit(currentState.copyWith(address: address));
    }
  }

  /// Cập nhật giới tính
  void updateGioiTinh(String gioiTinh) {
    final currentState = state;
    if (currentState is EditProfileLoaded) {
      emit(currentState.copyWith(gioiTinh: gioiTinh));
    }
  }

  /// Lưu thông tin profile qua API
  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address,
    String? gioiTinh,
    String? soTaiKhoan,
    String? nganHang,
    double? canNang,
    double? chieuCao,
  }) async {
    final currentState = state;
    if (currentState is! EditProfileLoaded) return;

    emit(EditProfileSaving());

    try {
      await _profileService.updateProfile(
        tenNguoiDung: name,
        gioiTinh: gioiTinh ?? currentState.gioiTinh,
        sdt: phone,
        diaChi: address,
        soTaiKhoan: soTaiKhoan ?? currentState.soTaiKhoan,
        nganHang: nganHang ?? currentState.nganHang,
        canNang: canNang ?? currentState.canNang,
        chieuCao: chieuCao ?? currentState.chieuCao,
      );

      if (isClosed) return;

      emit(const EditProfileSaveSuccess(
        message: 'Cập nhật thông tin thành công!',
      ));

      // Reload profile sau khi save
      await loadProfile();
    } catch (e) {
      if (!isClosed) {
        emit(EditProfileError(message: 'Không thể lưu thông tin: $e'));
      }
    }
  }
}
