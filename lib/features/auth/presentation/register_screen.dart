import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  DateTime? _selectedDate;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _register() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || firstName.isEmpty || lastName.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select your date of birth.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The passwords do not match!'), backgroundColor: AppColors.error),
      );
      return;
    }

    context.read<AuthCubit>().signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          birthDate: _selectedDate!,
        );
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
                    const SizedBox(height: 20),
                    const Icon(Icons.map_outlined, size: 70, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Creating Account',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 32),
                    
                    // First Name Field
                    TextField(
                      controller: _firstNameController,
                      style: AppTextStyles.bodyInput,
                      decoration: const InputDecoration(
                        labelText: "First Name",
                        labelStyle: AppTextStyles.label,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.surface)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last Name Field
                    TextField(
                      controller: _lastNameController,
                      style: AppTextStyles.bodyInput,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: AppTextStyles.label,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.surface)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DOB
                    ListTile(
                      onTap: () => _selectDate(context),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.surface),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      leading: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                      title: Text(
                        _selectedDate == null 
                            ? 'Date of Birth' 
                            : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                        style: _selectedDate == null ? AppTextStyles.label : AppTextStyles.bodyInput,
                      ),
                      trailing: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
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
                    
                    // Password Field
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

                    // Confirm Password Field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: AppTextStyles.bodyInput,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
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
                      child: const Text('Already have an account? Sign in', style: AppTextStyles.textButton),
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