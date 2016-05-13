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
    
    static var working = false
    
    init (_ vc : UIViewController) {
        self.vc = vc
    }
    
    func checkAndLogin () {
        if WifiLoginHelper.working { return }
        WifiLoginHelper.working = true
        
        vc.showTipDialogIfUnknown("欢迎使用摇一摇登录校园网~\n由于iOS限制，快跟小猴学使用姿势：\n\n1、请在系统[设置]-[Wi-Fi]-[seu-wlan]-关闭[自动连接]开关才能正常使用~\n\n2、摇一摇之前请手动连接seu-wlan，等状态栏出现Wi-Fi图标后（如果没出现请参照第1条）即可在小猴首页摇一摇登录~", cachePostfix: "wifi") {
            self.vc.showProgressDialog()
            //self.vc.showMessage("摇一摇：正在检测网络环境~")
            self.beginCheck()
        }
    }
    
    private func beginCheck () {
        ApiRequest().url("https://selfservice.seu.edu.cn/selfservice/index.php").noCheck200().onFinish { success, code, response in
            if !response.containsString("403 Forbidden") {
                self.vc.showMessage("摇一摇：坐稳扶好，准备发车啦~")
                //self.vc.showMessage("摇一摇：网络通畅，正在查询登录状态~")
                self.checkOnlineStatus()
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("摇一摇：网络异常，请先手动连接到seu-wlan~")
            }
        }.run()
    }
    
    private func checkOnlineStatus () {
        ApiRequest().get().url("http://w.seu.edu.cn/portal/init.php").noCheck200().onFinish { success, _, response in
            if success {
                if response.containsString("notlogin") {
                    // 未登录状态，直接登录
                    //self.vc.showMessage("摇一摇：未登录状态，正在尝试登录~")
                    self.loginToService()
                } else if !response.containsString(ApiHelper.getWifiUserName()) {
                    // 已登录，但账号与当前设置的账号不同
                    //self.vc.showMessage("摇一摇：已登录其它账号，正在尝试退出~")
                    self.logoutThenLogin()
                } else {
                    self.vc.hideProgressDialog()
                    WifiLoginHelper.working = false
                    self.vc.showMessage("摇一摇：已登录状态，不用再摇了~")
                }
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("摇一摇：信号有点差，换个姿势试试？")
            }
        }.run()
    }
    
    private func logoutThenLogin () {
        ApiRequest().url("http://w.seu.edu.cn/portal/logout.php").noCheck200().onFinish { success, _, response in
            if success {
                //self.vc.showMessage("摇一摇：退出成功，正在尝试登录~")
                self.loginToService()
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("摇一摇：已登录账号退出失败，请重试~")
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
                        self.vc.showMessage("摇一摇：小猴登陆校园网成功~")
                    } else {
                        if let error = JSON.parse(response)["error"].string {
                            self.vc.showMessage("摇一摇：登录失败，\(error.replaceAll(",", "，"))")
                        } else {
                            self.vc.showMessage("摇一摇：登录失败，出现未知错误")
                        }
                    }
                } else {
                    self.vc.showMessage("摇一摇：信号有点差，换个姿势试试？")
                }
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
        }.run()
    }
}




















