import 'package:education_app/auth/register/cubit.dart';
import 'package:education_app/student/subsercriptions_cubit.dart';
import 'package:education_app/student/getAllinstrucorsData.dart/cubit.dart';
import 'package:education_app/instructor/InscoursesCubit.dart';
import 'package:education_app/instructor/cubit_of_Materials.dart';
import 'package:education_app/instructor/video_cubit.dart';
import 'package:education_app/notifications/cubit.dart';
import 'package:education_app/settings/cubitofUser.dart';
import 'package:education_app/splash.dart';
import 'package:education_app/student/studentCubit.dart';
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
        startLocale: getValidLocale(savedLanguage, deviceLocale),
        child: const MyApp(),
      ),
    ),
  );
}

/// هذه الدالة تتحقق من اللغة المحفوظة أو لغة الجهاز وتعطي لغة مدعومة
Locale getValidLocale(String? savedLanguage, Locale deviceLocale) {
  if (savedLanguage == 'ar') return const Locale('ar', 'EG');
  if (savedLanguage == 'en') return const Locale('en', 'US');

  if (deviceLocale.languageCode == 'ar') return const Locale('ar', 'EG');
  if (deviceLocale.languageCode == 'en') return const Locale('en', 'US');

  return const Locale('en', 'US'); // fallback لو اللغة مش مدعومة
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => InstructorCoursesCubit()),
        BlocProvider(create: (context) => StudentCubit()),
        BlocProvider(create: (context) => InstructorCubit()),
        BlocProvider(create: (context) => VideoUploadCubit()),
        BlocProvider(create: (context) => MaterialsCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => NotificationCubit()),
        BlocProvider(create: (context) => EnrolledCoursesCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
