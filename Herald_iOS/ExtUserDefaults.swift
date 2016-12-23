import SwiftyJSON

/**
 * PrefixUserDefaults | 前缀用户偏好
 * 实现用前缀区分几套不同类别的用户偏好，并简化用户偏好的设置和获取操作
 */
extension UserDefaults {
    
    /// 从 UserDefaults 初始化一个 PrefixUserDefaults
    static func withPrefix (_ prefix : String) -> PrefixUserDefaults {
        let defaults = UserDefaults(suiteName: "group.herald-ext")!
        return PrefixUserDefaults(defaults: defaults, prefix: prefix)
    }
}

class PrefixUserDefaults {
    
    /// 被封装的 UserDefaults
    var defaults : UserDefaults
    
    /// 所用的前缀
    var prefix : String
    
    /// 构造函数
    init (defaults : UserDefaults, prefix : String) {
        self.defaults = defaults
        self.prefix = prefix
    }
    
    /// 获取对应键值的用户偏好
    func get (_ key : String) -> String {
        if let k = defaults.string(forKey: prefix + key) {
            return k
        }
        return ""
    }
    
    /// 设置对应键值的用户偏好
    func set (_ key : String, _ value : String) {
        defaults.set(value, forKey: prefix + key)
        defaults.synchronize()
    }
}
