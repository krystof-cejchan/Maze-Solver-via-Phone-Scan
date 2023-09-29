import 'package:camera/camera.dart';

class CameraResolutionPixels {
  final int width, height;
  CameraResolutionPixels({required this.width, required this.height});

  factory CameraResolutionPixels.fromResolutionPreset(ResolutionPreset rp,
      {bool? isIOS}) {
    isIOS ??= false;
    switch (rp) {
      case ResolutionPreset.high:
        return CameraResolutionPixels(width: 1280, height: 720);
      case ResolutionPreset.low:
        return isIOS
            ? CameraResolutionPixels(width: 352, height: 288)
            : CameraResolutionPixels(width: 320, height: 240);
      case ResolutionPreset.medium:
        return isIOS
            ? CameraResolutionPixels(width: 640, height: 480)
            : CameraResolutionPixels(width: 720, height: 480);
      case ResolutionPreset.veryHigh:
        return CameraResolutionPixels(width: 1920, height: 1080);
      default:
        return isIOS
            ? CameraResolutionPixels(width: 640, height: 480)
            : CameraResolutionPixels(width: 720, height: 480);
    }
  }
}
