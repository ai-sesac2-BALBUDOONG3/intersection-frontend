// lib/models/user.dart
// 백엔드 UserOut 스키마 + 기존 UI 코드 호환용 User 모델
//
// - 다른 화면에서 user.name, user.school, user.region 등을
//   자유롭게 수정할 수 있도록 모든 필드를 mutable(가변)로 유지.
// - profile_screen.dart 에서 사용하는
//   profileImageUrl, backgroundImageUrl, profileImageBytes, backgroundImageBytes
//   setter도 그대로 동작함.

import 'dart:typed_data';

class User {
  // 기본 식별자
  int id;

  /// UI에서 보여줄 이름 (우선순위: nickname > real_name > name)
  String name;

  /// 실제 이름(real_name). 없으면 name과 동일하게 세팅.
  String realName;

  /// 별명 (있을 경우)
  String? nickname;

  /// 생년 (없으면 0으로 세팅)
  int birthYear;

  /// 표시용 지역 문자열 (예: "서울 강동구")
  /// - 우선순위: base_region > "${region_city} ${region_district}" > region
  String region;

  /// 대표 학교명
  String school;

  /// 백엔드 raw base_region 값 (있다면)
  String? baseRegion;

  /// 학교 타입 (예: "elementary", "middle", "high")
  String? schoolType;

  /// 입학년도(admission_year)
  int? admissionYear;

  /// 프로필 / 배경 이미지 URL
  String? profileImageUrl;
  String? backgroundImageUrl;

  /// 피드에 사용될 이미지 URL들
  List<String> feedImages;

  /// 웹에서 임시로 들고 있는 이미지 바이트 (업로드 전 미리보기 등)
  Uint8List? profileImageBytes;
  Uint8List? backgroundImageBytes;

  User({
    required this.id,
    required this.name,
    String? realName,
    this.nickname,
    required this.birthYear,
    required this.region,
    required this.school,
    this.baseRegion,
    this.schoolType,
    this.admissionYear,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.profileImageBytes,
    this.backgroundImageBytes,
    List<String>? feedImages,
  })  : realName = realName ?? name,
        feedImages = feedImages ?? <String>[];

  /// 백엔드 UserOut → User
  factory User.fromJson(Map<String, dynamic> json) {
    // id 매핑
    final int id =
        (json["id"] ?? json["user_id"] ?? json["uid"] ?? 0) as int;

    // 이름/닉네임 매핑
    final String rawRealName =
        (json["real_name"] ?? json["realName"] ?? json["name"] ?? "") as String;
    final String? rawNickname = json["nickname"] as String?;

    final String displayName =
        (rawNickname != null && rawNickname.isNotEmpty)
            ? rawNickname
            : (rawRealName.isNotEmpty ? rawRealName : "사용자");

    // 지역 정보 매핑
    final String? baseRegion = json["base_region"] as String?;
    final String? regionCity = json["region_city"] as String?;
    final String? regionDistrict = json["region_district"] as String?;
    String region = json["region"] as String? ?? "";

    if (baseRegion != null && baseRegion.isNotEmpty) {
      region = baseRegion;
    } else if (regionCity != null && regionCity.isNotEmpty) {
      region = [
        regionCity,
        if (regionDistrict != null && regionDistrict.isNotEmpty)
          regionDistrict,
      ].join(" ");
    }

    // 학교/입학년도 매핑
    final String schoolName =
        (json["school_name"] ??
                json["anchor_school_name"] ??
                json["school"] ??
                "") as String;
    final String? schoolType = json["school_type"] as String?;

    final int birthYear =
        (json["birth_year"] as int?) ??
            (json["birthYear"] as int?) ??
            0;

    final int? admissionYear =
        (json["admission_year"] as int?) ??
            (json["entry_year"] as int?);

    // 이미지/피드 이미지 매핑
    final String? profileImageUrl =
        (json["profile_image_url"] ?? json["profile_image"]) as String?;
    final String? backgroundImageUrl =
        (json["background_image_url"] ?? json["background_image"]) as String?;

    final List<String> feedImages = (json["feed_images"] is List)
        ? List<String>.from(json["feed_images"])
        : <String>[];

    return User(
      id: id,
      name: displayName,
      realName: rawRealName,
      nickname: rawNickname,
      birthYear: birthYear,
      region: region,
      school: schoolName,
      baseRegion: baseRegion,
      schoolType: schoolType,
      admissionYear: admissionYear,
      profileImageUrl: profileImageUrl,
      backgroundImageUrl: backgroundImageUrl,
      profileImageBytes: null,
      backgroundImageBytes: null,
      feedImages: feedImages,
    );
  }

  /// 서버로 보낼 때 사용할 JSON (필요한 필드만 사용)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "real_name": realName,
      "nickname": nickname,
      "birth_year": birthYear,
      "region": region,
      "base_region": baseRegion,
      "school_name": school,
      "school_type": schoolType,
      "admission_year": admissionYear,
      "profile_image_url": profileImageUrl,
      "background_image_url": backgroundImageUrl,
      "feed_images": feedImages,
    };
  }
}
