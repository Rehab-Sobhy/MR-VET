import 'package:education_app/instructor/addCourse.dart';
import 'package:education_app/instructor/coursesCubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:education_app/auth/login/login_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLanguage = prefs.getString('saved_language');

  Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

  runApp(
    OverlaySupport.global(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
        path: 'assets/localization',
        fallbackLocale: const Locale('en', 'US'),
        startLocale: savedLanguage == 'ar'
            ? const Locale('ar', 'EG')
            : savedLanguage == 'en'
                ? const Locale('en', 'US')
                : deviceLocale,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => CoursesCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: AddCourseScreen(),
        ),
      ),
    );
  }
}
