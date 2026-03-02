import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/repositories/backlog_repository.dart';
import 'logic/blocs/backlog_bloc.dart';
import 'presentation/pages/main_screen.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => BacklogRepository(),
      child: BlocProvider(
        create: (context) => BacklogBloc(context.read<BacklogRepository>())..add(LoadBacklogItems()),
        child: MaterialApp(
          title: 'Backlog App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6B4EFF), // A soft purple
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6B4EFF),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          ),
          themeMode: ThemeMode.system,
          home: const MainScreen(),
        ),
      ),
    );
  }
}
