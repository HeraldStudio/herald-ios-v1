//
//  ApiHelper.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class ApiHelper : NSObject {
    // heraldstudio.com 主站API
    static let WWW_ROOT = "http://www.heraldstudio.com/"
    static let API_ROOT = WWW_ROOT + "api/"
    
    static let auth_url = WWW_ROOT + "uc/auth"
    static let auth_update_url = WWW_ROOT + "uc/update"
    static let wechat_lecture_notice_url = WWW_ROOT + "wechat2/lecture"
    static let feedback_url = WWW_ROOT + "service/feedback"
    
    static let appid = "34cc6df78cfa7cd457284e4fc377559e"
    
    static let authCache = NSUserDefaults.withPrefix("auth_")
    
    static func getApiUrl (api : String) -> String {
        return API_ROOT + api
    }
    
    // TODO dealApiException
    
    static func doLogout (context : UIViewController?) {
        
        //清除授权信息
        authCache.set("authUser", "")
        authCache.set("authPwd", "")
        authCache.set("uuid", "")
        authCache.set("cardnum", "")
        authCache.set("schoolnum", "")
        authCache.set("name", "")
        authCache.set("sex", "")
        
        // 清除模块缓存
        // 注意此处的clearAllmoduleCache里的authUser和authPwd与上面清除的是不同的
        CacheHelper.clearAllModuleCache()
        
        // 跳转到登录页
        if let nc = context {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("login")
            nc.presentViewController(vc, animated: true) {}
        }
    }
    
    static func isLogin () -> Bool {
        let uuid = authCache.get("uuid")
        return uuid != ""
    }
    
    static func getUUID () -> String {
        return authCache.get("uuid")
    }
    
    static func setAuth (user user : String, pwd : String) {
        // TODO 加密
        CacheHelper.set("authUser", cacheValue: user)
        CacheHelper.set("authPwd", cacheValue: pwd)
    }
    
    static func getUserName () -> String {
        return CacheHelper.get("authUser")
    }
    
    static func getPassword () -> String {
        return CacheHelper.get("authPwd")
    }
    
    static func setWifiAuth (user user : String, pwd : String) {
        // TODO 加密
        CacheHelper.set("wifiAuthUser", cacheValue: user)
        CacheHelper.set("wifiAuthPwd", cacheValue: pwd)
    }
    
    static func getWifiUserName () -> String {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cacheUser = CacheHelper.get("wifiAuthUser")
        return cacheUser == "" ? getUserName() : cacheUser
    }
    
    static func getWifiPassword () -> String {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cachePwd = CacheHelper.get("authPwd")
        return cachePwd == "" ? getPassword() : cachePwd
    }
    
    static func clearWifiAuth () {
        // TODO 若实现了加密，这里也应该对应修改
        setWifiAuth(user: "", pwd: "")
    }
    
    let authCache = NSUserDefaults.withPrefix("auth_")
    
    static func getAuthCache (key : String) -> String {
        return authCache.get(key)
    }
    
    static func setAuthCache (key : String, _ value : String) {
        authCache.set(key, value)
    }

    static func getSchoolnum () -> String {
        return authCache.get("schoolnum")
    }
}