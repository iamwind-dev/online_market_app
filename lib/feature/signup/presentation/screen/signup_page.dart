import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/signup_cubit.dart';
import '../../../../core/dependency/injection.dart';
import '../../../../core/services/auth/auth_service.dart';

/// Màn hình đăng ký
/// 
/// Chức năng:
/// - Đăng ký với tên, số điện thoại, email và mật khẩu
/// - Validate input
/// - Chuyển sang màn hình đăng nhập
/// - Hiển thị/ẩn mật khẩu
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static const String routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(authService: getIt<AuthService>()),
      child: const SignUpView(),
    );
  }
}

/// View của màn hình đăng ký
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to Product/Home screen after successful registration
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is SignUpFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/splash_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.white.withOpacity(0.3),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo
                    _buildLogo(),
                    
                    const SizedBox(height: 50),
                    
                    // SignUp Form Container
                    _buildSignUpForm(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build logo
  Widget _buildLogo() {
    return Container(
      width: 206,
      height: 91,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/img/splash_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Build signup form container
  Widget _buildSignUpForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF9E4).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0272BA),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab header
            _buildTabHeader(),
            
            const SizedBox(height: 40),
            
            // Email field
            _buildEmailField(),
            
            const SizedBox(height: 20),
            
            // Password field
            _buildPasswordField(),
            
            const SizedBox(height: 20),
            
            // Name field
            _buildNameField(),
            
            
            const SizedBox(height: 40),
            
            // SignUp button
            _buildSignUpButton(),
            
            const SizedBox(height: 24),
            
            // Login link
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  /// Build tab header (Đăng nhập / Đăng ký)
  Widget _buildTabHeader() {
    return Row(
      children: [
        // Đăng nhập tab (inactive)
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to Login page
              Navigator.of(context).pop();
            },
            child: Text(
              'Đăng nhập',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00B40F).withOpacity(0.5),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Đăng ký tab (active)
        Expanded(
          child: Column(
            children: [
              const Text(
                'Đăng ký',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00B40F),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF0606),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build email field
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF0272BA),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              
              // Text field
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Tên đăng nhập hoặc Email*',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF5E5C5C),
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    return context.read<SignUpCubit>().validateEmail(value);
                  },
                ),
              ),
              
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// Build password field
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<SignUpCubit, SignUpState>(
          builder: (context, state) {
            final cubit = context.read<SignUpCubit>();
            final isPasswordVisible = cubit.isPasswordVisible;
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0272BA),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  
                  // Text field
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: const InputDecoration(
                        hintText: 'Mật khẩu*',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF5E5C5C),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        return cubit.validatePassword(value);
                      },
                    ),
                  ),
                  
                  // Toggle visibility button
                  IconButton(
                    onPressed: () {
                      cubit.togglePasswordVisibility();
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build name field
  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0272BA),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          
          // Text field
          Expanded(
            child: TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                hintText: 'Tên*',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5E5C5C),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                return context.read<SignUpCubit>().validateName(value);
              },
            ),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  /// Build signup button
  Widget _buildSignUpButton() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        final isLoading = state is SignUpLoading;
        
        return SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      await context.read<SignUpCubit>().signUp(
                        username: _emailController.text.trim(),
                        password: _passwordController.text,
                        fullName: _nameController.text.trim(),
                        role: 'nguoi_mua',
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B40F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Build login link
  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bạn đã có tài khoản? ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Đăng nhập',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00B40F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
