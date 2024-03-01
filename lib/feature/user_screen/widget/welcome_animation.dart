import 'package:flutter/material.dart';
import 'package:get_location/core/constant/app_image.dart';
import 'package:lottie/lottie.dart';

class LottieAnimationAudio extends StatefulWidget {
  const LottieAnimationAudio({super.key});

  @override
  State<LottieAnimationAudio> createState() => _LottieAnimationAudioState();
}

class _LottieAnimationAudioState extends State<LottieAnimationAudio>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      ImageAsset.icWelcomeAnimation,
      height: 300,
      width: 300,
      fit: BoxFit.fill,
      repeat: true,
      controller: controller,
      onLoaded: (composition) {
        controller
          ..duration = composition.duration
          ..repeat();

        // debugPrint("Lottie Duration: ${composition.duration}");
      },
    );
  }
}
