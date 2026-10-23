# 10장(2026-10-21): release 빌드가 시작 화면에서 멈추던 문제(reports/app-integration.md 3절).
# shared_preferences_android 2.5.1은 Dart가 JNI(package:jni)로 플러그인 메서드를 이름·시그니처로 부른다.
# 이 플러그인에는 keep 규칙이 없어 release의 R8이 그 메서드를 지우거나 이름을 바꾸고, 앱이 켜질 때
# NoSuchMethodError·ClassNotFoundException이 난다. jni 자체 클래스는 jni 패키지의 규칙이 지킨다.
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# jni·shared_preferences_android의 Dart 코드가 이름으로 찾는 Kotlin 클래스(suspend 함수 호출에 쓰임).
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
