import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'cubit/auth_cubit.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords does not matching'), backgroundColor: AppColors.error),
      );
      return;
    }

    context.read<AuthCubit>().signUp(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    const Icon(Icons.map_outlined, size: 80, color: AppColors.primary),
                    const SizedBox(height: 24),
                    const Text(
                      'Account creating',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 48),
                    
                    TextField(
                      controller: _emailController,
                      style: AppTextStyles.bodyInput,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: AppTextStyles.label,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.surface)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: AppTextStyles.bodyInput,
                      decoration: const InputDecoration(
                        labelText: 'Password (min. 6 symbols)',
                        labelStyle: AppTextStyles.label,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.surface)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: AppTextStyles.bodyInput,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        labelStyle: AppTextStyles.label,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.surface)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        prefixIcon: Icon(Icons.lock_clock_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Register', style: AppTextStyles.primaryButton),
                    ),
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('Already have an account? Log in', style: AppTextStyles.textButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}