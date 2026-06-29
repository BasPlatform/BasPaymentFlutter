import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

const bool _enableLog = kDebugMode;
class _MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return _enableLog;
  }
}

@internal
final Logger logger = Logger(
  level: _enableLog ? Level.debug : Level.off,
  filter: _MyFilter(),
);
