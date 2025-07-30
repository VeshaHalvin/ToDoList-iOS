//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let useEmulator = UserDefaults.standard.bool(forKey: "useEmulator")
        if useEmulator{
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
            
            Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    func application(_ application: UIApplication,
                         didReceiveRemoteNotification notification: [AnyHashable : Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        completionHandler(.noData)
    }
}

@main
struct TodoListApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    
    var body: some Scene {
            WindowGroup {
                if authViewModel.isSignedIn {
                    TodoListView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
}
