//
//  MyGpsMapApp.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSCore
import AWSS3

@main
struct MyGpsMapApp: App {
    init() {
        print("MyGpsMapApp initialized")
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print("Failed to configure Amplify: \(error)")
        }
    }
}

/// 従来のAppDelegateの代わりとなるクラス
/// SwiftUI側のApp構造体から参照される
class AppDelegateAdaptor: NSObject, UIApplicationDelegate {
    
    var authService = AuthService() // AuthServiceのインスタンスを作成
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureAmplify()
        
        // Taskを使って非同期処理を呼ぶ
        Task {
            await authService.checkSessionStatus() // セッション状態を確認
        }
        
        return true
    }
    
    /// Amplifyの初期化処理（AppDelegateのconfigureAmplifyを移植）
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
            
            // AWSの認証情報を設定
            let credentialsProvider = AWSCognitoCredentialsProvider(
                regionType: .APNortheast1,
                identityPoolId: "ap-northeast-1:5afceccc-9cca-4586-8221-f5f4dc4c7d17"
            )
            
            // カスタムリージョン設定
            let configuration = AWSServiceConfiguration(
                region: .APNortheast1,
                endpoint: AWSEndpoint(
                    region: .APNortheast1,
                    service: .S3,
                    url: URL(string: "https://s3.ap-northeast-1.amazonaws.com")!
                ),
                credentialsProvider: credentialsProvider
            )
            
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            // S3の設定
            AWSS3TransferUtility.register(with: configuration!, forKey: "defaultKey")
            
            print("AWS S3 configured")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
    
    // 以下、もしSceneDelegate相当の処理が必要であれば追加
    // たとえばUISceneSession Lifecycleのフックをしたい場合は下記のように書きます
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // SwiftUI化すると、原則ここは呼ばれなくなるが、
        // iOS13対応などでUISceneConfigurationが必要ならこう書いておく
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // SceneDelegateの sceneDidDisconnect / sceneDidEnterBackground など
        // 必要ならここにまとめます
    }
    
    // CoreData関連があるなら、ここに引き続き置きます
    // （ただしSwiftUIのPersistentCloudKitContainerなどに移行する方法もあります）
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyGpsMap")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
