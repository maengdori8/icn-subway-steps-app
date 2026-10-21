// 서버 단계의 photoKey → 앱에 들어 있는 사진과 출처 표시. 서버는 출처를 주지 않으므로 앱이 함께 둔다.
// 출처 원문: assets/photos/CREDITS.md. {ko|...}는 한국어로 읽을 부분.
class PhotoAsset {
  const PhotoAsset(this.asset, this.credit);

  final String asset;
  final String credit;
}

const _arrivalsCredit = 'Photo: {ko|인천국제공항공사} · data.go.kr · {ko|공공누리 1유형}';
const _wikiCredit = 'Photo: MNXANL / Wikimedia Commons · CC BY-SA 4.0';

const Map<String, PhotoAsset> stepPhotos = {
  'arrivals': PhotoAsset('assets/photos/arrivals_t1.jpg', _arrivalsCredit),
  'expressConcourse': PhotoAsset('assets/photos/express_concourse.jpg', _wikiCredit),
  'localConcourse': PhotoAsset('assets/photos/local_concourse.jpg', _wikiCredit),
  'localPlatform': PhotoAsset('assets/photos/local_platform.jpg', _wikiCredit),
};

// 모르는 키(서버에 새 사진이 생겼는데 앱에 없음)는 '사진 준비 중'으로 보인다.
PhotoAsset? stepPhotoFor(String? key) => key == null ? null : stepPhotos[key];
