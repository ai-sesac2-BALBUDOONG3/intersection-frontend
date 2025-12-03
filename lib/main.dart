// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/data/signup_form_data.dart';
import 'package:intersection/data/user_storage.dart';

// 🔥 ApiConfig import (baseUrl 확인용)
import 'config/api_config.dart';

// Screens
import 'package:intersection/screens/landing_screen.dart';
import 'package:intersection/screens/main_tab_screen.dart';
import 'package:intersection/screens/phone_verification_screen.dart';
import 'package:intersection/screens/signup_step1_screen.dart';
import 'package:intersection/screens/signup_step3_screen.dart';
import 'package:intersection/screens/signup_step4_screen.dart';
import 'package:intersection/screens/recommended_screen.dart';
import 'package:intersection/screens/login_screen.dart';
import 'package:intersection/screens/friends_screen.dart';
import 'package:intersection/screens/comment_screen.dart';
import 'package:intersection/screens/community_write_screen.dart';
import 'package:intersection/screens/report_screen.dart';

import 'package:intersection/models/post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------
  // 🔍 현재 앱이 어떤 API baseUrl을 사용하는지 출력
  //  - 콘솔에서 확인용 (문제 해결 후 지워도 됨)
  // --------------------------------------------------------
  // ignore: avoid_print
  print('[DEBUG] ApiConfig.baseUrl = ${ApiConfig.baseUrl}');

  // --------------------------------------------------------
  // 🔥 자동 로그인 복원
  // --------------------------------------------------------
  AppState.token = await UserStorage.loadToken();
  AppState.currentUser = await UserStorage.loadUser();

  runApp(const IntersectionApp());
}

class IntersectionApp extends StatelessWidget {
  const IntersectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'intersection',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black87,
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),

        fontFamily: 'Pretendard',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black54),
          titleLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(color: Colors.black87),
          titleSmall: TextStyle(color: Colors.black54),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black, width: 1.0),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
          hintStyle: const TextStyle(color: Colors.black26),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          // withOpacity(0.1) → withValues 로 대체 (신버전 대응)
          indicatorColor: Colors.black.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.black87, fontSize: 12),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: Colors.black87),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
      ),

      // --------------------------------------------------------
      // 🔥 초기 화면 (자동 로그인 적용)
      // --------------------------------------------------------
      home: AppState.currentUser == null
          ? const LandingScreen()
          : const MainTabScreen(),

      // --------------------------------------------------------
      // 🔥 라우터
      // --------------------------------------------------------
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/signup/phone':
            return MaterialPageRoute(
              builder: (_) => const PhoneVerificationScreen(),
            );

          case '/signup/step1':
            return MaterialPageRoute(
              builder: (_) => const SignupStep1Screen(),
            );

          case '/signup/step3':
            if (args is SignupFormData) {
              return MaterialPageRoute(
                builder: (_) => SignupStep3Screen(data: args),
              );
            }
            return _error("회원가입 데이터가 누락되었습니다.");

          case '/signup/step4':
            if (args is SignupFormData) {
              return MaterialPageRoute(
                builder: (_) => SignupStep4Screen(data: args),
              );
            }
            return _error("회원가입 데이터가 누락되었습니다.");

          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );

          case '/recommended':
            return MaterialPageRoute(
              builder: (_) => const RecommendedFriendsScreen(),
            );

          case '/friends':
            return MaterialPageRoute(
              builder: (_) => const FriendsScreen(),
            );

          // ✅ 댓글 화면: Post 객체 필요
          case '/comments':
            if (args is Post) {
              return MaterialPageRoute(
                builder: (_) => CommentScreen(post: args),
              );
            }
            return _error("게시물 정보가 누락되었습니다.");

          // ✅ 글쓰기 화면
          //  - 지금은 기본값으로 '전체 커뮤니티' 사용
          //  - 나중에 필요하면 arguments 로 communityName / community 넘기면 됨
          case '/write':
            return MaterialPageRoute(
              builder: (_) => const CommunityWriteScreen(
                communityName: '전체 커뮤니티',
              ),
            );

          case '/report':
            if (args is Post) {
              return MaterialPageRoute(
                builder: (_) => ReportScreen(post: args),
              );
            }
            return _error("게시물 정보가 누락되었습니다.");

          default:
            return _error("존재하지 않는 페이지입니다.");
        }
      },
    );
  }

  Route<dynamic> _error(String msg) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("오류")),
        body: Center(
          child: Text(msg),
        ),
      ),
    );
  }
}
