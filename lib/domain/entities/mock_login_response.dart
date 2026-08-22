/// Mock login authentication response entity
class MockLoginResponse {
  const MockLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
  });

  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;
  final int refreshTokenExpiresInSeconds;
}
