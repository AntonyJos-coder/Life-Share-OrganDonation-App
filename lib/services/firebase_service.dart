import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  // Method to log events
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    analytics.logEvent(name: eventName, parameters: parameters);
  }

  // Method to log errors
  static void recordError(dynamic exception, StackTrace? stack) {
    crashlytics.recordError(exception, stack, fatal: false);
  }

  // Optional: Method to set user ID for tracking
  static void setUserId(String? userId) {
    analytics.setUserId(id: userId);
  }
} 