class ApiConfig {
  // Base API configuration
  static const String baseUrl = 'https://migrationmanager.bansalcrm.com/api';
  static const String clientPortalEndpoint = '/client-portal';

  // Authentication endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/logout';
  static const String forgotPasswordEndpoint = '/forgot-password';
  static const String resetPasswordEndpoint = '/reset-password';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Matters
  static const String mattersEndpoint = '/matters';

  // Dashboard
  static const String dashboardEndpoint = '/dashboard';

  // Workflow endpoints
  static const String workflowStagesEndpoint = '/workflow/stages';
  static const String workflowStageDetailsEndpoint = '/workflow/stages';
  static const String workflowAllowedChecklistEndpoint =
      '/workflow/allowed-checklist';
  static const String workflowUploadChecklistEndpoint =
      '/workflow/upload-allowed-checklist';

  // Client portal specific endpoints
  static const String clientProfileEndpoint = '/profile';
  static const String clientCasesEndpoint = '/recent-cases';
  static const String clientDocumentsEndpoint = '/documents';
  static const String clientAppointmentsEndpoint =
      '/client-portal/appointments';
  static const String clientMessagesEndpoint = '/client-portal/messages';
  static const String clientTasksEndpoint = '/upcoming-deadlines';
  static const String recentActivityEndpoint = "/recent-activity";
  static const String documentsEndpoint = "/documents";
  static const String messagesRecipients = "/messages/recipients";
  static const String messagesList = "/messages";
  static const String messagesSend = "/messages/send";
  static const String messageRead = "/messages";
  static const String messageUnreadCount = "/messages/unread-count";
  static const String getClientPersonalDetailEndpoint = "/get-client-personal-detail";
  static const String updateClientBasicDetail = "/update-client-basic-detail";
  static const String updateClientPhoneDetail = "/update-client-phone-detail";
  static const String updateClientEmailDetail = "/update-client-email-detail";
  static const String updateClientPassportDetail = "/update-client-passport-detail";
  static const String updateClientVisaDetail = "/update-client-visa-detail";
  static const String updateClientAddressDetail = "/update-client-address-detail";
  static const String updateClientTravelDetail = "/update-client-travel-detail";
  static const String updateClientQualificationDetail = "/update-client-qualification-detail";
  static const String updateClientExperienceDetail = "/update-client-experience-detail";
  static const String updateClientOccupationDetail = "/update-client-occupation-detail";
  static const String updateClientTestScoreDetail = "/update-client-testscore-detail";
  static const String searchOccupation = "/search-occupation";


  // API settings
  static const Duration timeout = Duration(seconds: 30);
  static const Duration refreshTokenThreshold = Duration(minutes: 5);

  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client-Portal/1.0.0',
  };

  // Error messages
  static const Map<int, String> errorMessages = {
    400: 'Bad Request - Please check your input',
    401: 'Unauthorized - Please login again',
    403: 'Forbidden - You don\'t have permission',
    404: 'Not Found - Resource not available',
    422: 'Validation Error - Please check your data',
    429: 'Too Many Requests - Please try again later',
    500: 'Server Error - Please try again later',
    502: 'Bad Gateway - Service temporarily unavailable',
    503: 'Service Unavailable - Please try again later',
  };

  // Get full endpoint URL
  static String getEndpoint(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl$endpoint';
  }

  // Get client portal endpoint URL
  static String getClientPortalEndpoint(String endpoint) {
    return '$baseUrl$clientPortalEndpoint$endpoint';
  }

  // Get error message for status code
  static String getErrorMessage(int statusCode) {
    return errorMessages[statusCode] ?? 'Unknown error occurred';
  }

  // ----------------------
  // Pusher configuration
  // ----------------------
  static const String pusherAppId = '2058948';
  static const String pusherAppKey = '0410ad08e960563173b5';
  static const String pusherAppSecret = 'd2d8b6320636c77dec48';
  static const String pusherCluster = 'ap2';
  static const String pusherEncrypted = 'true';
}
