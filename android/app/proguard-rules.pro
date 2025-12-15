# for flutter_blue_plus
-keep class com.boskokg.flutter_blue_plus.** { *; }

# for flutter_blue
-keep class com.pauldemarco.flutter_blue.** { *; }

# for for zoom video sdk
-keep class us.zoom.**{*;}
-keep class com.zipow.**{*;}
-keep class us.zipow.**{*;}
-keep class us.zipow.**{*;}
-keep class org.webrtc.**{*;}
-keep class us.google.protobuf.**{*;}
-keep class com.google.crypto.tink.**{*;}
-keep class androidx.security.crypto.**{*;}

# Keep flutter_zoom_meeting plugin classes to prevent method channel crashes
# CRITICAL: These rules prevent FlutterZoomPlugin from being removed by ProGuard/R8
# The plugin has minifyEnabled=true in its build.gradle, so these rules are essential
-keep class com.zoualfkar.flutter_zoom.** { *; }
-keep class com.zoualfkar.flutter_zoom.FlutterZoomPlugin { *; }
-keep class com.zoualfkar.flutter_zoom.StatusStreamHandler { *; }
-keepclassmembers class com.zoualfkar.flutter_zoom.** { *; }
# Keep all constructors and methods - prevent removal during plugin's own minification
-keepclassmembers class com.zoualfkar.flutter_zoom.FlutterZoomPlugin {
    <init>(...);
    <methods>;
    <fields>;
    *;
}
# Keep the plugin class and all its dependencies - prevent obfuscation
-keep,allowobfuscation class com.zoualfkar.flutter_zoom.FlutterZoomPlugin
-keep,allowobfuscation class * extends com.zoualfkar.flutter_zoom.FlutterZoomPlugin
# Keep all FlutterPlugin implementations from the plugin
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin {
    <init>(...);
}
# Don't warn about missing classes from the plugin
-dontwarn com.zoualfkar.flutter_zoom.**

# for zalo
-keep class com.zing.zalo.**{ *; }
-keep enum com.zing.zalo.**{ *; }
-keep interface com.zing.zalo.**{ *; }

# Keep Flutter plugins that use method channels
# Mixpanel Flutter plugin
-keep class com.mixpanel.android.** { *; }
-keep class com.mixpanel.** { *; }
-keep class com.mixpanel.mixpanel_flutter.** { *; }
-dontwarn com.mixpanel.**

