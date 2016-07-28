import Foundation

class CacheHelper {
    
    /// 本 Helper 的缓存已经改成随用户变化，退出登录时不再需要清空
    static var cache : PrefixUserDefaults {
        return NSUserDefaults.withPrefix("cache_\(ApiHelper.currentUser.userName)_")
    }
    
    static func get(cacheName : String) -> String {
        return cache.get(cacheName)
    }
    
    /// 返回值为该缓存与之前相比是否有变化
    static func set(cacheName : String, _ cacheValue : String) -> Bool {
        let oldValue = cache.get(cacheName)
        cache.set(cacheName, cacheValue)
        
        // 此处首先判断旧值是否为空，若旧值为空说明是初次更新
        // 因为初次更新无法判断实际数据是否发生了变化，同时也是为了为了首次启动时不干扰用户，所以初次更新时不显示小红点
        return oldValue != "" && cacheValue != oldValue
    }
}