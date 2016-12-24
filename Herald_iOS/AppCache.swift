import Foundation

class AppCache {

    /// 缓存键名
    let key : String

    /// 取值或设值
    var value : String {
        get {
            if let mask = mask {
                return mask(CacheHelper.get(key))
            }
            return CacheHelper.get(key)
        } set {
            CacheHelper.set(key, newValue)
        }
    }
    
    /// 取值时的可选变换
    var mask : ((String) -> String)?

    /// 由于同一个 ApiRequest 实例不能多次使用，所以需要存储一个能动态创建新 ApiRequest 实例的闭包
    let refresherCreator : () -> ApiRequest

    /// 每次取 refresher 变量时，按照当前 cache 的要求动态创建一个 ApiRequest 并返回
    var refresher : ApiRequest {
        return refresherCreator()
    }
    
    /// 缓存是否为空
    var isEmpty : Bool {
        return value == ""
    }

    /// 构造函数
    init (_ key : String, refresher : @escaping () -> ApiRequest = { () in ApiEmptyRequest() }) {
        self.key = key
        self.refresherCreator = refresher
    }

    /// 刷新函数，可以直接无参数调用或者拖一个 OnFinishListener，即 { success, code in ... }
    func refresh(_ onFinishListener : OnFinishListener? = nil) {
        if let onFinishListener = onFinishListener {
            refresher.onFinish(onFinishListener).run()
        } else {
            refresher.run()
        }
    }

    /// 刷新函数，当缓存为空时刷新
    func refreshIfEmpty(_ onFinishListener : OnFinishListener? = nil) {
        if isEmpty {
            refresh(onFinishListener)
        }
    }

    /// 设为空
    func setEmpty() {
        value = ""
    }
    
    /// 设置取值变换
    func masked(mask : ((String) -> String)?) -> AppCache {
        self.mask = mask
        return self
    }
}
