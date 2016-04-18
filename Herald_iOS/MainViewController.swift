//
//  MainViewController.swift
//  主界面分页滑动切换
//
//  Created by Howie on 16/3/27.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

/// 主页面
class MainViewController: UITabBarController{
    
    /// 启动时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 去除界面切换时导航栏的黑影
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        
        tabBar.tintColor = UIColor.orangeColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        if !ApiHelper.isLogin() {
            presentViewController(storyboard!.instantiateViewControllerWithIdentifier("login"), animated: false) {}
        }
    }
}