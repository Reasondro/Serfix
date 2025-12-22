import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/app.dart';
import 'package:serfix/app/routing/routing_service.dart';
import 'package:serfix/app/themes/cubit/theme_cubit.dart';
import 'package:serfix/features/auth/data/supabase_auth_repository.dart';
import 'package:serfix/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_PROJECT_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );

  // Create ThemeCubit and load saved theme
  final ThemeCubit themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  // Create AuthRepository and AuthCubit
  final SupabaseAuthRepository authRepository = SupabaseAuthRepository();
  final AuthCubit authCubit = AuthCubit(authRepository: authRepository);

  // Create router with AuthCubit for redirect logic
  final GoRouter router = RoutingService(authCubit: authCubit).router;

  // Run app
  runApp(App(router: router, authCubit: authCubit, themeCubit: themeCubit));
}
