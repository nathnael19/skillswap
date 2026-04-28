import 'package:permission_handler/permission_handler.dart';

class EssentialPermissionsService {
  EssentialPermissionsService._();

  static Future<void> requestCorePermissions() async {
    await [
      Permission.microphone,
      Permission.camera,
      Permission.notification,
    ].request();
  }
}
