import UIKit

class ApiHelper : NSObject {
    // heraldstudio.com 主站API
    static let WWW_ROOT = "http://www.heraldstudio.com/"
    static let API_ROOT = WWW_ROOT + "api/"
    
    static let auth_url = WWW_ROOT + "uc/auth"
    static let auth_update_url = WWW_ROOT + "uc/update"
    static let wechat_lecture_notice_url = WWW_ROOT + "wechat2/lecture"
    static let feedback_url = WWW_ROOT + "service/feedback"
    
    static let appid = "9f9ce5c3605178daadc2d85ce9f8e064"
    
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
        
        // 清除通知
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // 清除模块缓存
        // 注意此处的clearAllmoduleCache里的authUser和authPwd与上面清除的是不同的
        CacheHelper.clearAllModuleCache()
        
        ((UIApplication.sharedApplication().delegate) as! AppDelegate).showLogin()
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
        CacheHelper.set("authUser", user)
        CacheHelper.set("authPwd", pwd)
    }
    
    static func getUserName () -> String {
        return CacheHelper.get("authUser")
    }
    
    static func getPassword () -> String {
        return CacheHelper.get("authPwd")
    }
    
    static func setWifiAuth (user user : String, pwd : String) {
        // TODO 加密
        CacheHelper.set("wifiAuthUser", user)
        CacheHelper.set("wifiAuthPwd", pwd)
    }
    
    static func getWifiUserName () -> String {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cacheUser = CacheHelper.get("wifiAuthUser")
        return cacheUser == "" ? getUserName() : cacheUser
    }
    
    static func getWifiPassword () -> String {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cachePwd = CacheHelper.get("wifiAuthPwd")
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