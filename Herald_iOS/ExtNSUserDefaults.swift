import Foundation

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