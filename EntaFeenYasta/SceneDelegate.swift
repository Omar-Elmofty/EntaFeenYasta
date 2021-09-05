//
//  SceneDelegate.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-13.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        FirebaseApp.configure()
        app_delegate.hangouts = Hangouts()

        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let window = UIWindow(windowScene: windowScene)
            print("Hello")
            if Auth.auth().currentUser != nil
            {
                // Pull current User from firebase
                
                if app_delegate.current_user == nil {
                    app_delegate.current_user = User()
                }
                let user_id = Auth.auth().currentUser!.uid
                app_delegate.current_user!.setID(user_id)
                app_delegate.current_user!.pullFromFirebase(completion: { user in
                    print("Error Retrieving user")
                    window.rootViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.home_view_controller) as UIViewController
                    try! app_delegate.current_user!.populateFriends()
                    return true
                })
            }
            else
            {
                window.rootViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.sign_up_view_controller) as UIViewController
            }
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

