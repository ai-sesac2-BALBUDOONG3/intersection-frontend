// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intersection/data/app_state.dart';
import 'package:intersection/screens/edit_profile_screen.dart';
import 'package:intersection/screens/image_viewer.dart';
import 'package:file_picker/file_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // =====================================================
  // 이미지 Provider (웹/모바일 자동 분기)
  // =====================================================
  ImageProvider buildImageProvider(String? url, Uint8List? bytes) {
    if (bytes != null) return MemoryImage(bytes);
    if (url != null && url.startsWith("http")) return NetworkImage(url);
    if (url != null && !kIsWeb && File(url).existsSync()) {
      return FileImage(File(url));
    }
    return const AssetImage("assets/default_profile.png");
  }

  // =====================================================
  // 이미지 선택 (프로필/배경 공용)
  // =====================================================
  Future<void> _pickImage({required bool isProfile}) async {
    final user = AppState.currentUser!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;
    final file = result.files.first;

    setState(() {
      if (kIsWeb) {
        if (isProfile) {
          user.profileImageBytes = file.bytes;
        } else {
          user.backgroundImageBytes = file.bytes;
        }
      } else {
        if (isProfile) {
          user.profileImageUrl = file.path;
        } else {
          user.backgroundImageUrl = file.path;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.currentUser!;
    final width = MediaQuery.of(context).size.width;

    final bgProvider =
        buildImageProvider(user.backgroundImageUrl, user.backgroundImageBytes);
    final profileProvider =
        buildImageProvider(user.profileImageUrl, user.profileImageBytes);

    return Scaffold(
      appBar: AppBar(
        title: const Text("내 프로필"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =====================================================
            // 🔥 1) 상단 - 배경 + 프로필 (카메라 버튼 제거)
            // =====================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    if (user.backgroundImageUrl != null ||
                        user.backgroundImageBytes != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageViewer(
                            imageUrl: user.backgroundImageUrl,
                            bytes: user.backgroundImageBytes,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: bgProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // 배경 변경 버튼
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: ElevatedButton(
                    onPressed: () => _pickImage(isProfile: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("배경 변경"),
                  ),
                ),

                // 프로필 이미지
                Positioned(
                  bottom: -50,
                  left: width / 2 - 50,
                  child: GestureDetector(
                    onTap: () {
                      if (user.profileImageUrl != null ||
                          user.profileImageBytes != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewer(
                              imageUrl: user.profileImageUrl,
                              bytes: user.profileImageBytes,
                            ),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileProvider,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 90),

            // 🔥 프로필 사진 변경 버튼 (잘 눌리는 구조)
            TextButton.icon(
              onPressed: () => _pickImage(isProfile: true),
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text(
                "프로필 사진 변경",
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            // =====================================================
            // 🔥 2) 기본 정보 텍스트
            // =====================================================
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "${user.birthYear}년생 · ${user.school} · ${user.region}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // 🔥 3) 인스타 스타일 피드
            // =====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "내 피드",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 10),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: user.feedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemBuilder: (context, index) {
                final img = user.feedImages[index];

                final provider = img.startsWith("http")
                    ? NetworkImage(img)
                    : (!kIsWeb && File(img).existsSync())
                        ? FileImage(File(img))
                        : const AssetImage("assets/default_profile.png")
                            as ImageProvider;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageViewer(imageUrl: img),
                      ),
                    );
                  },
                  child: Hero(
                    tag: img,
                    child: Image(
                      image: provider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // =====================================================
            // 🔥 4) 내 정보 + 로그아웃
            // =====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 0.7),
                  const SizedBox(height: 20),

                  Text("학교: ${user.school}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  Text("지역: ${user.region}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  Text("출생연도: ${user.birthYear}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: const Text("프로필 수정"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await AppState.logout();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "로그아웃",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
