// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/screens/signup_step1_screen.dart';

/// 구(舊) 단일 회원가입 화면.
/// 현재는 사용하지 않고, 멀티 스텝(Step1~4) 회원가입을 사용.
/// 혹시 기존 라우트에서 /signup 으로 들어올 수 있으니,
/// 여기서 Step1 화면으로 넘겨주는 역할만 수행한다.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 바로 Step1으로 네비게이션
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SignupStep1Screen(),
        ),
      );
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
