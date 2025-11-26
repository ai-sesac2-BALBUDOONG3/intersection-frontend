import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String? imageUrl;     // http 또는 local path
  final Uint8List? bytes;     // 웹에서 사용하는 원본 bytes

  const ImageViewer({
    super.key,
    this.imageUrl,
    this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider provider;

    if (bytes != null) {
      // 웹 전용 또는 bytes 지원
      provider = MemoryImage(bytes!);
    } else if (imageUrl != null && imageUrl!.startsWith("http")) {
      provider = NetworkImage(imageUrl!);
    } else if (imageUrl != null && !kIsWeb && File(imageUrl!).existsSync()) {
      provider = FileImage(File(imageUrl!));
    } else {
      provider = const AssetImage("assets/default_profile.png");
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl ?? bytes.hashCode,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image(image: provider),
          ),
        ),
      ),
    );
  }
}
