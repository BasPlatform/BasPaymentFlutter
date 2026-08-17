import 'package:bas_pay_flutter/utils/bas_pay_logger.dart';

import '../models/init_bas_sdk_model.dart';

class BasPayHostUrls {
  static const String prodBaseUrl = 'https://bas-pay.web.app/';
  static const String devBaseUrl = 'https://bas-pay-dev.web.app/';
  static const String sandboxBaseUrl = 'https://bas-pay-sandbox.web.app/';
  static const String embeddedPopup = 'popup';
  static const String osTypeWeb = 'Web';
  static const String parentOriginKey = 'parentOrigin';

  static const Set<String> allowedHostedOrigins = <String>{
    'https://bas-pay.web.app',
    'https://bas-pay-dev.web.app',
    'https://bas-pay-sandbox.web.app',
  };

  static const Set<String> allowedLocalHosts = <String>{
    'localhost',
    '127.0.0.1',
    '[::1]',
  };

  static String resolveBaseUrl({required String? environment}) {
    return switch (environment?.toLowerCase()) {
      'dev' => devBaseUrl,
      'sandbox' => sandboxBaseUrl,
      _ => prodBaseUrl,
    };
  }

  static bool isAllowedOrigin(String origin) {
    final String trimmedOrigin = origin.trim();
    if (trimmedOrigin.isEmpty || trimmedOrigin == 'null') {
      return false;
    }
    if (allowedHostedOrigins.contains(trimmedOrigin)) {
      return true;
    }
    final Uri? uri = Uri.tryParse(trimmedOrigin);
    if (uri == null || uri.host.isEmpty) {
      return false;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    final String host = uri.host.toLowerCase();
    return allowedLocalHosts.contains(host);
  }

  static Uri buildPaymentUri({
    required InitBasSdkModel model,
    required String parentOrigin,
  }) {
    final String baseUrl = resolveBaseUrl(environment: model.environment);
    final Map<String, String> queryParameters = <String, String>{};
    model.toJson().forEach((String key, dynamic value) {
      if (value == null) {
        return;
      }
      queryParameters[key] = value.toString();
    });
    queryParameters['osType'] = osTypeWeb;
    queryParameters['embedded'] = embeddedPopup;
    final String trimmedParentOrigin = parentOrigin.trim();
    if (trimmedParentOrigin.isNotEmpty) {
      queryParameters[parentOriginKey] = trimmedParentOrigin;
    }
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
    logger.d('payment popup uri: $uri');
    return uri;
  }
}
