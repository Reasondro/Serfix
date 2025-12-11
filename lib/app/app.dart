import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/themes/light_mode.dart';
import 'package:serfix/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:serfix/features/doctor/screening/data/supabase_screening_repository.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';
import 'package:serfix/features/doctor/screening/presentation/cubit/screening_cubit.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.router,
    required this.authCubit,
  });

  final GoRouter router;
  final AuthCubit authCubit;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ScreeningRepository>(
          create: (_) => SupabaseScreeningRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<ScreeningCubit>(
            create: (context) => ScreeningCubit(
              repository: context.read<ScreeningRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Serfix',
          theme: serfixLightTheme,
          routerConfig: widget.router,
        ),
      ),
    );
  }
}
