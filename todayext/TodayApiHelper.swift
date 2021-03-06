import UIKit
import SwiftyJSON

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
    
    static let authCache = UserDefaults.withPrefix("auth_")
    
    static func getApiUrl (_ api : String) -> String {
        return API_ROOT + api
    }
    
    /// 用户变化的监听器
    typealias UserChangedListener = () -> Void
    
    static var userChangedListeners : [UserChangedListener] = []
    
    static func addUserChangedListener (_ listener : @escaping UserChangedListener) {
        userChangedListeners.append(listener)
    }
    
    static func notifyUserChanged () {
        for function in userChangedListeners {
            function()
        }
    }
    
    static var currentUser : User {
        get {
            return User(JSON.parse(get("currentUser")))
        } set {
            ApiHelper.set("currentUser", newValue.toJson().rawStringValue)
            notifyUserChanged()
        }
    }
    
    /// 当 ApiRequest 检测到用户身份过期时，将调用此函数
    static func notifyUserIdentityExpired () {
    }
    
    static func isLogin () -> Bool {
        return currentUser != trialUser
    }
    
    static func setWifiAuth (user : String, pwd : String) {
        // TODO 加密
        set("wifiAuthUser", user)
        set("wifiAuthPwd", pwd)
    }
    
    static func getWifiUserName () -> String {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cacheUser = get("wifiAuthUser")
        return cacheUser == "" ? currentUser.userName : cacheUser
    }
    
    static func getWifiPassword () -> String {
        // 若无校园网独立用户缓存，则使用登陆应用的账户
        let cachePwd = get("wifiAuthPwd")
        return cachePwd == "" ? currentUser.password : cachePwd
    }
    
    static func isWifiLoginAvailable () -> Bool {
        return isLogin() || getWifiUserName() != trialUser.userName
    }
    
    static func clearWifiAuth () {
        setWifiAuth(user: "", pwd: "")
    }
    
    static func get (_ key : String) -> String {
        return authCache.get(key)
    }
    
    static func set (_ key : String, _ value : String) {
        authCache.set(key, value)
    }
}
