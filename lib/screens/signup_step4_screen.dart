// lib/screens/signup_step4_screen.dart

import 'package:flutter/material.dart';
import 'package:intersection/data/signup_form_data.dart';
import 'package:intersection/services/api_service.dart';
import 'package:intersection/screens/main_tab_screen.dart';

class SignupStep4Screen extends StatefulWidget {
  final SignupFormData data;

  const SignupStep4Screen({super.key, required this.data});

  @override
  State<SignupStep4Screen> createState() => _SignupStep4ScreenState();
}

class _SignupStep4ScreenState extends State<SignupStep4Screen> {
  // 필수 입력
  late TextEditingController schoolNameController;
  late TextEditingController entryYearController;
  String? selectedSchoolLevel;

  // 선택 입력
  late TextEditingController nicknamesController;
  late TextEditingController memoryKeywordsController;
  late TextEditingController interestsController;

  // 전학 여부
  bool hasTransferInfo = false;
  late TextEditingController transferInfoController;

  bool _isSubmitting = false;

  final List<String> schoolLevels = ['초등학교', '중학교', '고등학교'];

  @override
  void initState() {
    super.initState();

    schoolNameController = TextEditingController(text: widget.data.schoolName);
    entryYearController = TextEditingController(text: widget.data.entryYear);
    selectedSchoolLevel =
        widget.data.schoolLevel.isNotEmpty ? widget.data.schoolLevel : null;

    nicknamesController =
        TextEditingController(text: widget.data.nicknames ?? '');
    memoryKeywordsController =
        TextEditingController(text: widget.data.memoryKeywords ?? '');
    interestsController =
        TextEditingController(text: (widget.data.interests ?? []).join(', '));

    hasTransferInfo = widget.data.transferInfo?.isNotEmpty == true;
    transferInfoController =
        TextEditingController(text: widget.data.transferInfo ?? '');
  }

  @override
  void dispose() {
    schoolNameController.dispose();
    entryYearController.dispose();
    nicknamesController.dispose();
    memoryKeywordsController.dispose();
    interestsController.dispose();
    transferInfoController.dispose();
    super.dispose();
  }

  bool _isValidYear(String year) {
    final parsed = int.tryParse(year);
    final now = DateTime.now().year;
    return parsed != null && parsed >= 1980 && parsed <= now;
  }

  bool _canProceed() {
    return !_isSubmitting &&
        selectedSchoolLevel != null &&
        schoolNameController.text.isNotEmpty &&
        _isValidYear(entryYearController.text);
  }

  String _mapSchoolLevelToType(String? level) {
    switch (level) {
      case '초등학교':
        return 'elementary';
      case '중학교':
        return 'middle';
      case '고등학교':
        return 'high';
      default:
        return level ?? '';
    }
  }

  Future<void> _submitSignup() async {
    final form = widget.data;

    final birthYear = int.tryParse(form.birthYear);
    final currentYear = DateTime.now().year;

    if (birthYear == null || birthYear < 1900 || birthYear > currentYear) {
      _showError('생년도를 올바르게 입력해주세요.');
      return;
    }

    final admissionYear = int.tryParse(entryYearController.text);
    if (admissionYear == null ||
        admissionYear < 1980 ||
        admissionYear > currentYear) {
      _showError('입학년도를 올바르게 입력해주세요.');
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // 최신 값 form에 반영
    form.schoolLevel = selectedSchoolLevel ?? '';
    form.schoolName = schoolNameController.text.trim();
    form.entryYear = admissionYear.toString();
    form.nicknames = nicknamesController.text.trim().isNotEmpty
        ? nicknamesController.text.trim()
        : null;
    form.memoryKeywords = memoryKeywordsController.text.trim().isNotEmpty
        ? memoryKeywordsController.text.trim()
        : null;
    form.transferInfo = hasTransferInfo &&
            transferInfoController.text.trim().isNotEmpty
        ? transferInfoController.text.trim()
        : null;
    form.interests = interestsController.text
        .split(RegExp(r'[,/]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      // ✅ 1) 회원가입
      await ApiService.register(
        loginId: form.loginId,
        password: form.password,
        realName: form.name,
        nickname: form.primaryNickname,
        email: form.email ?? form.loginId,
      );

      // ✅ 2) 로그인 (토큰 저장)
      await ApiService.login(
        loginId: form.loginId,
        password: form.password,
      );

      // ✅ 3) 온보딩
      final onboardingPayload = {
        "anchor": {
          "school_name": form.schoolName,
          "school_type": _mapSchoolLevelToType(form.schoolLevel),
          "admission_year": admissionYear,
          "base_region": form.baseRegion,
          "nicknames": form.nicknames,
          "memory_keywords": form.memoryKeywords,
          "transfer_info": form.transferInfo,
          "clubs": form.clubs,
        },
        "school_histories": [],
        "keywords": [
          if (form.memoryKeywords != null) form.memoryKeywords,
          if (form.interests != null && form.interests!.isNotEmpty)
            ...form.interests!,
        ].whereType<String>().toList(),
      };

      try {
        await ApiService.onboarding(onboardingPayload);
      } catch (e) {
        debugPrint('온보딩 호출 실패: $e');
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('회원가입 완료'),
          content: const Text('intersection에 오신 것을 환영합니다!\n추천 친구를 확인해볼까요?'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainTabScreen(initialIndex: 1),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('회원가입 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입 - 3단계'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '학교 정보 입력',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  const Text('학교급',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedSchoolLevel,
                    hint: const Text('초/중/고'),
                    items: schoolLevels
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedSchoolLevel = v),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('학교명',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: schoolNameController,
                    decoration: InputDecoration(
                      hintText: '예: OO초등학교',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_city_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('입학년도',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: entryYearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '예: 2010',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_month_outlined),
                      errorText: entryYearController.text.isNotEmpty &&
                              !_isValidYear(entryYearController.text)
                          ? '올바른 연도를 입력해주세요'
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 32),
                  const Divider(height: 32),

                  const Text(
                    '추가 정보 (선택사항)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  const Text('별명들 (선택사항)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nicknamesController,
                    decoration: InputDecoration(
                      hintText: '예: 철수, 공대로봇',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person_pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('기억 키워드 (선택사항)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: memoryKeywordsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: '예: 운동회, 소풍, 학교축제',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.favorite_border),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('관심사 (선택사항)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: interestsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: '예: 만화, 야구, 힙합',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.star_border),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canProceed() ? _submitSignup : null,
                child: Text(_isSubmitting ? '처리 중...' : '회원가입 완료'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
