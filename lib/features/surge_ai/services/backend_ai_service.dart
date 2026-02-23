import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Backend AI Service
/// Secure HTTP client for communicating with AI gateway
/// NEVER exposes AI provider details to the app
class BackendAIService {
  final FirebaseAuth _auth;
  final String _baseUrl;
  
  BackendAIService({
    required FirebaseAuth auth,
    String? baseUrl,
  })  : _auth = auth,
        _baseUrl = baseUrl ?? 'http://localhost:3000/api/v1/surge-ai';
  
  /// Send a chat message to the backend AI gateway
  /// Returns AI response or throws exception
  Future<BackendAIResponse> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      // Get Firebase ID token
      final token = await _getAuthToken();
      
      if (token == null) {
        throw BackendAIException('Authentication required. Please sign in.');
      }
      
      // Make request to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          if (sessionId != null) 'sessionId': sessionId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw BackendAIException('Request timed out. Please try again.');
        },
      );
      
      // Parse response
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Handle errors
      if (response.statusCode != 200) {
        return _handleErrorResponse(response.statusCode, data);
      }
      
      // Return successful response
      return BackendAIResponse(
        reply: data['reply'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
        sessionId: data['sessionId'] as String,
      );
    } on BackendAIException {
      rethrow;
    } catch (e, stackTrace) {
      // Detailed error logging for debugging
      print('❌ Backend AI Connection Error:');
      print('   Error Type: ${e.runtimeType}');
      print('   Error: $e');
      print('   Base URL: $_baseUrl');
      print('   Stack Trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      throw BackendAIException('Connection failed: ${e.toString()}');
    }
  }
  
  /// Get user's AI usage stats
  Future<AIUsageStats?> getUsageStats() async {
    try {
      final token = await _getAuthToken();
      
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/usage'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AIUsageStats.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check backend health
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Get Firebase ID token
  Future<String?> _getAuthToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return await user.getIdToken();
  }
  
  /// Handle error responses from backend
  BackendAIResponse _handleErrorResponse(int statusCode, Map<String, dynamic> data) {
    final error = data['error'] as String?;
    final upgradePrompt = data['upgradePrompt'] as bool? ?? false;
    
    if (statusCode == 429) {
      // Rate limit exceeded
      throw RateLimitException(
        error ?? 'Too many requests. Please try again later.',
        upgradePrompt: upgradePrompt,
      );
    }
    
    if (statusCode == 401) {
      // Authentication failed
      throw BackendAIException('Authentication failed. Please sign in again.');
    }
    
    if (statusCode == 400) {
      // Bad request
      throw BackendAIException(error ?? 'Invalid request.');
    }
    
    // Generic error
    throw BackendAIException(error ?? 'An error occurred. Please try again.');
  }
}

/// Backend AI Response
class BackendAIResponse {
  final String reply;
  final DateTime timestamp;
  final String sessionId;
  
  BackendAIResponse({
    required this.reply,
    required this.timestamp,
    required this.sessionId,
  });
}

/// AI Usage Statistics
class AIUsageStats {
  final String tier;
  final int dailyLimit;
  final int dailyRemaining;
  final int dailyUsed;
  
  AIUsageStats({
    required this.tier,
    required this.dailyLimit,
    required this.dailyRemaining,
    required this.dailyUsed,
  });
  
  factory AIUsageStats.fromJson(Map<String, dynamic> json) {
    return AIUsageStats(
      tier: json['tier'] as String,
      dailyLimit: json['dailyLimit'] as int,
      dailyRemaining: json['dailyRemaining'] as int,
      dailyUsed: json['dailyUsed'] as int,
    );
  }
  
  bool get isProUser => tier == 'pro';
  bool get hasReachedLimit => dailyRemaining <= 0;
  double get usagePercentage => dailyLimit > 0 ? (dailyUsed / dailyLimit) * 100 : 0;
}

/// Backend AI Exception
class BackendAIException implements Exception {
  final String message;
  
  BackendAIException(this.message);
  
  @override
  String toString() => message;
}

/// Rate Limit Exception
class RateLimitException extends BackendAIException {
  final bool upgradePrompt;
  
  RateLimitException(String message, {this.upgradePrompt = false}) : super(message);
}
