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
        
        tabBar.tintColor = UIColor(red: 0, green: 180/255, blue: 255/255, alpha: 1)
    }
    
    func initialize() {
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