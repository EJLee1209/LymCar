//
//  AppDelegate.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var fcmToken: String?
    var viewingChatRoomId = ""
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        /// 원격 알림 등록
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        /// 메세징 델리게이트
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    /// fcm 토큰이 등록되었을 때, apns와 연결
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// 앱이 켜져 있을 때 푸시가 온 경우
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        guard let roomId = userInfo["roomId"] as? String else { return }
           
        if viewingChatRoomId != roomId { // 채팅방을 보고 있지 않은 경우에만 푸시 알림 표시
            completionHandler([.banner, .sound])
        }
    }
    
    /// 백그라운드에 푸시가 온 경우
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        completionHandler()
    }
}

//MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    /// fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.fcmToken = fcmToken
    }
}
