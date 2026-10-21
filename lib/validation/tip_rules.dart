// S03 팁 입력 규칙. 화면과 가짜 저장소가 같은 규칙을 쓴다.
// 글자 수는 코드 포인트(runes) 기준이다. 서버 계약에서 단위가 정해지면 이 파일만 고친다.
const int tipTitleMax = 80;
const int tipLocationMax = 80;
const int tipNoteMax = 150;

int codePointLength(String value) => value.runes.length;

// 칸 아래에 보일 오류. 문구가 아니라 종류를 저장해 언어를 바꿔도 그 언어로 다시 그린다.
enum TipFieldError { required, tooLong80, tooLong150 }

class TipFormErrors {
  const TipFormErrors({this.title, this.location, this.note});

  final TipFieldError? title;
  final TipFieldError? location;
  final TipFieldError? note;

  bool get isEmpty => title == null && location == null && note == null;
}

// 제목·위치: 앞뒤 공백을 뺀 뒤 1~80자. 메모: 선택, 앞뒤 공백을 뺀 뒤 150자 이하(서버 계약과 같음).
TipFormErrors validateTip({required String title, required String location, required String note}) {
  TipFieldError? required80(String value) {
    final length = codePointLength(value.trim());
    if (length < 1) return TipFieldError.required;
    if (length > tipTitleMax) return TipFieldError.tooLong80;
    return null;
  }

  return TipFormErrors(
    title: required80(title),
    location: required80(location),
    note: codePointLength(note.trim()) > tipNoteMax ? TipFieldError.tooLong150 : null,
  );
}

// 화면의 글자 수 표시(n/80, n/150). 검증과 같은 기준으로 센다.
int tipFieldCount(String value) => codePointLength(value.trim());
