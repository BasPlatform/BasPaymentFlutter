abstract class BasPayWebErrors {
  static const int popupBlockedCode = 601;
  static const int userCancelledCode = 602;
  static const int sessionTimeoutCode = 603;

  static const String popupBlockedMessage =
      'Payment popup was blocked. Allow popups for this site and try again.';
  static const String userCancelledMessage =
      'Payment was cancelled before completion.';
  static const String sessionTimeoutMessage =
      'Payment session timed out. Please try again.';
}

enum BasPayPopupExitReason {
  success,
  popupBlocked,
  userCancelled,
  sessionTimeout,
}
