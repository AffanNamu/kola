import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();

  static Future<bool> hasInternet() async {
    final res = await _connectivity.checkConnectivity();
    return res != ConnectivityResult.none;
  }
}
