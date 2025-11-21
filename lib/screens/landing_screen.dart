import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top spacer
            SizedBox(height: screenHeight * 0.08),

            // Logo section
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  'intersection',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          '기억의 교집합',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'intersection',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          '그때의 우리, 지금의 나',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.6,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Button section
            Padding(
              padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup/phone');
                      },
                      child: const Text('기억 꺼내기'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login'); // 🔥 로그인 화면 이동
                      },
                      child: const Text('이미 계정이 있으신가요? 로그인'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
