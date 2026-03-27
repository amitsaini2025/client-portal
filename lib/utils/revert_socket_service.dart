import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:client/models/workflow_send_message_response.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ReverbSocketService {
  static WebSocketChannel? _channel;
  static Timer? _reconnectTimer;
  static bool _isConnected = false;

  static Function(MessageDetail message)? onMessageReceived;

  static const String _appId = "952b2edc3f42e289";
  static const String _appKey = "145cd98cfea9f69732ae6755ac889bcc";
  static const String _host = "revapi.bansalcrm.com";
  static const int _port = 443;
  static const String _scheme = "wss";

  static String get _url =>
      "$_scheme://$_host:$_port/app/$_appKey?protocol=7&client=flutter";

  static String get _authUrl =>
      "https://$_host/reverb/broadcasting/auth";

  static Future<void> connect({
    required String userId,
    required String token,
  }) async {
    try {
      log("🔌 Connecting to: $_url");

      _channel = WebSocketChannel.connect(Uri.parse(_url));

      _channel!.stream.listen(
            (event) => _handleEvent(event, userId, token),
        onDone: () {
          log("❌ Disconnected");
          _isConnected = false;
          _reconnect(userId, token);
        },
        onError: (e) {
          log("❌ Error: $e");
          _isConnected = false;
          _reconnect(userId, token);
        },
      );
    } catch (e) {
      log("❌ Connect exception: $e");
      _reconnect(userId, token);
    }
  }

  static Future<void> _handleEvent(
      dynamic event, String userId, String token) async {
    try {
      log("📦 RAW: $event");

      final decoded = jsonDecode(event);

      switch (decoded['event']) {
        case 'pusher:connection_established':
          final data = jsonDecode(decoded['data']);
          final socketId = data['socket_id'];

          log("✅ Connected | socket_id: $socketId");
          _isConnected = true;

          await _subscribe(userId, token, socketId);
          break;

        case 'pusher:subscription_succeeded':
          log("✅ Channel subscribed");
          break;

        case 'pusher:pong':
          log("❤️ Pong received");
          break;

        default:
          _handleCustomEvent(decoded);
      }
    } catch (e) {
      log("⚠️ Parse error: $e");
    }
  }

  static void _handleCustomEvent(dynamic decoded) {
    try {
      if (decoded['data'] == null) return;

      final data = jsonDecode(decoded['data']);

      if (data['message'] != null) {
        final message = MessageDetail.fromJson(data['message']);
        onMessageReceived?.call(message);
      }
    } catch (e) {
      log("⚠️ Custom parse error: $e");
    }
  }

  static Future<void> _subscribe(
      String userId, String token, String socketId) async {
    try {
      log("🔐 Authorizing...");

      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "socket_id": socketId,
          "channel_name": "private-user.$userId",
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Auth failed: ${response.statusCode} ${response.body}");
      }

      final data = jsonDecode(response.body);

      final payload = {
        "event": "pusher:subscribe",
        "data": {
          "channel": "private-user.$userId",
          "auth": data['auth'],
        }
      };

      _channel!.sink.add(jsonEncode(payload));

      log("📡 Subscribed to private-user.$userId");
    } catch (e) {
      log("❌ Auth error: $e");
    }
  }

  static void sendPing() {
    if (_isConnected) {
      _channel?.sink.add(jsonEncode({"event": "pusher:ping"}));
    }
  }

  static void disconnect() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _isConnected = false;
    log("🛑 Disconnected");
  }

  static void _reconnect(String userId, String token) {
    if (_reconnectTimer != null) return;

    log("🔄 Reconnecting in 5s...");

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _reconnectTimer = null;
      connect(userId: userId, token: token);
    });
  }
}