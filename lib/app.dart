import 'package:all_the_counters/app_state/db/snapshots_repository.dart';
import 'package:all_the_counters/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/db/metadata_repository.dart';
import 'package:all_the_counters/screens/main_screen.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: _repositoryProviders(),
        child: _buildApp()
    );
  }

  Widget _buildApp() {
    return MaterialApp(
        title: 'AllTheCounters',
        theme: _theme(),
        darkTheme: _themeDark(),
        home: MainPage(),
        navigatorObservers: [routeObserver]
    );
  }

  List<RepositoryProvider> _repositoryProviders() {
    return [
      RepositoryProvider<CountersRepository>(create: (context) => CountersRepository(context)),
      RepositoryProvider<MetadataRepository>(create: (context) => MetadataRepository(context)),
      RepositoryProvider<SnapshotsRepository>(create: (context) => SnapshotsRepository(context)),
    ];
  }

  ThemeData _themeDark() {
    return ThemeData.dark().copyWith(

        canvasColor: AppColors.darkCanvasColor,
        splashColor: AppColors.swatch.shade700,
        primaryColor: AppColors.swatch.shade500,
        buttonColor: AppColors.swatch.shade500,
        highlightColor: AppColors.swatch.shade900,
        cardColor: Colors.black,

        buttonTheme: ButtonThemeData(
            buttonColor: AppColors.swatch.shade500,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))
        ),

        textTheme: TextTheme(
            button: TextStyle(
                fontFamily: 'OpenSans'
            ),
            headline2: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w100,
            ),
            subtitle2: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
            )
        )
    );
  }

  ThemeData _theme() => ThemeData(
      primarySwatch: AppColors.swatch,
      fontFamily: 'OpenSans',

      canvasColor: Color(0xfff8fbf8),
      splashColor: AppColors.swatch.shade400,
      primaryColor: AppColors.swatch.shade500,
      buttonColor: AppColors.swatch.shade500,
      highlightColor: AppColors.swatch.shade50,
      cardColor: Colors.white,

      buttonTheme: ButtonThemeData(
          buttonColor: AppColors.swatch.shade500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))
      ),

      textTheme: TextTheme(
          button: TextStyle(
              fontFamily: 'OpenSans'
          ),
          headline2: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w100
          ),
          subtitle2: TextStyle(
              color: Color.fromARGB(255, 50, 50, 50),
              fontWeight: FontWeight.bold,
              fontSize: 18
          )
      )
  );
}