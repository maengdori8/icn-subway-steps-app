// 로그인 결과. 앱을 끄면 사라진다(기기에 저장하지 않음).
// 10장에서 POST /api/auth/login 응답(로그인 확인 값·사용자 이름)으로 채운다.
class UserSession {
  const UserSession({required this.userId, required this.username, required this.accessToken});

  final int userId; // 팁의 owner_id와 비교해 '내가 올림'을 정한다
  final String username; // 설정(S05) '…(으)로 로그인됨'에 보인다
  final String accessToken; // 가짜 저장소에서는 의미 없는 표시 값. 로그·화면에 보이지 않는다

  @override
  String toString() => 'UserSession($userId, $username)';
}
