
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class ConnectivityHelper {
  /// Returns true only if there is actual internet access (not just network).
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    // Try to make a simple request to a reliable endpoint
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
