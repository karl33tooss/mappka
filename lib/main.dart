import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mappka/core/network/dio_client.dart';
import 'firebase_options.dart';

import 'core/theme/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/services/location_service.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/map/presentation/cubit/map_cubit.dart';
import 'features/weather/data/weather_api_service.dart';
import 'features/weather/presentation/cubit/weather_cubit.dart';
import 'features/quote/data/quote_api_service.dart';
import 'features/quote/presentation/cubit/quote_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final dioClient = DioClient();
  final authService = AuthService();
  final authCubit = AuthCubit(authService);
  final locationService = LocationService();
  final weatherApiService = WeatherApiService(dioClient);
  final quoteApiService = QuoteApiService(dioClient);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (context) => MapCubit(locationService)),
        BlocProvider(create: (context) => WeatherCubit(weatherApiService)),
        BlocProvider(create: (context) => QuoteCubit(quoteApiService),)
      ],
      child: MappkaApp(authCubit: authCubit),
    ),
  );
}

class MappkaApp extends StatelessWidget {
  final AuthCubit authCubit;

  const MappkaApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(authCubit).router;

    return MaterialApp.router(
      title: 'Mappka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
