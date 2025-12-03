import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intersection/models/user.dart';
import 'package:intersection/screens/image_viewer.dart';

class FriendProfileScreen extends StatelessWidget {
  final User user;

  const FriendProfileScreen({
    super.key,
    required this.user,
  });

  // ==========================================================
  // 🔥 통합 이미지 Provider (웹/모바일 모두 정상 동작)
  // ==========================================================
  ImageProvider buildProvider(String? url, Uint8List? bytes) {
    if (bytes != null) return MemoryImage(bytes); // Web/Mobile 공용
    if (url != null && url.startsWith("http")) return NetworkImage(url);
    if (url != null && !kIsWeb && File(url).existsSync()) {
      return FileImage(File(url));
    }
    return const AssetImage("assets/default_profile.png");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bg = buildProvider(user.backgroundImageUrl, user.backgroundImageBytes);
    final profile = buildProvider(user.profileImageUrl, user.profileImageBytes);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================================
            // 🔥 1) 배경 이미지
            // ==========================================================
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
                        image: bg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // ==========================================================
                // 🔥 2) 프로필 이미지 (중앙)
                // ==========================================================
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
                    child: Hero(
                      tag: "friend-profile-${user.id}",
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profile,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            // ==========================================================
            // 🔥 3) 이름 + 한 줄 정보
            // ==========================================================
            Text(
              user.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              "${user.birthYear}년생 · ${user.school} · ${user.region}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // ==========================================================
            // 🔥 4) 친구 인스타 피드
            // ==========================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "최근 활동",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 게시물 없으면 "게시물이 없습니다" 표시
            if (user.feedImages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Icon(Icons.photo_library_outlined,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "게시물이 없습니다",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: user.feedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final img = user.feedImages[index];
                  final provider = buildProvider(img, null);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ImageViewer(imageUrl: img, bytes: null),
                        ),
                      );
                    },
                    child: Hero(
                      tag: img,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image(
                          image: provider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),

            // ==========================================================
            // 🔥 5) 기본 정보
            // ==========================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 0.6),
                  const SizedBox(height: 20),
                  Text("학교: ${user.school}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("지역: ${user.region}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("${user.birthYear}년생",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
