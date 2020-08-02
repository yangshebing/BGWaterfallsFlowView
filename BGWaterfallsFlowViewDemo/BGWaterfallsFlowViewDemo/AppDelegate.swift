//
//  AppDelegate.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if window != nil {
            let window = self.window!
            window.backgroundColor = .white
            window.rootViewController = MainViewController()
            window.makeKeyAndVisible()
        }
        
        return true
    }
}
