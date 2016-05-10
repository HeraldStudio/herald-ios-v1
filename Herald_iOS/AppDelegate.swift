//
//  AppDelegate.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/10.
//  Copyright © 2016年 于海通. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(application: UIApplication) {
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //判断是否是首次启动
        let launchTimes = SettingsHelper.getLaunchTimes()
        if launchTimes == 0 {
            SettingsHelper.setDefaultConfig()
        }
        
        //启动次数递增
        SettingsHelper.updateLaunchTimes(launchTimes + 1)
        
        if !ApiHelper.isLogin() {
            showLogin()
        }
        
        if #available(iOS 9.0, *) {
            let test1 = UIApplicationShortcutItem.init(type: "exam", localizedTitle: "考试助手", localizedSubtitle: "", icon: UIApplicationShortcutIcon.init(templateImageName: "pre_exam"), userInfo: nil)
            let test2 = UIApplicationShortcutItem.init(type: "curriculum", localizedTitle: "课表助手", localizedSubtitle: "", icon: UIApplicationShortcutIcon.init(templateImageName: "pre_curriculum"), userInfo: nil)
            let test3 = UIApplicationShortcutItem.init(type: "card", localizedTitle: "一卡通充值", localizedSubtitle: "", icon: UIApplicationShortcutIcon.init(templateImageName: "pre_card"), userInfo: nil)
            application.shortcutItems = [test1,test2,test3]
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        var desVC = String()
        switch shortcutItem.type {
        case "exam":
            desVC = "MODULE_QUERY_EXAM"
        case "curriculum":
            desVC = "MODULE_QUERY_CURRICULUM"
        case "card":
            desVC = "WEBMODULE"
        default:
            return
        }
        
        let view = self.window?.rootViewController as! UINavigationController
        if desVC == "WEBMODULE" {
            CacheHelper.set("herald_webmodule_title", "充值")
            CacheHelper.set("herald_webmodule_url", "http://58.192.115.47:8088/wechat-web/login/initlogin.html")
            
            let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE")
            view.pushViewController(detailVC, animated: true)

        } else {
            let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(desVC)
            view.pushViewController(detailVC, animated: true)
        }
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func showLogin () {
        self.window?.rootViewController = nil
        let lvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("login")
        self.window?.rootViewController = lvc
    }
}

