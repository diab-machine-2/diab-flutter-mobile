import UIKit
import Flutter
import BranchSDK

@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {

    // MARK: - Cold Start: scene连接时 (app刚启动)
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // CRITICAL: Capture URL TRƯỚC super — Flutter engine và plugins chưa sẵn sàng
        // Nếu không capture ở đây, URL deep link sẽ bị mất vĩnh viễn (iOS 26+)
        
        // Universal Link (NSUserActivity) cold start
        for activity in connectionOptions.userActivities
            where activity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = activity.webpageURL {
                AppDelegate.pendingInitialDeepLink = url.absoluteString
                break
            }
        }
        
        // Custom scheme URL cold start
        if let ctx = connectionOptions.urlContexts.first {
            AppDelegate.pendingInitialDeepLink = ctx.url.absoluteString
        }
        
        // Forward to BranchScene ngay lập tức (plugins chưa register nên phải tự forward)
        if let userActivity = connectionOptions.userActivities.first {
            BranchScene.shared().scene(scene, continue: userActivity)
        } else if !connectionOptions.urlContexts.isEmpty {
            BranchScene.shared().scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    // MARK: - Warm Universal Link (app đang chạy, click Universal Link)
    override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Gọi super trước → dispatch đến flutter_branch_sdk plugin
        super.scene(scene, continue: userActivity)
        
        // Safety net: capture URL phòng plugin miss event
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            AppDelegate.pendingInitialDeepLink = url.absoluteString
        }
    }

    // MARK: - Warm custom scheme URL (app đang chạy, click branchdiab://...)
    override func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        super.scene(scene, openURLContexts: URLContexts)
        
        if let ctx = URLContexts.first {
            AppDelegate.pendingInitialDeepLink = ctx.url.absoluteString
        }
    }
}
