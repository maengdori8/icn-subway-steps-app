import 'dart:convert';

// 회원가입 입력 규칙(서버 docs/api-spec.yaml SignupRequest와 같음). 공백을 지우지 않고 그대로 검사한다.
// - 아이디: 영어 소문자·숫자·밑줄 4~24자(^[a-z0-9_]{4,24}$)
// - 비밀번호: 8자(코드 포인트) 이상, UTF-8 72바이트 이하(BCrypt 한계). 공백도 글자로 센다.
final RegExp usernamePattern = RegExp(r'^[a-z0-9_]{4,24}$');
const int passwordMinLength = 8;
const int passwordMaxBytes = 72;

// 칸 아래에 보일 오류. 문구가 아니라 종류를 저장해 언어를 바꿔도 그 언어로 다시 그린다.
// rejected: 서버 400이 그 칸을 거절했지만 앱 규칙으로는 맞는 종류가 없을 때(일반 문구).
enum SignupFieldError { usernameFormat, usernameTaken, passwordShort, passwordLong, passwordMismatch, rejected }

class SignupErrors {
  const SignupErrors({this.username, this.password, this.confirm});

  final SignupFieldError? username;
  final SignupFieldError? password;
  final SignupFieldError? confirm;

  bool get isEmpty => username == null && password == null && confirm == null;
}

SignupErrors validateSignup({required String username, required String password, required String confirm}) {
  SignupFieldError? passwordError() {
    if (password.runes.length < passwordMinLength) return SignupFieldError.passwordShort;
    if (utf8.encode(password).length > passwordMaxBytes) return SignupFieldError.passwordLong;
    return null;
  }

  return SignupErrors(
    username: usernamePattern.hasMatch(username) ? null : SignupFieldError.usernameFormat,
    password: passwordError(),
    confirm: confirm == password ? null : SignupFieldError.passwordMismatch,
  );
}
