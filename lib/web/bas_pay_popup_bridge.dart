// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:bas_pay_flutter/utils/bas_pay_logger.dart';
import 'package:web/web.dart' as web;

import '../models/init_bas_sdk_model.dart';
import '../models/result_model.dart';
import 'bas_pay_host_urls.dart';
import 'bas_pay_message_contract.dart';
import 'bas_pay_web_errors.dart';

class BasPayPopupBridge {
  static const String popupName = 'bas_pay_sdk';
  static const String popupFeatures =
      'popup,width=480,height=800,scrollbars=yes,resizable=yes';
  static const Duration defaultTimeout = Duration(minutes: 30);
  static const Duration popupPollInterval = Duration(milliseconds: 500);
  static const Duration popupCloseGracePeriod = Duration(milliseconds: 1500);

  Future<({bool resultStatus, ResultModel? resultModel})> openAndWaitForResult({
    required InitBasSdkModel model,
    Duration timeout = defaultTimeout,
  }) async {
    final String parentOrigin = web.window.location.origin;
    final Uri paymentUri = BasPayHostUrls.buildPaymentUri(
      model: model,
      parentOrigin: parentOrigin,
    );
    logger.d('opening payment popup from parent origin: $parentOrigin');
    final web.Window? popup = web.window.open(
      paymentUri.toString(),
      popupName,
      popupFeatures,
    );
    if (popup == null || popup.closed) {
      return _buildPluginResult(
        exitReason: BasPayPopupExitReason.popupBlocked,
      );
    }
    return _waitForPopupResult(popup: popup, timeout: timeout);
  }

  Future<({bool resultStatus, ResultModel? resultModel})> _waitForPopupResult({
    required web.Window popup,
    required Duration timeout,
  }) async {
    final Completer<({bool resultStatus, ResultModel? resultModel})> completer =
        Completer<({bool resultStatus, ResultModel? resultModel})>();
    Timer? pollTimer;
    Timer? timeoutTimer;
    Timer? closeGraceTimer;
    late final JSFunction messageListenerJs;
    void onMessage(web.Event event) {
      if (completer.isCompleted) {
        return;
      }
      final web.MessageEvent messageEvent = event as web.MessageEvent;
      if (!BasPayHostUrls.isAllowedOrigin(messageEvent.origin)) {
        logger.d('ignored postMessage from origin: ${messageEvent.origin}');
        return;
      }
      final Map<String, dynamic>? messageData = _parseMessageData(
        messageEvent.data,
      );
      if (messageData == null) {
        logger.d('ignored postMessage with unsupported payload');
        return;
      }
      if (messageData[BasPayMessageContract.typeKey] !=
          BasPayMessageContract.resultType) {
        return;
      }
      final dynamic payload = messageData[BasPayMessageContract.payloadKey];
      if (payload == null) {
        return;
      }
      logger.d('received bas_pay_result from popup');
      closeGraceTimer?.cancel();
      _completePayment(
        completer: completer,
        popup: popup,
        pollTimer: pollTimer,
        timeoutTimer: timeoutTimer,
        closeGraceTimer: closeGraceTimer,
        messageListenerJs: messageListenerJs,
        exitReason: BasPayPopupExitReason.success,
        resultModel: ResultModel.fromJson(payload),
      );
    }

    void onPopupClosed() {
      if (completer.isCompleted) {
        return;
      }
      pollTimer?.cancel();
      logger.d('popup closed, waiting for postMessage grace period');
      closeGraceTimer?.cancel();
      closeGraceTimer = Timer(popupCloseGracePeriod, () {
        if (completer.isCompleted) {
          return;
        }
        logger.d('popup closed without postMessage result');
        _completePayment(
          completer: completer,
          popup: popup,
          pollTimer: pollTimer,
          timeoutTimer: timeoutTimer,
          closeGraceTimer: closeGraceTimer,
          messageListenerJs: messageListenerJs,
          exitReason: BasPayPopupExitReason.userCancelled,
        );
      });
    }

    messageListenerJs = onMessage.toJS;
    web.window.addEventListener('message', messageListenerJs);
    pollTimer = Timer.periodic(popupPollInterval, (_) {
      if (completer.isCompleted) {
        return;
      }
      if (popup.closed) {
        onPopupClosed();
      }
    });
    timeoutTimer = Timer(timeout, () {
      if (completer.isCompleted) {
        return;
      }
      logger.d('payment popup session timeout');
      _completePayment(
        completer: completer,
        popup: popup,
        pollTimer: pollTimer,
        timeoutTimer: timeoutTimer,
        closeGraceTimer: closeGraceTimer,
        messageListenerJs: messageListenerJs,
        exitReason: BasPayPopupExitReason.sessionTimeout,
      );
    });
    return completer.future;
  }

  void _completePayment({
    required Completer<({bool resultStatus, ResultModel? resultModel})>
    completer,
    required web.Window popup,
    required Timer? pollTimer,
    required Timer? timeoutTimer,
    required Timer? closeGraceTimer,
    required JSFunction messageListenerJs,
    required BasPayPopupExitReason exitReason,
    ResultModel? resultModel,
  }) {
    if (completer.isCompleted) {
      return;
    }
    logger.d('completing payment with exit reason: $exitReason');
    pollTimer?.cancel();
    timeoutTimer?.cancel();
    closeGraceTimer?.cancel();
    web.window.removeEventListener('message', messageListenerJs);
    if (!popup.closed) {
      popup.close();
    }
    completer.complete(
      _buildPluginResult(exitReason: exitReason, resultModel: resultModel),
    );
  }

  ({bool resultStatus, ResultModel? resultModel}) _buildPluginResult({
    required BasPayPopupExitReason exitReason,
    ResultModel? resultModel,
  }) {
    if (exitReason == BasPayPopupExitReason.success && resultModel != null) {
      return (resultStatus: true, resultModel: resultModel);
    }
    return (
      resultStatus: true,
      resultModel: ResultModel.fromJson(<String, dynamic>{
        ResultModelFields.status: false,
        ResultModelFields.message: _resolveErrorMessage(exitReason),
        ResultModelFields.result: '',
        ResultModelFields.code: _resolveErrorCode(exitReason),
      }),
    );
  }

  String _resolveErrorMessage(BasPayPopupExitReason exitReason) {
    switch (exitReason) {
      case BasPayPopupExitReason.popupBlocked:
        return BasPayWebErrors.popupBlockedMessage;
      case BasPayPopupExitReason.userCancelled:
        return BasPayWebErrors.userCancelledMessage;
      case BasPayPopupExitReason.sessionTimeout:
        return BasPayWebErrors.sessionTimeoutMessage;
      case BasPayPopupExitReason.success:
        return '';
    }
  }

  int _resolveErrorCode(BasPayPopupExitReason exitReason) {
    switch (exitReason) {
      case BasPayPopupExitReason.popupBlocked:
        return BasPayWebErrors.popupBlockedCode;
      case BasPayPopupExitReason.userCancelled:
        return BasPayWebErrors.userCancelledCode;
      case BasPayPopupExitReason.sessionTimeout:
        return BasPayWebErrors.sessionTimeoutCode;
      case BasPayPopupExitReason.success:
        return 200;
    }
  }

  Map<String, dynamic>? _parseMessageData(JSAny? data) {
    if (data == null) {
      return null;
    }
    final Object? dartified = data.dartify();
    if (dartified is String) {
      final dynamic decoded = jsonDecode(dartified);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    }
    if (dartified is Map<String, dynamic>) {
      return dartified;
    }
    if (dartified is Map) {
      return Map<String, dynamic>.from(dartified);
    }
    return null;
  }
}
