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

class WifiLoginHelper {
    
    var vc : UIViewController
    
    init (_ vc : UIViewController) {
        self.vc = vc
    }
    
    func checkAndLogin () {
        vc.showTipDialogIfUnknown("欢迎使用摇一摇登录校园网~\n由于iOS限制，快跟小猴学使用姿势：\n\n1、请在系统[设置]-[Wi-Fi]-[seu-wlan]-关闭[自动连接]开关才能正常使用~\n\n2、摇一摇之前请手动连接seu-wlan，等状态栏出现Wi-Fi图标后（如果没出现请参照第1条）即可在小猴首页摇一摇登录~", cachePostfix: "wifi") {
            self.beginCheck()
        }
    }
    
    private func beginCheck () {
        self.vc.showMessage("正在检测网络环境~")
        ApiRequest().url("https://selfservice.seu.edu.cn/selfservice/index.php").noCheck200().onFinish { success, code, response in
            if !response.containsString("403 Forbidden") {
                self.vc.showMessage("网络通畅，正在尝试登录~")
                self.checkOnlineStatus()
            } else {
                self.vc.showMessage("请先手动连接到seu-wlan~")
            }
        }.run()
    }
    
    private func checkOnlineStatus () {
        ApiRequest().get().url("http://w.seu.edu.cn/portal/init.php").noCheck200().onFinish { success, _, response in
            if success {
                // 如果已经登陆的账号与当前设置的校园网账号不同，也视为未登录
                if response.containsString("notlogin") || !response.containsString(ApiHelper.getWifiUserName()) {
                    // 未登录状态，开始登录
                    self.loginToService()
                } else {
                    self.vc.showMessage("你已经登录校园网，不用再摇了~")
                }
            } else {
                self.vc.showMessage("似乎信号有点差，换个姿势试试？")
            }
        }.run()
    }
    
    private func loginToService () {
        let username = ApiHelper.getWifiUserName()
        let password = ApiHelper.getWifiPassword()
        
        ApiRequest().url("http://w.seu.edu.cn/portal/login.php").noCheck200()
            .post("p1", username, "p2", password)
            .onFinish { success, _, response in
                if success {
                    let info = JSON.parse(response)
                    if info["login_username"].string != nil
                        && info["login_index"].string != nil
                        && info["login_ip"].string != nil
                        && info["login_location"].string != nil
                        && info["login_expire"].string != nil
                        && info["login_remain"].int != nil
                        && info["login_time"].int != nil {
                        self.vc.showMessage("小猴已经成功帮你登陆seu网络啦")
                    } else {
                        if let error = JSON.parse(response)["error"].string {
                            self.vc.showMessage("登录失败，\(error)")
                        } else {
                            self.vc.showMessage("登录失败，出现未知错误")
                        }
                    }
                } else {
                    self.vc.showMessage("似乎信号有点差，不妨换个姿势试试？")
                }
        }.run()
    }
}




















