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
        if ApiHelper.isWifiLoginAvailable() {
            
            if WifiLoginHelper.working { return }
            WifiLoginHelper.working = true
            self.beginCheck()
        } else {
            self.vc.showMessage("请登录")
        }
    }
    
    private func beginCheck () {
        ApiSimpleRequest(.post).url("http://selfservice.seu.edu.cn/selfservice/index.php")
            .onResponse { success, code, response in
                if !response.contains("403 Forbidden") {
                    self.checkOnlineStatus()
                } else {
                    WifiLoginHelper.working = false
                    self.vc.showMessage("SEU未连接")
                }
            }.runWithoutFatalListener()
    }
    
    private func checkOnlineStatus () {
        ApiSimpleRequest(.get).url("http://w.seu.edu.cn/index.php/index/init")
            .onResponse { success, _, response in
                if success {
                    let responseJSON = JSON.parse(response)
                    
                    if responseJSON["status"].intValue == 0 {
                        
                        self.loginToService()
                        
                    } else if responseJSON["logout_username"].stringValue != ApiHelper.getWifiUserName() {
                        
                        self.logoutThenLogin()
                        
                    } else {
                        WifiLoginHelper.working = false
                        self.vc.showMessage("SEU已登录")
                        
                    }
                } else {
                    WifiLoginHelper.working = false
                    self.vc.showMessage("SEU信号差")
                }
            }.run()
    }
    
    public func checkOnly() {
        ApiSimpleRequest(.post).url("http://selfservice.seu.edu.cn/selfservice/index.php")
            .onResponse { success, code, response in
                if !response.contains("403 Forbidden") {
                    ApiSimpleRequest(.get).url("http://w.seu.edu.cn/index.php/index/init")
                        .onResponse { success, _, response in
                            if success {
                                let responseJSON = JSON.parse(response)
                                if responseJSON["status"].intValue == 0 {
                                    self.vc.showMessage("登录SEU")
                                } else if responseJSON["logout_username"].stringValue != ApiHelper.getWifiUserName() {
                                    self.vc.showMessage("登录SEU")
                                } else {
                                    WifiLoginHelper.working = false
                                    self.vc.showMessage("SEU已登录")
                                }
                            } else {
                                WifiLoginHelper.working = false
                                self.vc.showMessage("SEU信号差")
                            }
                        }.run()
                } else {
                    WifiLoginHelper.working = false
                    self.vc.showMessage("SEU未连接")
                }
            }.runWithoutFatalListener()
    }
    
    private func logoutThenLogin () {
        ApiSimpleRequest(.post).url("http://w.seu.edu.cn/index.php/index/logout")
            .onResponse { success, _, response in
                if success {
                    self.loginToService()
                } else {
                    WifiLoginHelper.working = false
                    self.vc.showMessage("SEU信号差")
                }
            }.run()
    }
    
    private func loginToService () {
        let username = ApiHelper.getWifiUserName()
        let password = ApiHelper.getWifiPassword()
        
        let passwordData = password.data(using: String.Encoding.utf8)
        
        let passwordEncoded = passwordData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) ?? ""
        
        ApiSimpleRequest(.post).url("http://w.seu.edu.cn/index.php/index/login")
            .post("username", username, "password", passwordEncoded, "enablemacauth", "1")
            .onResponse { success, _, response in
                if success {
                    let info = JSON.parse(response)
                    if info["status"].intValue == 1 {
                        self.vc.showMessage("SEU已登录")
                    } else {
                        if info["info"].string != nil {
                            self.vc.showMessage("请开通或续费")
                        } else {
                            self.vc.showMessage("SEU信号差")
                        }
                    }
                } else {
                    self.vc.showMessage("SEU信号差")
                }
                WifiLoginHelper.working = false
            }.run()
    }
}




















