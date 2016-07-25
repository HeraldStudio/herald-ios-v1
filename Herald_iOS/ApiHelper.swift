import UIKit

/**
 * ApiHelper | API相关、登录相关
 */
class ApiHelper {
    // heraldstudio.com 主站API
    static let WWW_ROOT = "http://www.heraldstudio.com/"
    static let API_ROOT = WWW_ROOT + "api/"
    
    static let auth_url = WWW_ROOT + "uc/auth"
    static let auth_update_url = WWW_ROOT + "uc/update"
    static let wechat_lecture_notice_url = WWW_ROOT + "wechat2/lecture"
    static let feedback_url = WWW_ROOT + "service/feedback"
    
    static let appid = "9f9ce5c3605178daadc2d85ce9f8e064"
    
    /// 试用登陆时的uuid、学号和一卡通号
    static let trialUuid = "00000000000000000000000000000000"
    static let trialUserName = "000000000"
    static let trialSchoolnum = "00000000"
    
    static let authCache = NSUserDefaults.withPrefix("auth_")
    
    static func getApiUrl (api : String) -> String {
        return API_ROOT + api
    }
    
    static func doLogout (message: String?) {
        
        //清除授权信息
        authCache.set("authUser", "")
        authCache.set("authPwd", "")
        authCache.set("uuid", "")
        authCache.set("cardnum", "")
        authCache.set("schoolnum", "")
        authCache.set("name", "")
        authCache.set("sex", "")
        
        // 清除通知
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // 清除模块缓存
        // 注意此处的clearAllmoduleCache里的authUser和authPwd与上面清除的是不同的
        CacheHelper.clearAllModuleCache()
        
        let vc = AppDelegate.instance.showLogin()
        if let message = message {
            vc.showMessage(message)
        }
    }
    
    static func isLogin () -> Bool {
        return getUUID() != ""
    }
    
    static func isTrial () -> Bool {
        return getUUID() == ApiHelper.trialUuid
    }
    
    static func getUUID () -> String {
        return authCache.get("uuid")
    }
    
    /// 试用登陆时，此函数不需要调用，即不需要关心用户名和密码缓存的值，
    /// 因为试用登陆时取得的用户名和密码已被下面两个函数直接短路为nil
    static func setAuth (user user : String, pwd : String) {
        // TODO 加密
        CacheHelper.set("authUser", user)
        CacheHelper.set("authPwd", pwd)
    }
    
    /// 试用登陆时，取用户名和密码均为空
    static func getUserName () -> String? {
        if !isLogin() || isTrial() { return nil }
        return CacheHelper.get("authUser")
    }
    
    /// 试用登陆时，取用户名和密码均为空
    static func getPassword () -> String? {
        if !isLogin() || isTrial() { return nil }
        return CacheHelper.get("authPwd")
    }
    
    static func setWifiAuth (user user : String, pwd : String) {
        // TODO 加密
        CacheHelper.set("wifiAuthUser", user)
        CacheHelper.set("wifiAuthPwd", pwd)
    }
    
    /// 试用登陆且没设置自定义账号时，取 Wifi 用户名和密码均为空
    static func getWifiUserName () -> String? {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cacheUser = CacheHelper.get("wifiAuthUser")
        return cacheUser == "" ? getUserName() : cacheUser
    }
    
    /// 试用登陆且没设置自定义账号时，取 Wifi 用户名和密码均为空
    static func getWifiPassword () -> String? {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cachePwd = CacheHelper.get("wifiAuthPwd")
        return cachePwd == "" ? getPassword() : cachePwd
    }
    
    static func clearWifiAuth () {
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