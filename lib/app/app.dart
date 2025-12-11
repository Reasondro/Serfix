import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/themes/light_mode.dart';
import 'package:serfix/core/services/inference/inference_repository.dart';
import 'package:serfix/core/services/inference/inference_service.dart';
import 'package:serfix/core/services/inference/mock_inference_service.dart';
import 'package:serfix/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:serfix/features/doctor/screening/data/supabase_screening_repository.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';
import 'package:serfix/features/doctor/screening/presentation/cubit/screening_cubit.dart';

// Toggle this to switch between mock and real inference
// Set to false when your FastAPI server is ready
const bool useMockInference = true;

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
  late final InferenceService _inferenceService;
  late final InferenceRepository _inferenceRepository;

  @override
  void initState() {
    super.initState();

    // Initialize inference service
    // TODO: When FastAPI is ready, replace with:
    // _inferenceService = FastApiInferenceService(baseUrl: 'http://your-server:8000');
    if (useMockInference) {
      _inferenceService = MockInferenceService();
    } else {
      // Uncomment when FastAPI is ready:
      // _inferenceService = FastApiInferenceService(
      //   baseUrl: dotenv.env['FASTAPI_BASE_URL'] ?? 'http://localhost:8000',
      // );
      _inferenceService = MockInferenceService(); // Fallback to mock
    }

    _inferenceRepository = InferenceRepository(
      inferenceService: _inferenceService,
    );
  }

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
        RepositoryProvider<InferenceRepository>.value(
          value: _inferenceRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<ScreeningCubit>(
            create: (context) => ScreeningCubit(
              repository: context.read<ScreeningRepository>(),
              inferenceRepository: context.read<InferenceRepository>(),
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
