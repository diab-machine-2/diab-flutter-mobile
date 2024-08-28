# for flutter_blue_plus
-keep class com.boskokg.flutter_blue_plus.** { *; }

# for flutter_blue
-keep class com.pauldemarco.flutter_blue.** { *; }

# for for zoom video sdk
-keep class  us.zoom.**{*;}
-keep class  com.zipow.**{*;}
-keep class  us.zipow.**{*;}
-keep class  org.webrtc.**{*;}
-keep class  us.google.protobuf.**{*;}
-keep class  com.google.crypto.tink.**{*;}
-keep class  androidx.security.crypto.**{*;}

# for zalo
-keep class com.zing.zalo.**{ *; }
-keep enum com.zing.zalo.**{ *; }
-keep interface com.zing.zalo.**{ *; }

-dontwarn com.crashlytics.android.ndk.CrashlyticsNdk
-dontwarn com.google.android.exoplayer2.trackselection.TrackSelectionOverrides$Builder
-dontwarn com.google.android.exoplayer2.trackselection.TrackSelectionOverrides$TrackSelectionOverride
-dontwarn com.google.android.exoplayer2.trackselection.TrackSelectionOverrides
-dontwarn com.google.api.client.http.GenericUrl
-dontwarn com.google.api.client.http.HttpHeaders
-dontwarn com.google.api.client.http.HttpRequest
-dontwarn com.google.api.client.http.HttpRequestFactory
-dontwarn com.google.api.client.http.HttpResponse
-dontwarn com.google.api.client.http.HttpTransport
-dontwarn com.google.api.client.http.javanet.NetHttpTransport$Builder
-dontwarn com.google.api.client.http.javanet.NetHttpTransport
-dontwarn org.joda.time.Instant