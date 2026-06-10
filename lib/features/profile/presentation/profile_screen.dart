import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/data/auth_service.dart';
import '../../quote/presentation/cubit/quote_cubit.dart';
import '../../quote/presentation/cubit/quote_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuoteCubit>().fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: AppTextStyles.heading1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
            onPressed: () async => await AuthService().signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildUserPlaceholder(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<QuoteCubit, QuoteState>(
                builder: (context, state) {
                  if (state is QuoteLoading || state is QuoteInitial) {
                    return _buildQuoteSkeleton();
                  }
                  if (state is QuoteLoaded) {
                    return _buildQuoteCard(
                      state.quote.quote,
                      state.quote.author,
                    );
                  }
                  if (state is QuoteError) {
                    return _buildQuoteError();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(String quote, String author) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.primary, width: 1.0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.0),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DAILY QUOTE', style: AppTextStyles.textButton),
              Icon(Icons.format_quote_rounded,
              color: AppColors.primary,
              size: 30,),
          ],),
          const SizedBox(height: 16),
          Text('"${quote}"', style: AppTextStyles.quote),
          const SizedBox(height: 16),
          Text('— $author', style: AppTextStyles.textButton),
        ],
      ),
    );
  }

  Widget _buildQuoteError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.primary, width: 1.0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.0),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DAILY QUOTE', style: AppTextStyles.textButton),
              Icon(Icons.format_quote_rounded,
              color: AppColors.primary,
              size: 30,),
          ],),
          const SizedBox(height: 16),
          Text('"Something went wrong =)"', style: AppTextStyles.quote),
          const SizedBox(height: 16),
          Text('— SERVER', style: AppTextStyles.textButton),
        ],
      ),
    );
  }

  Widget _buildQuoteSkeleton() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildUserPlaceholder() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.surface,
          child: Icon(Icons.person, size: 50, color: AppColors.inactive),
        ),
        const SizedBox(height: 16),
        const Text('Explorer', style: AppTextStyles.heading1),
        Text(
          'user@email.com',
          style: AppTextStyles.bodyInput.copyWith(color: AppColors.inactive),
        ),
      ],
    );
  }
}
