import '../../domain/entities/mock_login_response.dart';

/// Data model for [MockLoginResponse] with JSON serialization
class MockLoginResponseModel extends MockLoginResponse {
  const MockLoginResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.accessTokenExpiresInSeconds,
    required super.refreshTokenExpiresInSeconds,
  });

  factory MockLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return MockLoginResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      accessTokenExpiresInSeconds:
          (json['access_token_expires_in_seconds'] as num?)?.toInt() ?? 0,
      refreshTokenExpiresInSeconds:
          (json['refresh_token_expires_in_seconds'] as num?)?.toInt() ?? 0,
    );
  }

  factory MockLoginResponseModel.fromEntity(MockLoginResponse entity) {
    return MockLoginResponseModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      accessTokenExpiresInSeconds: entity.accessTokenExpiresInSeconds,
      refreshTokenExpiresInSeconds: entity.refreshTokenExpiresInSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expires_in_seconds': accessTokenExpiresInSeconds,
      'refresh_token_expires_in_seconds': refreshTokenExpiresInSeconds,
    };
  }
}
