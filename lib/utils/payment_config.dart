const String applePayConfig = '''{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.example",
    "displayName": "Example Merchant",
    "merchantCapabilities": ["3DS", "debit", "credit"],
    "supportedNetworks": ["visa", "masterCard", "amex"],
    "countryCode": "US",
    "currencyCode": "USD"
  }
}''';

const String googlePayConfig = '''{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY","CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA","MASTERCARD"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "example",
            "gatewayMerchantId": "exampleMerchantId"
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantName": "Example Merchant"
    },
    "transactionInfo": {
      "countryCode": "US",
      "currencyCode": "USD"
    }
  }
}''';