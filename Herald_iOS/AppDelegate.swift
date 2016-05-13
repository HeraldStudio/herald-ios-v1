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
        
        let settings = UIUserNotificationSettings(forTypes: [/*.Badge,*/ .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        //判断是否登录
        if !ApiHelper.isLogin() {
            showLogin()
            return
        }
        
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
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        application.applicationIconBadgeNumber -= 1
    }

    func showLogin () {
        self.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        self.window?.rootViewController = nil
        let lvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("login")
        self.window?.rootViewController = lvc
    }
    
    func showMain () {
        self.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        self.window?.rootViewController = nil
        let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("main")
        self.window?.rootViewController = mvc
    }
}

