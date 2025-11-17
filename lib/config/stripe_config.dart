class StripeConfig {
  const StripeConfig._();

  static const String publishableKey =
      'pk_test_51HAz4JFeMJ48bwS4Www5LApVIBY6KqnGtsdKjpQleJDJIXAS0V8qrKecEO0MEoBnzcqmIo5GFBnXCtJEsj7H6FIH00kSSk38hr';

  static const String secretKey = String.fromEnvironment(
    'sk_test_51HAz4JFeMJ48bwS4dB2PdVBvrIueL4Tpir8re630NvjMdE8VX4tQMv5UXvq0CNZsMiNPuc2hl8XOKUxhgpguj61C00Peq8Mbm2',
    defaultValue: '',
  );

  /// WARNING: Never ship secret keys in production builds.
  /// This constant is included temporarily for integration purposes and
  /// must be moved to a secure backend before release.
  /// Provide the Stripe secret key via runtime configuration. In debug builds
  /// you can supply the value with `--dart-define STRIPE_SECRET_KEY=...`.

  static const String merchantDisplayName = 'LegiComply';
  static const String merchantIdentifier = 'merchant.com.legicomply';
  static const String merchantCountryCode = 'US';
  static const String defaultCurrency = 'usd';

  static const Duration paymentTimeout = Duration(minutes: 15);
}

