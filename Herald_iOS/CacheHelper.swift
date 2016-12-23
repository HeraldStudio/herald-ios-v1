import Foundation

class CacheHelper {
    
    /// 本 Helper 的缓存已经改成随用户变化，退出登录时不再需要清空
    static var cache : PrefixUserDefaults {
        return UserDefaults.withPrefix("cache_\(ApiHelper.currentUser.userName)_")
    }
    
    static func get(_ cacheName : String) -> String {
        return cache.get(cacheName)
    }
    
    /// 返回值为该缓存与之前相比是否有变化
    static func set(_ cacheName : String, _ cacheValue : String) {
        cache.set(cacheName, cacheValue)
    }
}
