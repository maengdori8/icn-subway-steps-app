// 서버 단계의 photoKey → 앱에 들어 있는 사진과 출처 표시. 서버는 출처를 주지 않으므로 앱이 함께 둔다.
// 출처 원문: assets/photos/CREDITS.md. {ko|...}는 한국어로 읽을 부분.
class PhotoAsset {
  const PhotoAsset(this.asset, this.credit);

  final String asset;
  final String credit;
}

const _arrivalsCredit = 'Photo: {ko|인천국제공항공사} · data.go.kr · {ko|공공누리 1유형}';
const _wikiCredit = 'Photo: MNXANL / Wikimedia Commons · CC BY-SA 4.0';
// 2026-10-22 사용자 요청으로 빈 사진 2곳을 위키미디어 공용 사진으로 채움. 개찰구는 2007년 사진이라 연도를 함께 적는다.
const _transportCredit = 'Photo: Minseong Kim / Wikimedia Commons · CC BY-SA 4.0';
const _gateCredit = 'Photo (2007): Kanchi1979 / Wikimedia Commons · CC BY 2.5';
// 같은 날 추가 요청('더 찾아 직통열차')으로 직통열차 4·5단계도 채움. 둘 다 2015년, 개찰구는 개찰구·표지판 부분만 잘라 넣음.
const _expressGateCredit = 'Photo (2015, cropped): Asacyan / Wikimedia Commons · CC BY-SA 4.0';
const _expressPlatformCredit = 'Photo (2015): Wei-Te Wong / Wikimedia Commons · CC BY-SA 2.0';

const Map<String, PhotoAsset> stepPhotos = {
  'arrivals': PhotoAsset('assets/photos/arrivals_t1.jpg', _arrivalsCredit),
  'transportCenter': PhotoAsset('assets/photos/transport_center.jpg', _transportCredit),
  'expressConcourse': PhotoAsset('assets/photos/express_concourse.jpg', _wikiCredit),
  'expressGate': PhotoAsset('assets/photos/express_gate.jpg', _expressGateCredit),
  'expressPlatform': PhotoAsset('assets/photos/express_platform.jpg', _expressPlatformCredit),
  'localConcourse': PhotoAsset('assets/photos/local_concourse.jpg', _wikiCredit),
  'localGate': PhotoAsset('assets/photos/local_gate.jpg', _gateCredit),
  'localPlatform': PhotoAsset('assets/photos/local_platform.jpg', _wikiCredit),
};

// 모르는 키(서버에 새 사진이 생겼는데 앱에 없음)는 '사진 준비 중'으로 보인다.
PhotoAsset? stepPhotoFor(String? key) => key == null ? null : stepPhotos[key];
