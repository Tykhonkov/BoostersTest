//
//  SceneDelegate.swift
//  BoostersTestTask
//
//  Created by Elias on 31.03.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        
        let soundFileURL = Bundle.main.resourceURL("nature.mp4")
        let alarmSoundFileURL = Bundle.main.resourceURL("alarm.mp4")

        let configuration = BoostersWorkflowCoordinator.BoostersCoordinatorConfiguration(
            audioSession: AudioSession(),
            audioPlayer: BoostersAudioPlayer(),
            audioRecorder: BoostersAudioRecorder(),
            notificationsManager: NotificationsManager(),
            soundFileURL: soundFileURL,
            alarmSoundName: "alarm3.aifc",
            alarmSoundURL: alarmSoundFileURL,
            sleepSoundDuratioon: 20 * 60,
            shouldPlayNatureSound: true,
            isRecordingEnabled: true
        )
        
        let viewModel = MainViewModel(workflowCoordinator: BoostersWorkflowCoordinator(configuration: configuration))
        let mainView = MainView(viewModel: viewModel)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: mainView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

}
