part of 'edit_profile_cubit.dart';

/// Base state cho Edit Profile
abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EditProfileInitial extends EditProfileState {}

/// Loading state
class EditProfileLoading extends EditProfileState {}

/// Loaded state với thông tin user
class EditProfileLoaded extends EditProfileState {
  final String maNguoiDung;
  final String tenDangNhap;
  final String name;
  final String phone;
  final String address;
  final String? gioiTinh;
  final String? soTaiKhoan;
  final String? nganHang;
  final double? canNang;
  final double? chieuCao;

  const EditProfileLoaded({
    required this.maNguoiDung,
    required this.tenDangNhap,
    required this.name,
    required this.phone,
    required this.address,
    this.gioiTinh,
    this.soTaiKhoan,
    this.nganHang,
    this.canNang,
    this.chieuCao,
  });

  @override
  List<Object?> get props => [
        maNguoiDung,
        tenDangNhap,
        name,
        phone,
        address,
        gioiTinh,
        soTaiKhoan,
        nganHang,
        canNang,
        chieuCao,
      ];

  EditProfileLoaded copyWith({
    String? maNguoiDung,
    String? tenDangNhap,
    String? name,
    String? phone,
    String? address,
    String? gioiTinh,
    String? soTaiKhoan,
    String? nganHang,
    double? canNang,
    double? chieuCao,
  }) {
    return EditProfileLoaded(
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      tenDangNhap: tenDangNhap ?? this.tenDangNhap,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      soTaiKhoan: soTaiKhoan ?? this.soTaiKhoan,
      nganHang: nganHang ?? this.nganHang,
      canNang: canNang ?? this.canNang,
      chieuCao: chieuCao ?? this.chieuCao,
    );
  }
}

/// Saving state
class EditProfileSaving extends EditProfileState {}

/// Save success state
class EditProfileSaveSuccess extends EditProfileState {
  final String message;

  const EditProfileSaveSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
