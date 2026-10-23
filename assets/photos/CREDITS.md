# 단계 사진 출처

원본: C:\dev\photo-sources\airport-subway (SOURCE-licenses.txt는 원본 licenses.txt 사본). 앱에는 가로 720px로 줄여(비율 유지, 자르기 없음) 넣었다. 단 express_gate.jpg는 옆으로 긴 원본에서 개찰구·표지판 부분만 잘라 넣었다. 화면에서는 4:3 칸에 맞춰 가운데를 보여 준다.

| 앱 파일 | 원본 | 출처 표시 | 라이선스 |
| --- | --- | --- | --- |
| arrivals_t1.jpg | datagokr/T1 입국장.JPG | 인천국제공항공사, 공공데이터포털(data.go.kr) https://www.data.go.kr/data/15130703/fileData.do | 공공누리 제1유형(출처표시) |
| transport_center.jpg | wikimedia/Incheon_Airport_Transportation_Center_Main_Hall.jpg | Minseong Kim / Wikimedia Commons https://commons.wikimedia.org/wiki/File:Incheon_Airport_Transportation_Center_Main_Hall.jpg | CC BY-SA 4.0 |
| express_concourse.jpg | wikimedia/202403_AREX_Express_Train_Concourse_at_Incheon_International_Airport_Terminal_1_Station.jpg | MNXANL / Wikimedia Commons https://commons.wikimedia.org/wiki/File:202403_AREX_Express_Train_Concourse_at_Incheon_International_Airport_Terminal_1_Station.jpg | CC BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/ |
| express_gate.jpg | wikimedia/Korail_ar_incheon_intl_airport_sta_02.jpg (공용 이름 Korail ar incheon int'l airport sta 02.jpg) 중 x 1600, y 1010, 1360×1020을 잘라 냄 | Asacyan / Wikimedia Commons https://commons.wikimedia.org/wiki/File:Korail_ar_incheon_int%27l_airport_sta_02.jpg (2015년 촬영) | CC BY-SA 4.0 |
| express_platform.jpg | wikimedia/Wongwt_Seoul_Airport_Railroad_16921458087.jpg (공용 이름 Wongwt 首爾機場快鐵 (16921458087).jpg) | Wei-Te Wong / Wikimedia Commons https://commons.wikimedia.org/wiki/File:Wongwt_%E9%A6%96%E7%88%BE%E6%A9%9F%E5%A0%B4%E5%BF%AB%E9%90%B5_(16921458087).jpg (2015년 촬영) | CC BY-SA 2.0 https://creativecommons.org/licenses/by-sa/2.0/ |
| local_concourse.jpg | wikimedia/202403_AREX_Local_Train_Concourse_at_Incheon_International_Airport_Terminal_1_Station.jpg | MNXANL / Wikimedia Commons https://commons.wikimedia.org/wiki/File:202403_AREX_Local_Train_Concourse_at_Incheon_International_Airport_Terminal_1_Station.jpg | CC BY-SA 4.0 |
| local_gate.jpg | wikimedia/AREX-Incheon-International-Airport-Station-Gates.JPG | Kanchi1979 / Wikimedia Commons https://commons.wikimedia.org/wiki/File:AREX-Incheon-International-Airport-Station-Gates.JPG (2007년 촬영) | CC BY 2.5 https://creativecommons.org/licenses/by/2.5/ |
| local_platform.jpg | wikimedia/202403_AREX_Local_Platform_1,2_of_Incheon_International_Airport_Terminal_1_Station.jpg | MNXANL / Wikimedia Commons https://commons.wikimedia.org/wiki/File:202403_AREX_Local_Platform_1,2_of_Incheon_International_Airport_Terminal_1_Station.jpg | CC BY-SA 4.0 |

주의:
- T1 입국장 사진은 코로나 시기 촬영으로 보인다(원본 licenses.txt 참고).
- 개찰구 사진(local_gate.jpg)은 2007년 촬영이라 지금 기계·표지판과 다를 수 있다. 앱의 출처 표시에 연도를 함께 적었다.
- 직통열차 개찰구·승강장(express_gate.jpg, express_platform.jpg)은 2015년 촬영이다. 2018년 역 이름이 바뀌고 KTX가 없어져 지금 표지판과 다를 수 있어 출처 표시에 연도를 적었다. 개찰구는 잘라 냈으므로 'cropped/잘라냄'도 적었다.
- 이제 앱의 모든 단계에 사진이 있다. 서버 photoKey가 null이거나 앱이 모르는 키일 때만 '사진 준비 중'이 보인다.
- 현장 사진으로 바꾸면 이 표와 lib/models/step_photos.dart(서버 photoKey → 사진·출처), 설정 화면의 사진 출처를 함께 고친다.
