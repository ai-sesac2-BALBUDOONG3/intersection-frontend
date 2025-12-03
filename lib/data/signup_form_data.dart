// lib/data/signup_form_data.dart
// 회원가입 1~4단계에서 입력한 값을 모아두는 DTO
// → 최종적으로 /auth/register 요청에 들어갈 payload를 만들기 위한 헬퍼 포함.

class SignupFormData {
  // 1단계: 계정 정보
  String loginId = ''; // 이메일 = login_id
  String password = '';

  String phoneNumber = '';
  bool isPhoneVerified = false;

  // 2단계: 기본 프로필
  String name = '';      // 실명(real_name)
  String birthYear = ''; // "1993" 같은 문자열, 서버에는 int로 전송
  String gender = '';    // ex) "male", "female", "other"
  String baseRegion = ''; // ex) "서울 강동구" (백엔드: base_region)

  // 3단계: 학교 / 기억 정보
  String schoolLevel = ''; // ex) "초등학교", "중학교", "고등학교"
  String schoolName = '';
  String entryYear = ''; // 입학년도(문자열), 서버에는 admission_year(int)로 전송

  String? className;
  String? transferInfo;
  String? clubs;
  String? nicknames;       // 별명 여러 개일 수 있음
  String? memoryKeywords;  // 기억 키워드

  // 기타 / 확장 필드
  List<String>? interests;
  String? email; // 기본적으로 loginId(이메일)를 그대로 사용

  // 편의 getter (기존 코드 호환용)
  String get phone => phoneNumber;
  String get userId => loginId;
  String get region => baseRegion;

  SignupFormData();

  // 대표 별명 (백엔드 nickname으로 보낼 값)
  String get primaryNickname {
    if (nicknames == null) return name;
    final raw = nicknames!.trim();
    if (raw.isEmpty) return name;
    final parts = raw.split(RegExp(r'[,/ ]+')).where((e) => e.trim().isNotEmpty);
    if (parts.isEmpty) return name;
    return parts.first.trim();
  }

  // 백엔드 school_type으로 사용할 값 매핑
  String? get schoolTypeForBackend {
    final level = schoolLevel.toLowerCase();
    if (level.contains('초')) return 'elementary';
    if (level.contains('중')) return 'middle';
    if (level.contains('고')) return 'high';
    if (level.isEmpty) return null;
    return level; // 그대로 보내고, 백엔드에서 후처리 가능
  }

  SignupFormData copyWith({
    String? loginId,
    String? password,
    String? phoneNumber,
    bool? isPhoneVerified,
    String? name,
    String? birthYear,
    String? gender,
    String? baseRegion,
    String? schoolLevel,
    String? schoolName,
    String? entryYear,
    String? className,
    String? transferInfo,
    String? clubs,
    String? nicknames,
    String? memoryKeywords,
    List<String>? interests,
    String? email,
  }) {
    final copy = SignupFormData();
    copy.loginId = loginId ?? this.loginId;
    copy.password = password ?? this.password;
    copy.phoneNumber = phoneNumber ?? this.phoneNumber;
    copy.isPhoneVerified = isPhoneVerified ?? this.isPhoneVerified;
    copy.name = name ?? this.name;
    copy.birthYear = birthYear ?? this.birthYear;
    copy.gender = gender ?? this.gender;
    copy.baseRegion = baseRegion ?? this.baseRegion;
    copy.schoolLevel = schoolLevel ?? this.schoolLevel;
    copy.schoolName = schoolName ?? this.schoolName;
    copy.entryYear = entryYear ?? this.entryYear;
    copy.className = className ?? this.className;
    copy.transferInfo = transferInfo ?? this.transferInfo;
    copy.clubs = clubs ?? this.clubs;
    copy.nicknames = nicknames ?? this.nicknames;
    copy.memoryKeywords = memoryKeywords ?? this.memoryKeywords;
    copy.interests = interests ?? this.interests;
    copy.email = email ?? this.email ?? (this.loginId.isNotEmpty ? this.loginId : null);
    return copy;
  }

  /// 화면단 → ApiService.signup()에 넘길 표준 payload (camelCase)
  Map<String, dynamic> toFrontendPayload() {
    return {
      "loginId": loginId,
      "password": password,
      "email": email ?? (loginId.isNotEmpty ? loginId : null),
      "name": name,
      "birthYear": birthYear,
      "gender": gender,
      "baseRegion": baseRegion,
      "schoolLevel": schoolLevel,
      "schoolName": schoolName,
      "entryYear": entryYear,
      "phoneNumber": phoneNumber,
      "isPhoneVerified": isPhoneVerified,
      "className": className,
      "transferInfo": transferInfo,
      "clubs": clubs,
      "nicknames": nicknames,
      "memoryKeywords": memoryKeywords,
      "interests": interests,
    };
  }

  @override
  String toString() {
    return 'SignupFormData('
        'loginId: $loginId, '
        'phoneNumber: $phoneNumber, '
        'name: $name, '
        'gender: $gender, '
        'baseRegion: $baseRegion, '
        'schoolLevel: $schoolLevel, '
        'schoolName: $schoolName, '
        'entryYear: $entryYear, '
        'interests: ${interests ?? []}'
        ')';
  }
}
