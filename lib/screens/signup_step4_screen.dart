import 'package:flutter/material.dart';
import '../data/signup_form_data.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../data/app_state.dart';
import '../data/user_storage.dart';
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
    return selectedSchoolLevel != null &&
        schoolNameController.text.isNotEmpty &&
        _isValidYear(entryYearController.text);
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

    // 서버로 보낼 payload
    final payload = {
      'email': form.loginId,
      'password': form.password,
      'name': form.name,
      'birth_year': birthYear,
      'gender': form.gender,
      'region': form.baseRegion,
      'school_name': schoolNameController.text,
      'school_type': selectedSchoolLevel,
      'admission_year': admissionYear,
    };

    try {
      // 1) 회원가입 요청
      final signupResult = await ApiService.signup(payload);

      // 2) 서버에서 준 유저 정보로 User 생성
      final newUser = User.fromJson(signupResult);

      // 3) 로그인 처리
      final token = await ApiService.login(form.loginId, form.password);

      // 4) 메모리 저장
      AppState.login(token, newUser);

      // 5) 로컬 저장 (자동로그인)
      await UserStorage.saveToken(token);
      await UserStorage.saveUser(newUser);

      if (!mounted) return;

      // 6) 완료 팝업
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('회원가입 완료'),
          content: const Text('intersection에 오신 것을 환영합니다!'),
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
    } catch (e) {
      _showError(e.toString());
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
        title: const Text('회원가입 - 4단계'),
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

                  const Text('학교급', style: TextStyle(fontWeight: FontWeight.w600)),
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

                  const Text('학교명', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
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
                child: const Text('회원가입 완료'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
