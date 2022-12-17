//
//  moveOnApp.swift
//  moveOn
//
//  Created by Nourah Almusaad on 08/12/2022.
//

import SwiftUI
import FirebaseMessaging
import Firebase
import UserNotifications


@main
struct moveOnApp: App {
 //   @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
 
            WindowGroup {
                Path()
            }
        
    }
}



class AppDelegate: NSObject, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      UNUserNotificationCenter.current().delegate = self
      Messaging.messaging().delegate = self

      if #available(iOS 10.0, *){
          UNUserNotificationCenter.current().delegate = self
          
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
      }
      else {
          let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
      }

         application.registerForRemoteNotifications()

    return true
  }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }


    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrievedd: \(deviceToken.base64EncodedString())")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)


    }
    

 
    
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
     
        print(dataDict)
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      let userInfo = notification.request.content.userInfo

      if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
      }

      print(userInfo)

      // Change this to your preferred presentation option
      completionHandler([[.banner, .badge, .sound]])
    }
  
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        print(userInfo)

        completionHandler()
      }
}
