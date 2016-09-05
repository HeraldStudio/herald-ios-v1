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
        
        /// 此段代码需要使用 Wifi 用户名和密码，先判断是否已登录或已自定义Wifi账号
        if !ApiHelper.isWifiLoginAvailable() {
            if let wholeController = AppDelegate.instance.wholeController {
                wholeController.showQuestionDialog("App处于未登录状态，校园网快捷登录功能需要登录App或设置自定义账号才能使用，是否立即登录？"){
                    
                    AppDelegate.showLogin()
                }
            }
        } else {// 若非未登录状态，进入下面的流程
            
            if WifiLoginHelper.working { return }
            WifiLoginHelper.working = true
            
            self.vc.showProgressDialog()
            self.beginCheck()
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
                self.vc.showMessage("校园网快捷登录：状态异常，请先手动连接到 seu-wlan，并等待网络图标变成 Wi-Fi 图标之后再试~\n\n如果系统弹出登录页面，请到 Wi-Fi 设置中关闭 seu-wlan 的 [自动登录] 功能再试~")
            }
        }.runWithoutFatalListener()
    }
    
    private func checkOnlineStatus () {
        ApiSimpleRequest(.Get).url("http://w.seu.edu.cn/index.php/index/init")
            .onResponse { success, _, response in
            if success {
                let responseJSON = JSON.parse(response)
                
                if responseJSON["status"].intValue == 0 {
                    
                    self.loginToService()
                    
                } else if responseJSON["logout_username"].stringValue != ApiHelper.getWifiUserName() {
                    
                    self.logoutThenLogin()
                    
                } else {
                    
                    self.vc.hideProgressDialog()
                    WifiLoginHelper.working = false
                    self.vc.showMessage("校园网快捷登录：已登录状态，无需重复登录~")
                    
                }
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("校园网快捷登录：信号不佳，换个姿势试试？")
            }
        }.run()
    }
    
    private func logoutThenLogin () {
        ApiSimpleRequest(.Post).url("http://w.seu.edu.cn/index.php/index/logout")
            .onResponse { success, _, response in
            if success {
                self.loginToService()
            } else {
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
                self.vc.showMessage("校园网快捷登录：已登录账号退出失败，请重试~")
            }
        }.run()
    }
    
    private func loginToService () {
        let username = ApiHelper.getWifiUserName()
        let password = ApiHelper.getWifiPassword()
            
        let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)
            
        let passwordEncoded = passwordData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) ?? ""
        
        ApiSimpleRequest(.Post).url("http://w.seu.edu.cn/index.php/index/login")
            .post("username", username, "password", passwordEncoded, "enablemacauth", "1")
            .onResponse { success, _, response in
                if success {
                    let info = JSON.parse(response)
                    if info["status"].intValue == 1 {
                        self.vc.showMessage("校园网快捷登录成功~")
                    } else {
                        if let error = info["info"].string {
                            self.vc.showMessage("校园网快捷登录失败：\(error)")
                        } else {
                            self.vc.showMessage("校园网快捷登录：信号不佳，换个姿势试试？")
                        }
                    }
                } else {
                    self.vc.showMessage("校园网快捷登录：信号不佳，换个姿势试试？")
                }
                self.vc.hideProgressDialog()
                WifiLoginHelper.working = false
            }.run()
    }
}




















