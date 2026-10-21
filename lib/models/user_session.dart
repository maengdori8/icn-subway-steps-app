// 로그인 결과. 앱을 끄면 사라진다(기기에 저장하지 않음).
// 서버 POST /api/auth/login → {accessToken, tokenType: "Bearer", expiresIn: 1800, user: {id, username}}.
class UserSession {
  const UserSession({required this.userId, required this.username, required this.accessToken});

  final int userId; // 팁의 ownerId와 비교해 '내가 올림'을 정한다
  final String username; // 설정(S05) '…(으)로 로그인됨'에 보인다
  final String accessToken; // Authorization: Bearer <accessToken>. 로그·화면에 보이지 않는다

  factory UserSession.fromLoginJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return UserSession(
      userId: user['id'] as int,
      username: user['username'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  @override
  String toString() => 'UserSession($userId, $username)';
}
