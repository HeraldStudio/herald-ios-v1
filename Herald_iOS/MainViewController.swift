//
//  MainViewController.swift
//  主界面分页滑动切换
//
//  Created by Howie on 16/3/27.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit
import DHCShakeNotifier

/// 主页面
class MainViewController: UITabBarController {
    
    /// 启动时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 去除界面切换时导航栏的黑影
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        
        // 去除导航栏下的横线
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 去除tabbar上的横线
        tabBar.clipsToBounds = true
        
        tabBar.tintColor = UIColor(red: 0, green: 180/255, blue: 255/255, alpha: 1)
        
        initialize()
    }
    
    func initialize() {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if SettingsHelper.getModuleCardEnabled(Module.Curriculum.rawValue) {
            CurriculumNotifier.scheduleNotifications()
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Experiment.rawValue) {
            ExperimentNotifier.scheduleNotifications()
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Exam.rawValue) {
            ExamNotifier.scheduleNotifications()
        }
        
        if ApiHelper.isLogin() {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onShake), name: DHCSHakeNotificationName, object: nil)
        }
    }
    
    func onShake () {
        if SettingsHelper.getWifiAutoLogin() {
            WifiLoginHelper(self).checkAndLogin()
        }
    }
    
    override func finalize() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DHCSHakeNotificationName, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x00b4ff)
    }
}