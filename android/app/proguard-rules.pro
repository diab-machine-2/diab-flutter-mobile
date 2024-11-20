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