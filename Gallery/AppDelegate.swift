//
//  AppDelegate.swift
//  Gallery
//
//  Created by Dima Surkov on 01.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: SearchCollectionViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
