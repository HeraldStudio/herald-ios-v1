import SwiftyJSON

/**
 * PrefixUserDefaults | 前缀用户偏好
 * 实现用前缀区分几套不同类别的用户偏好，并简化用户偏好的设置和获取操作
 */
extension NSUserDefaults {
    
    /// 从 NSUserDefaults 初始化一个 PrefixUserDefaults
    static func withPrefix (prefix : String) -> PrefixUserDefaults {
        return PrefixUserDefaults(defaults: standardUserDefaults(), prefix: prefix)
    }
}

class PrefixUserDefaults {
    
    /// 被封装的 NSUserDefaults
    var defaults : NSUserDefaults
    
    /// 所用的前缀
    var prefix : String
    
    /// 构造函数
    init (defaults : NSUserDefaults, prefix : String) {
        self.defaults = defaults
        self.prefix = prefix
    }
    
    /// 获取对应键值的用户偏好
    func get (key : String) -> String {
        
        // 试用环境下的缓存覆盖
        if ApiHelper.isTrial() {
            if TrialCache.keys.contains(key) {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(TrialCache[key]!, options: NSJSONWritingOptions.PrettyPrinted)
                    let strJson = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print(strJson)
                    return "\(strJson!)"
                } catch {
                    // 解析出错，按照正常方式返回，不再覆盖缓存
                    // 也是一万年不会出现一次的意外
                }
            }
        }
        
        if let k = defaults.stringForKey(prefix + key) {
            return k
        }
        return ""
    }
    
    /// 设置对应键值的用户偏好
    func set (key : String, _ value : String) {
        defaults.setObject(value, forKey: prefix + key)
        defaults.synchronize()
    }
}