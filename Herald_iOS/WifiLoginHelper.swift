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
        
        /// 此段代码需要使用用户名和密码，先判断是否处于未登录状态
        if !ApiHelper.isLogin() {
            if let wholeController = AppDelegate.instance.wholeController {
                wholeController.showQuestionDialog("您处于未登录状态，校园网快捷登录功能需要登录或自定义账号才能使用，是否立即登录？"){
                    AppDelegate.showLogin()
                }
            }
        } else {// 若非未登录状态，进入下面的流程
            
            if WifiLoginHelper.working { return }
            WifiLoginHelper.working = true
            
            //vc.showTipDialogIfUnknown("注意：请先进入 [设置]-[Wi-Fi]-\"seu-wlan\" 右侧的 [i] 按钮，关闭 [自动连接]，才能正常使用~", cachePostfix: "wifi") {
            self.vc.showProgressDialog()
            self.beginCheck()
            //}
        }
    }
    
    private func beginCheck () {
        ApiSimpleRequest(.Post).url("https://selfservice.seu.edu.cn/selfservice/index.php")
            .onResponse { success, code, response in
            if !response.containsString("403 Forbidden") {
                self.checkOnlineStatus()
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("校园网状态异常，请先手动连接到 seu-wlan，并等待网络图标变成 Wi-Fi 图标之后再试~\n\n如果系统弹出登录页面，请到 Wi-Fi 设置中关闭 seu-wlan 的 [自动登录] 功能再试~")
            }
        }.runWithoutFatalListener()
    }
    
    private func checkOnlineStatus () {
        ApiSimpleRequest(.Get).url("http://w.seu.edu.cn/portal/init.php")
            .onResponse { success, _, response in
            if success {
                if response.containsString("notlogin") {
                    // 未登录状态，直接登录
                    //self.vc.showMessage("摇一摇：未登录状态，正在尝试登录~")
                    self.loginToService()
                    
                    /// 此处由于已经判断用户已登录，故断言 ApiHelper.getWifiUserName() 非空
                } else if !response.containsString(ApiHelper.getWifiUserName()) {
                    // 已登录，但账号与当前设置的账号不同
                    //self.vc.showMessage("摇一摇：已登录其它账号，正在尝试退出~")
                    self.logoutThenLogin()
                } else {
                    self.vc.hideProgressDialog()
                    WifiLoginHelper.working = false
                    self.vc.showMessage("已登录校园网，无需重复登录~")
                }
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("校园网信号不佳，换个姿势试试？")
            }
        }.run()
    }
    
    private func logoutThenLogin () {
        ApiSimpleRequest(.Post).url("http://w.seu.edu.cn/portal/logout.php")
            .onResponse { success, _, response in
            if success {
                self.loginToService()
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("已登录账号退出失败，请重试~")
            }
        }.run()
    }
    
    private func loginToService () {
        /// 此处由于已经判断用户已登录，故断言 ApiHelper.getWifiUserName()/getWifiPassword() 非空
        let username = ApiHelper.getWifiUserName()
        let password = ApiHelper.getWifiPassword()
        
        /// 前方大坑！前方大坑！
        // w.seu.edu.cn 的服务器在登录的时候是按参数顺序取参数的，第一个参数作为用户名，
        // 第二个参数作为密码，而 Alamofire 传参数时会将 Key 按字母顺序排序，因此若用户名 Key
        // 为 username ，密码 Key 为 password，会导致参数倒置，登录失败！
        ApiSimpleRequest(.Post).url("http://w.seu.edu.cn/portal/login.php")
            .post("p1", username, "p2", password)
            .onResponse { success, _, response in
                if success {
                    let info = JSON.parse(response)
                    if info["login_username"].string != nil
                        && info["login_index"].string != nil
                        && info["login_ip"].string != nil
                        && info["login_location"].string != nil
                        && info["login_expire"].string != nil
                        && info["login_remain"].int != nil
                        && info["login_time"].int != nil {
                        self.vc.showMessage("小猴登录校园网成功~")
                    } else {
                        if let error = JSON.parse(response)["error"].string {
                            self.vc.showMessage("登录失败：\(error.replaceAll(",", "，"))")
                        } else {
                            self.vc.showMessage("登录失败，出现未知错误")
                        }
                    }
                } else {
                    self.vc.showMessage("校园网信号不佳，换个姿势试试？")
                }
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
        }.run()
    }
}




















