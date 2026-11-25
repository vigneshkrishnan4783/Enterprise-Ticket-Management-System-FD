import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String get baseUrl => _api.baseUrl;
  bool get isBackendReachable => _api.isBackendReachable;
  String? get lastError => _api.lastConnectionError;

  bool _isTestingConnection = false;
  bool get isTestingConnection => _isTestingConnection;

  Future<bool> updateBaseUrl(String newUrl) async {
    _api.setBaseUrl(newUrl);
    _isTestingConnection = true;
    notifyListeners();

    final result = await _api.testConnection();
    _isTestingConnection = false;
    notifyListeners();
    return result;
  }

  Future<bool> checkConnection() async {
    _isTestingConnection = true;
    notifyListeners();

    final result = await _api.testConnection();
    _isTestingConnection = false;
    notifyListeners();
    return result;
  }
}
