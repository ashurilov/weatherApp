//
//  AppDelegate.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 04.05.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let mapScreenViewController = MapScreenViewController()
    lazy var navigationController = UINavigationController(rootViewController: mapScreenViewController)
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

