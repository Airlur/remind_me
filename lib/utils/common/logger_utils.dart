import 'package:logger/logger.dart';

class LoggerUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void d(dynamic message, [String? tag]) => 
      _logger.d(tag != null ? '【$tag】 $message' : message);
  
  static void i(dynamic message, [String? tag]) => 
      _logger.i(tag != null ? '【$tag】 $message' : message);
  
  static void w(dynamic message, [String? tag]) => 
      _logger.w(tag != null ? '【$tag】 $message' : message);
  
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace, String? tag]) => 
      _logger.e(tag != null ? '【$tag】 $message' : message, error: error, stackTrace: stackTrace);
} 