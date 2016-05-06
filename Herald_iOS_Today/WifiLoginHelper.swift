//
//  WifiLoginHelper.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/5.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class WifiLoginHelper {
    
    var vc : UIViewController
    
    init (_ vc : UIViewController) {
        self.vc = vc
    }
    
    func checkAndLogin () {
        self.beginCheck()
    }
    
    private func beginCheck () {
        Alamofire.request(.POST, "http://w.seu.edu.cn").responseString { response in
            if response.result.isSuccess {
                self.checkOnlineStatus()
            }
        }
    }
    
    private func checkOnlineStatus () {
        Alamofire.request(.POST, "http://w.seu.edu.cn/portal/init.php").responseString(completionHandler: { response in
            if response.result.isSuccess {
                // 如果已经登陆的账号与当前设置的校园网账号不同，也视为未登录
                if response.result.value!.containsString("notlogin") {
                    // 未登录状态，开始登录
                    self.loginToService()
                } else {
                    self.vc.showMessage("你已经登录校园网，不用再摇了~")
                }
            } else {
                self.vc.showMessage("似乎信号有点差，不妨换个姿势试试？")
            }
        })
    }
    
    private func loginToService () {
        let username = ApiHelper.getWifiUserName()
        let password = ApiHelper.getWifiPassword()
        
        Alamofire.request(.POST, "http://w.seu.edu.cn/portal/login.php",
            parameters: ["p1":username, "p2":password]).responseString(completionHandler: { (response) in
                if response.result.isSuccess {
                    let info = JSON.parse(response.result.value!)
                    if info["login_username"].string != nil
                        && info["login_index"].string != nil
                        && info["login_ip"].string != nil
                        && info["login_location"].string != nil
                        && info["login_expire"].string != nil
                        && info["login_remain"].int != nil
                        && info["login_time"].int != nil {
                        self.vc.showMessage("小猴已经成功帮你登陆seu网络啦")
                    } else {
                        if let error = JSON.parse(response.result.value!)["error"].string {
                            self.vc.showMessage("登录失败，\(error)")
                        } else {
                            self.vc.showMessage("登录失败，出现未知错误")
                        }
                    }
                } else {
                    self.vc.showMessage("似乎信号有点差，不妨换个姿势试试？")
                }
            })
    }
}




















