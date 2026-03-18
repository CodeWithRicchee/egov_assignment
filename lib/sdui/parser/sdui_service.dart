import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../models/sdui_models.dart';

@singleton
class SduiService {
  final Map<String, SduiScreen> _cache = {};

  Future<SduiScreen> loadScreen(String assetPath) async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath]!;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final screen = SduiScreen.fromJson(json);
    _cache[assetPath] = screen;
    return screen;
  }

  // Preload all screens
  Future<void> preloadAll() async {
    await Future.wait([
      loadScreen('assets/sdui/login_screen.json'),
      loadScreen('assets/sdui/employee_step1.json'),
      loadScreen('assets/sdui/employee_step2.json'),
      loadScreen('assets/sdui/employee_step3.json'),
    ]);
  }

  // Future: swap local JSON with API-provided SDUI response
  Future<SduiScreen> loadScreenFromApi(Map<String, dynamic> json) async {
    return SduiScreen.fromJson(json);
  }
}
