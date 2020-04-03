//
//  NotificationsManager.swift
//  BoostersTestTask
//
//  Created by Elias on 03.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import UserNotifications
import Combine
import UIKit

class NotificationsManager: NSObject {
    
    private let center: UNUserNotificationCenter
    private let application: UIApplication
    
    init(
        center: UNUserNotificationCenter = UNUserNotificationCenter.current(),
        application: UIApplication = UIApplication.shared
    ) {
        self.center = center
        self.application = application
        
        super.init()
        
        center.delegate = self
    }
    
    func requestNotificationsAuthorizationIfNeeded() -> AnyPublisher<Void,BoostersError> {
        return Future { [unowned self] promise in
            self.center.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    if settings.soundSetting == .enabled && settings.alertSetting == .enabled {
                        promise(.success(()))
                    } else {
                        promise(.failure(BoostersError.notificationsAuthorizationError))
                    }
                case .denied:
                    promise(.failure(BoostersError.notificationsAuthorizationError))
                case .notDetermined:
                    self.center.requestAuthorization(options: [.sound, .alert]) { (isGranted, error) in
                        if isGranted {
                            promise(.success(()))
                        } else {
                            promise(.failure(BoostersError.notificationsAuthorizationError))
                        }
                    }
                @unknown default:
                    fatalError("undefined case")
                    
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func scheduleNotification(
        at date: Date,
        soundName: String,
        identifier: String,
        title: String,
        subtitle: String,
        completion: (Error) -> Void
    ) {
    let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle 
        content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        center.add(request) {
            $0.map { print($0.localizedDescription) }
        }
    }
   
    func removePendingNotification(with identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
}

extension NotificationsManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent notification")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
           print("didReceive response")
    }
    
}

