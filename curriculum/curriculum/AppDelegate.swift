//
//  AppDelegate.swift
//  curriculum
//
//  Created by 于海通 on 16/2/24.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?;

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds);
        window!.backgroundColor = UIColor.whiteColor();
        window!.makeKeyAndVisible();
        let controller = ViewController();
        let nav = UINavigationController(rootViewController: controller);
        window!.rootViewController = nav;
        controller.topPadding = nav.navigationBar.frame.maxY;
        //nav.navigationBar.barStyle = .Black;
        nav.navigationBar.tintColor = UIColor(red: 0.0, green: 171/255.0, blue: 212/255.0, alpha: 1.0);
        //nav.navigationBar.barTintColor = UIColor(red: 0.0, green: 171/255.0, blue: 212/255.0, alpha: 1.0);
        //nav.navigationBar.opaque = false;
        
        return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }


}

