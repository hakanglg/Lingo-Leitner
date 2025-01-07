//
//  AppDelegate.swift
//  Lingo Leitner
//
//  Created by Hakan Gölge on 3.01.2025.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Firebase yapılandırması başlıyor...")
        FirebaseApp.configure()
        
        // Firebase yapılandırmasını kontrol edelim
        if let projectID = FirebaseApp.app()?.options.projectID {
            print("Firebase project ID: \(projectID)")
        }
        
        print("Firestore instance kontrol ediliyor...")
        let db = Firestore.firestore()
        print("Firestore instance oluşturuldu: \(db)")
        
        // Google Sign In yapılandırması
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

