import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/screens/main_tab_screen.dart';
import 'package:intersection/screens/signup_step1_screen.dart';
import 'package:intersection/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 로그인 ID (이메일/닉네임/임의 ID 모두 가능)
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text.trim();

    if (loginId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 ID와 비밀번호를 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1) 로그인 → 토큰 획득
      final token = await ApiService.login(loginId, password);

      // 2) 토큰으로 내 정보 조회
      final user = await ApiService.getMyInfo(token);

      // 3) AppState에 반영 (AppState 구현에 맞게 조정)
      AppState.token = token;
      AppState.login(token, user);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4) 메인 탭 화면으로 이동 (기존 구조 유지)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패: $e")),
      );
    }
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _loginIdController,
              decoration: const InputDecoration(
                labelText: "로그인 ID",
                hintText: "intersection ID 또는 이메일",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "비밀번호",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("로그인"),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupStep1Screen(),
                  ),
                );
              },
              child: Text(
                "아직 계정이 없나요? 회원가입",
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
