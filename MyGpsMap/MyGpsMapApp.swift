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
import os.log

@main
struct MyGpsMapApp: App {
    
    /// SwiftUI 版でも AppDelegate のような処理をしたい場合は、
    /// UIApplicationDelegateAdaptor を使ってラップできます。
    @UIApplicationDelegateAdaptor(AppDelegateAdaptor.self) var appDelegate
    
    // ここでApp全体に持たせたいステートやサービスを定義してもOK
    // 例:
    // @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            // 起動直後に表示されるコンテンツ(画面)を指定
            // 例として、あなたが今お使いのトップ画面(ViewControllerに相当するSwiftUIビュー)を指定する
            // とりあえず既存の"SignInView"をSwiftUI化するならば、SwiftUIのViewとしてここで指定する形になります。
            // もし既にある程度SwiftUIのビューがあるならそれを使い、なければ新規でContentViewを作成してください。
            
            ContentView() // 例: SwiftUIで作った最初の画面
                .onAppear {
                    // 画面が表示されるタイミングで何か処理したい場合はここへ
                }
        }
    }
}

/// 従来のAppDelegateの代わりとなるクラス
/// SwiftUI側のApp構造体から参照される
class AppDelegateAdaptor: NSObject, UIApplicationDelegate {
    
    var authService = AuthService() // AuthServiceのインスタンスを作成
    var timer: Timer?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureAmplify()
        
        // Taskを使って非同期処理を呼ぶ
        Task {
            await authService.checkSessionStatus() // セッション状態を確認
            LocationManager()
        }

        startTimer()
        
        return true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            // Taskを使って非同期関数を呼び出す
            Task {
                await FriendManager.shared.loadFriendsFromDynamoDB()
                await PinManager.shared.loadFriendsPinsDynamoDB()
            }
        }
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
