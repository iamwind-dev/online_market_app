import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'signup_state.dart';

/// SignUp Cubit quản lý logic nghiệp vụ của màn hình đăng ký
/// 
/// Chức năng chính:
/// - Xử lý đăng ký với tên, số điện thoại, email và mật khẩu
/// - Validate input
/// - Quản lý trạng thái hiển thị mật khẩu
/// - Xử lý lỗi và hiển thị thông báo
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  /// Toggle hiển thị/ẩn mật khẩu
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    emit(SignUpPasswordVisibilityChanged(isPasswordVisible: _isPasswordVisible));
  }

  /// Validate tên
  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Vui lòng nhập tên';
    }
    
    if (name.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    
    return null;
  }

  /// Validate số điện thoại
  String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    
    // Vietnamese phone number regex
    final phoneRegex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');
    
    if (!phoneRegex.hasMatch(phone)) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }

  /// Validate email
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Vui lòng nhập email';
    }
    
    // Simple email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }

  /// Validate password
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    
    return null;
  }

  /// Xử lý đăng ký
  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    // Validate inputs
    final nameError = validateName(name);
    final phoneError = validatePhone(phone);
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (nameError != null || phoneError != null || emailError != null || passwordError != null) {
      emit(SignUpValidationError(
        nameError: nameError,
        phoneError: phoneError,
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    try {
      emit(SignUpLoading());

      // TODO: Implement actual signup API call
      // Example:
      // final response = await authRepository.signUp(
      //   name: name,
      //   phone: phone,
      //   email: email,
      //   password: password,
      // );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock signup logic - Replace with actual implementation
      // For demo, always succeed
      emit(const SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(
        errorMessage: 'Đã có lỗi xảy ra: ${e.toString()}',
      ));
    }
  }

  /// Reset state về initial
  void resetState() {
    emit(SignUpInitial());
  }
}
