import 'package:googleapis/dialogflow/v2.dart' as dialogflow;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class ChatbotService {
  final String _projectId;
  final String _dialogflowJsonPath;

  dialogflow.DialogflowApi? _dialogflowApi;

  ChatbotService(this._projectId, this._dialogflowJsonPath);

  Future<void> initialize() async {
    final client = await _getHttpClient();
    _dialogflowApi = dialogflow.DialogflowApi(client);
  }

  Future<dialogflow.GoogleCloudDialogflowV2DetectIntentResponse> detectIntent(String query) async {
    if (_dialogflowApi == null) {
      throw Exception("Dialogflow API not initialized.");
    }

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final sessionPath = 'projects/$_projectId/agent/sessions/$sessionId';

    final textInput = dialogflow.GoogleCloudDialogflowV2TextInput(
      text: query,
      languageCode: 'en-US',
    );

    final queryInput = dialogflow.GoogleCloudDialogflowV2QueryInput(text: textInput);

    final request = dialogflow.GoogleCloudDialogflowV2DetectIntentRequest(
      queryInput: queryInput,
    );

    final response = await _dialogflowApi!.projects.agent.sessions
        .detectIntent(request, sessionPath);

    return response;
  }

  Future<AutoRefreshingAuthClient> _getHttpClient() async {
    final jsonCredentials = await rootBundle.loadString(_dialogflowJsonPath);
    final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
    final scopes = [dialogflow.DialogflowApi.dialogflowScope];
    final client = await clientViaServiceAccount(credentials, scopes);
    return client;
  }
}