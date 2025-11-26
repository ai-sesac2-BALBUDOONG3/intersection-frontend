// lib/models/user.dart

import 'dart:typed_data';

class User {
  int id;
  String name;
  int birthYear;
  String region;
  String school;

  String? profileImageUrl;        
  String? backgroundImageUrl;     
  List<String> feedImages;

  // 🔥 웹 지원용 (Memory Image)
  Uint8List? profileImageBytes;
  Uint8List? backgroundImageBytes;

  User({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.region,
    required this.school,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.profileImageBytes,
    this.backgroundImageBytes,
    List<String>? feedImages,
  }) : feedImages = feedImages ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      birthYear: json["birth_year"] ?? json["birthYear"] ?? 0,
      region: json["region"],
      school: json["school_name"] ?? json["school"] ?? "",

      profileImageUrl: json["profile_image"],
      backgroundImageUrl: json["background_image"],

      // 🔥 서버는 bytes 안줌 → null 유지
      profileImageBytes: null,
      backgroundImageBytes: null,

      feedImages: json["feed_images"] != null
          ? List<String>.from(json["feed_images"])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "birth_year": birthYear,
      "region": region,
      "school_name": school,
      "profile_image": profileImageUrl,
      "background_image": backgroundImageUrl,
      "feed_images": feedImages,
    };
  }
}
