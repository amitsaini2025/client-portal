import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';


class PusherService {
  PusherService._();
  static PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  static void init_() async {
    try {
        var key =  "0410ad08e960563173b5";
        var cluster =  "eu";

        var channelName = "OrdersOf-12";
        await pusher.init(
          apiKey: key,
          cluster: cluster,
          onAuthorizer: onAuthorizer,
          onConnectionStateChange: onConnectionStateChange,
          onError: onError,
          onSubscriptionSucceeded: onSubscriptionSucceeded,
          onEvent: onEvent,
          onSubscriptionError: onSubscriptionError,
        );
        await pusher.subscribe(channelName: channelName);
        await pusher.connect();

    } catch (e) {
      log("ERROR: $e");
    }
  }


  static Future<void> onEvent(PusherEvent event) async {
    log("onEvent: $event");
    if (event.data != null && event.data.isNotEmpty) {
      /////-action you want to do.

    }
  }

  static void onConnectionStateChange(
      dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  static void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  static void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    log("Me: $me");
  }

  static void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  static dynamic onAuthorizer(channel, socketId, _) async {
    var token = "";
    var baseUrl = "";
    var authUrl = "$baseUrl/broadcasting/auth";
    var result = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: 'socket_id=$socketId&channel_name=$channel',
    );
    var json = jsonDecode(result.body);
    return json;
  }
}
