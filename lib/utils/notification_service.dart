import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    if (token != null) {
      //await ApiService.sendFcmToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      //ApiService.sendFcmToken(token);
    });
  }
}
