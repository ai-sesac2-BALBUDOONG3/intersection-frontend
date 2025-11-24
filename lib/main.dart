import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/data/signup_form_data.dart';

// Screens
import 'package:intersection/screens/landing_screen.dart';
import 'package:intersection/screens/main_tab_screen.dart';
import 'package:intersection/screens/phone_verification_screen.dart';
import 'package:intersection/screens/signup_step1_screen.dart';
import 'package:intersection/screens/signup_step2_screen.dart';
import 'package:intersection/screens/signup_step3_screen.dart';
import 'package:intersection/screens/signup_step4_screen.dart';
import 'package:intersection/screens/recommended_screen.dart';
import 'package:intersection/screens/login_screen.dart';
import 'package:intersection/screens/friends_screen.dart';
import 'package:intersection/screens/comment_screen.dart';
import 'package:intersection/screens/community_write_screen.dart';
import 'package:intersection/screens/report_screen.dart'; // ⭐ 꼭 필요함!

// Models
import 'package:intersection/models/post.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a1a1a),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          foregroundColor: Color(0xFF1a1a1a),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
      ),

      home: AppState.currentUser == null
          ? const LandingScreen()
          : const MainTabScreen(),

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

          case '/signup/step2':
            if (args is SignupFormData) {
              return MaterialPageRoute(
                builder: (_) => SignupStep2Screen(data: args),
              );
            }
            return _errorRoute("회원가입 데이터가 누락되었습니다.");

          case '/signup/step3':
            if (args is SignupFormData) {
              return MaterialPageRoute(
                builder: (_) => SignupStep3Screen(data: args),
              );
            }
            return _errorRoute("회원가입 데이터가 누락되었습니다.");

          case '/signup/step4':
            if (args is SignupFormData) {
              return MaterialPageRoute(
                builder: (_) => SignupStep4Screen(data: args),
              );
            }
            return _errorRoute("회원가입 데이터가 누락되었습니다.");

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

          // ===== 댓글 화면 =====
          case '/comments':
            if (args is Post) {
              return MaterialPageRoute(
                builder: (_) => CommentScreen(post: args),
              );
            }
            return _errorRoute("게시물 정보가 누락되었습니다.");

          // ===== 글쓰기 =====
          case '/write':
            return MaterialPageRoute(
              builder: (_) => const CommunityWriteScreen(),
            );

          // ===== 신고하기 =====
          case '/report':
            if (args is Post) {
              return MaterialPageRoute(
                builder: (_) => ReportScreen(post: args),
              );
            }
            return _errorRoute("게시물 정보가 누락되었습니다.");

          default:
            return _errorRoute("존재하지 않는 페이지입니다.");
        }
      },
    );
  }

  // ⭐ 반드시 클래스 안쪽에 있어야 함
  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