# Keep all Flutter plugin classes to prevent method channel failures
-keep class io.flutter.plugins.** { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$Registrar { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.plugin.common.MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler { *; }
-keep class * implements io.flutter.plugin.common.BinaryMessenger { *; }

# Keep method channel names to prevent obfuscation
-keepclassmembers class * {
    public static final java.lang.String *;
}

-dontwarn com.crashlytics.android.ndk.CrashlyticsNdk
-dontwarn com.google.android.exoplayer2.trackselection.TrackSelectionOverrides$Builder
-dontwarn com.google.android.exoplayer2.trackselection.TrackSelectionOverrides$TrackSelectionOverride
-dontwarn com.google.android.exoplayer2.trackselection.TrackSelectionOverrides
-dontwarn com.google.android.exoplayer2.TracksInfo
-dontwarn com.google.api.client.http.GenericUrl
-dontwarn com.google.api.client.http.HttpHeaders
-dontwarn com.google.api.client.http.HttpRequest
-dontwarn com.google.api.client.http.HttpRequestFactory
-dontwarn com.google.api.client.http.HttpResponse
-dontwarn com.google.api.client.http.HttpTransport
-dontwarn com.google.api.client.http.javanet.NetHttpTransport$Builder
-dontwarn com.google.api.client.http.javanet.NetHttpTransport
-dontwarn org.joda.time.Instant
-dontwarn coil.compose.SingletonAsyncImageKt
-dontwarn com.symbol.emdk.EMDKBase
-dontwarn com.symbol.emdk.EMDKManager$EMDKListener
-dontwarn com.symbol.emdk.EMDKManager$FEATURE_TYPE
-dontwarn com.symbol.emdk.EMDKManager$StatusData
-dontwarn com.symbol.emdk.EMDKManager$StatusListener
-dontwarn com.symbol.emdk.EMDKManager
-dontwarn com.symbol.emdk.EMDKResults$EXTENDED_STATUS_CODE
-dontwarn com.symbol.emdk.EMDKResults$STATUS_CODE
-dontwarn com.symbol.emdk.EMDKResults
-dontwarn com.symbol.emdk.ProfileManager$PROFILE_FLAG
-dontwarn com.symbol.emdk.ProfileManager
-dontwarn io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
-dontwarn us.zoom.prism.R$attr
-dontwarn us.zoom.prism.R$color
-dontwarn us.zoom.prism.R$dimen
-dontwarn us.zoom.prism.R$drawable
-dontwarn us.zoom.prism.R$id
-dontwarn us.zoom.prism.R$layout
-dontwarn us.zoom.prism.R$plurals
-dontwarn us.zoom.prism.R$string
-dontwarn us.zoom.prism.R$style
-dontwarn us.zoom.prism.R$styleable
-dontwarn us.zoom.thirdparty.dialog.NoBrowserDialog
-dontwarn us.zoom.thirdparty.login.util.CustomTabsHelper
# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.microsoft.intune.mam.client.app.MAMComponents
-dontwarn com.microsoft.intune.mam.policy.AppPolicy
-dontwarn com.microsoft.intune.mam.policy.MAMEnrollmentManager
-dontwarn com.microsoft.intune.mam.policy.MAMServiceAuthenticationCallback
-dontwarn com.microsoft.intune.mam.policy.NotificationRestriction
-dontwarn com.zipow.cnthirdparty.cnlogin.model.CnLoginProxy
-dontwarn com.zoualfkar.flutter_zoom.FlutterZoomPlugin
-dontwarn javax.lang.model.element.Element
-dontwarn javax.lang.model.element.ExecutableElement
-dontwarn javax.lang.model.element.Name
-dontwarn javax.lang.model.element.TypeElement
-dontwarn javax.lang.model.type.TypeMirror
-dontwarn us.zoom.apm.apis.ApmIssue
-dontwarn us.zoom.apm.apis.IApmReporter
-dontwarn us.zoom.apm.apis.IssueType
-dontwarn us.zoom.apm.apis.ZoomHostService$ZoomInitializeListener
-dontwarn us.zoom.apm.apis.ZoomHostService
-dontwarn us.zoom.intunelib.AuthenticationCallback
-dontwarn us.zoom.intunelib.IIntuneLoginAssistant
-dontwarn us.zoom.intunelib.InTuneDownloadPolicyActivity
-dontwarn us.zoom.intunelib.InTuneWelcomeActivity
-dontwarn us.zoom.intunelib.MSALUtil
-dontwarn us.zoom.intunelib.ZmIntuneLoginManager
-dontwarn us.zoom.intunelib.ZmIntuneMamManager
-dontwarn us.zoom.thirdparty.login.LoginType
-dontwarn us.zoom.thirdparty.login.ThirdPartyLogin
-dontwarn us.zoom.thirdparty.login.ThirdPartyLoginFactory
-dontwarn us.zoom.thirdparty.login.sso.SsoUtil
-dontwarn xcrash.ICrashCallback
-dontwarn xcrash.XCrash$InitParameters
-dontwarn xcrash.XCrash

# R8 missing classes - optional dependencies from Zoom SDK and other libraries
# BlueParrott SDK (optional dependency)
-dontwarn com.blueparrott.blueparrottsdk.BPHeadset
-dontwarn com.blueparrott.blueparrottsdk.BPHeadsetListener
-dontwarn com.blueparrott.blueparrottsdk.BPSdk
-dontwarn com.blueparrott.blueparrottsdk.IBPHeadsetListener

# ExoPlayer (optional dependency)
-dontwarn com.google.android.exoplayer2.TracksInfo$TrackGroupInfo

# Gson (optional dependency)
-dontwarn com.google.gson.Strictness

# ML Kit Vision (optional dependency for Zoom SDK)
-dontwarn com.google.mlkit.vision.common.InputImage
-dontwarn com.google.mlkit.vision.text.Text$Line
-dontwarn com.google.mlkit.vision.text.Text$TextBlock
-dontwarn com.google.mlkit.vision.text.Text
-dontwarn com.google.mlkit.vision.text.TextRecognition
-dontwarn com.google.mlkit.vision.text.TextRecognizer
-dontwarn com.google.mlkit.vision.text.TextRecognizerOptionsInterface
-dontwarn com.google.mlkit.vision.text.latin.TextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.latin.TextRecognizerOptions

# ZXing (QR code library - optional dependency for Zoom SDK)
-dontwarn com.google.zxing.BarcodeFormat
-dontwarn com.google.zxing.Binarizer
-dontwarn com.google.zxing.BinaryBitmap
-dontwarn com.google.zxing.DecodeHintType
-dontwarn com.google.zxing.EncodeHintType
-dontwarn com.google.zxing.LuminanceSource
-dontwarn com.google.zxing.PlanarYUVLuminanceSource
-dontwarn com.google.zxing.RGBLuminanceSource
-dontwarn com.google.zxing.Reader
-dontwarn com.google.zxing.ReaderException
-dontwarn com.google.zxing.Result
-dontwarn com.google.zxing.ResultMetadataType
-dontwarn com.google.zxing.ResultPoint
-dontwarn com.google.zxing.ResultPointCallback
-dontwarn com.google.zxing.WriterException
-dontwarn com.google.zxing.common.BitMatrix
-dontwarn com.google.zxing.common.DecoderResult
-dontwarn com.google.zxing.common.DetectorResult
-dontwarn com.google.zxing.common.HybridBinarizer
-dontwarn com.google.zxing.qrcode.QRCodeReader
-dontwarn com.google.zxing.qrcode.QRCodeWriter
-dontwarn com.google.zxing.qrcode.decoder.Decoder
-dontwarn com.google.zxing.qrcode.decoder.ErrorCorrectionLevel
-dontwarn com.google.zxing.qrcode.decoder.QRCodeDecoderMetaData
-dontwarn com.google.zxing.qrcode.detector.Detector

# Smart Refresh Layout (optional dependency for Zoom SDK)
-dontwarn com.scwang.smart.refresh.footer.ClassicsFooter
-dontwarn com.scwang.smart.refresh.layout.SmartRefreshLayout
-dontwarn com.scwang.smart.refresh.layout.api.RefreshFooter
-dontwarn com.scwang.smart.refresh.layout.api.RefreshLayout
-dontwarn com.scwang.smart.refresh.layout.listener.OnLoadMoreListener

# Retrofit (optional dependency for Zoom SDK)
-dontwarn retrofit2.Call
-dontwarn retrofit2.CallAdapter$Factory
-dontwarn retrofit2.CallAdapter
-dontwarn retrofit2.Callback
-dontwarn retrofit2.Converter$Factory
-dontwarn retrofit2.Converter
-dontwarn retrofit2.Response
-dontwarn retrofit2.Retrofit$Builder
-dontwarn retrofit2.Retrofit
-dontwarn retrofit2.adapter.rxjava3.RxJava3CallAdapterFactory
-dontwarn retrofit2.http.Body
-dontwarn retrofit2.http.Header
-dontwarn retrofit2.http.POST

# Media3 (for updated ExoPlayer)
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.exoplayer.**

# Additional optimizations for bundle size reduction
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Aggressive optimization
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-allowaccessmodification
-repackageclasses ''