typedef PaymentSuccessCallback = Future<void> Function(String? sessionId);
typedef PaymentCancelCallback = void Function();

class PaymentSessionStore {
  static PaymentSuccessCallback? onSuccess;
  static PaymentCancelCallback? onCancel;

  static void clear() {
    onSuccess = null;
    onCancel = null;
  }
}