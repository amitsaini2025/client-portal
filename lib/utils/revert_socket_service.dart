import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:client/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/workflow_send_message_response.dart';

class ReverbSocketService {
  static WebSocketChannel? _channel;
  static Timer? _reconnectTimer;
  static bool _isConnected = false;

  static Function(dynamic message)? onMessageReceived;

  static const String _host = "revapi.bansalcrm.com";
  static const int _port = 443;
  static const String _scheme = "wss";

  static const String _appKey = "145cd98cfea9f69732ae6755ac889bcc";

  // WebSocket URL as you requested
  static String get _url => "$_scheme://$_host/app/$_appKey";

  // Auth URL
  static String get _authUrl => "${ApiConfig.baseUrl}/broadcasting/auth";

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
    log("📦 RAW: $event");

    try {
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
          log("🎉 Subscription successful");
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

      log("📩 EVENT DATA: $data");

      final message = MessageDetail.fromJson(data);
      if (message.message.isEmpty) return;

      onMessageReceived?.call(message);
    } catch (e) {
      log("⚠️ Custom event parse error: $e");
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
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "socket_id": socketId,
          "channel_name": "private-user.$userId",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Auth failed: ${response.statusCode} ${response.body}");
      }

      final data = jsonDecode(response.body);


      final payload = {
        "event": "pusher:subscribe",
        "data": {
          "auth": data['auth'],
          "channel": "private-user.$userId",
        }
      };

      log("📡 Subscribing payload: $payload");

      _channel!.sink.add(jsonEncode(payload));

      log("📡 Subscribed to private-user.$userId");
    } catch (e) {
      log("❌ Auth error: $e");
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