import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/pages/splash_page.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/connectivity_banner.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthCubit>()),
        BlocProvider(
          create: (_) => serviceLocator<CreditsCubit>()..fetchCredits(),
        ),
        BlocProvider(create: (_) => serviceLocator<ConnectivityCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillSwap',
      theme: AppTheme.dark(),
      builder: (context, child) {
        return Column(
          children: [
            BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
              builder: (context, state) {
                return ConnectivityBanner(
                  isVisible: state == ConnectivityStatus.disconnected,
                );
              },
            ),
            Expanded(child: child!),
          ],
        );
      },
      home: const SplashPage(),
    );
  }
}

