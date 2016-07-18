import Alamofire
import SwiftyJSON

/**
 * ApiRequest | 通用联网请求接口
 *
 * 设计要求：
 *  以 SimpleApiRequest(简单请求) 为单元，通过 chain(顺次执行) 和 parallel(同时执行) 两种
 *  运算，可以得到满足不同需求的复合请求，而复合请求又可以作为新的单元，形成更大的复合请求。
 **/
    
typealias OnResponseListener = (Bool, Int, String) -> Void
    
typealias OnFinishListener = (Bool) -> Void

protocol ApiRequest {
    
    func onResponse(listener : OnResponseListener) -> ApiRequest
    
    func onFinish(listener : OnFinishListener) -> ApiRequest
    
    func chain(nextRequest : ApiRequest) -> ApiRequest
    
    func parallel(anotherRequest : ApiRequest) -> ApiRequest
    
    func run()
}

func * (left: ApiRequest, right: ApiRequest) -> ApiRequest {
    return left.chain(right)
}

func + (left: ApiRequest, right: ApiRequest) -> ApiRequest {
    return left.parallel(right)
}

func *= (inout left: ApiRequest, right: ApiRequest) {
    left = left.chain(right)
}

func += (inout left: ApiRequest, right: ApiRequest) {
    left = left.parallel(right)
}

class ApiEmptyRequest : ApiRequest {
    func onResponse(listener: OnResponseListener) -> ApiRequest {
        return self
    }
    
    func onFinish(listener: OnFinishListener) -> ApiRequest {
        return self
    }
    
    func chain(nextRequest: ApiRequest) -> ApiRequest {
        return nextRequest
    }
    
    func parallel(anotherRequest: ApiRequest) -> ApiRequest {
        return anotherRequest
    }
    
    func run() {
        return
    }
}

/**
 * ApiSimpleRequest | 简单请求
 * 网络请求的一个基本单元，包含一次请求和一次回调。
 **/
class ApiSimpleRequest : ApiRequest {
    
    /**
     * 构造部分
     **/
    init(checkJson200: Bool){
        self.checkJson200 = checkJson200
    }
    
    var url : String?
    
    func url (url : String) -> ApiSimpleRequest {
        self.url = url
        return self
    }
    
    func api (api : String) -> ApiSimpleRequest {
        return url(ApiHelper.getApiUrl(api))
    }
    
    var checkJson200 : Bool
    
    var isDebug = false
    
    func debug () -> ApiSimpleRequest {
        isDebug = true
        return self
    }
    
    var isGet = false
    
    func get () -> ApiSimpleRequest {
        isGet = true
        return self
    }
    
    /**
     * 联网设置部分
     * builder  参数表
     **/
    var map : [String : AnyObject] = [:]
    
    func uuid () -> ApiSimpleRequest {
        map.updateValue(ApiHelper.getUUID(), forKey: "uuid")
        return self
    }
    
    func post (map : String...) -> ApiSimpleRequest {
        for i in 0 ..< (map.count / 2) {
            let key = map[2 * i]
            let value = map[2 * i + 1]
            self.map.updateValue(value, forKey: key)
        }
        
        return self
    }
    
    /**
     * 一级回调设置部分
     * 一级回调只是跟Alamofire框架之间的交互，并在此交互过程中为二级回调提供接口
     * 从此类外面看，不存在一级回调，只有二级回调和三级回调
     *
     * callback     默认的Callback（自动调用二级回调，若出错还会执行错误处理）
     **/
    
    func callback (response : Response <String, NSError>) -> Void {
        
        var code = 0
        let resp = response.result.value == nil ? "" : response.result.value!
        
        switch response.result {
        case .Success:
            let responseJson = JSON.parse(resp)
            code = responseJson["code"].intValue
            if !checkJson200 {
                for onResponseListener in onResponseListeners {
                    onResponseListener(true, code, resp)
                }
            } else {
                guard let jsonStr = responseJson.rawString() else { fallthrough }
                guard code == 200 else {
                    if code == 400 {
                        ApiHelper.doLogout("用户身份已过期，请重新登录")
                        break
                    } else {
                        fallthrough
                    }
                }
                
                for onResponseListener in onResponseListeners {
                    onResponseListener(true, code, jsonStr)
                }
            }
        case .Failure:
            for onResponseListener in onResponseListeners {
                onResponseListener(false, code, resp)
            }
        }
    }
    
    
    /**
     * 二级回调设置部分
     * 二级回调是对返回状态和返回数据处理方式的定义，相当于重写Callback，
     * 但这里允许多个二级回调策略进行叠加，因此比Callback更灵活
     *
     * onFinishListeners    二级回调接口，内含一个默认的回调操作，该操作仅在设置了三级回调策略时有效
     **/
    
    var onResponseListeners : [OnResponseListener] = []
    
    func onResponse (listener : OnResponseListener) -> ApiRequest {
        onResponseListeners.append(listener)
        return self
    }
    
    func onFinish(listener: OnFinishListener) -> ApiRequest {
        return onResponse { success, code, response in listener(success) }
    }
    
    /**
     * 三级回调设置部分
     * 三级回调是对一些比较典型的回调策略的包装，此处暂时只实现了将数据存入缓存这一种三级回调策略
     *
     * JSONParser   将原始数据转换为要存入缓存的目标数据的中转过程
     * toCache      将目标数据存入缓存的回调策略
     * toCache()    用于设置三级回调策略的函数
     **/
    typealias JSONParser = JSON throws -> JSON
    
    // 目前暂时只有CacheHelper有更新检测机制，如果另外两个也需要该机制，请修改对应的Helper的set函数
    func toCache (key : String, notifyModuleIfChanged module : AppModule? = nil, withParser parser : JSONParser = {json in json}) -> ApiSimpleRequest {
        onResponse {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response)).rawStringValue
                    if CacheHelper.set(key, cache) {
                        if let module = module {
                            module.hasUpdates = true
                        }
                    }
                } catch {
                    for onResponseListener in self.onResponseListeners {
                        onResponseListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }
    
    func toServiceCache (key : String, withParser parser : JSONParser = {json in json}) -> ApiSimpleRequest {
        onResponse {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response)).rawStringValue
                    ServiceHelper.set(key, cache)
                } catch {
                    for onResponseListener in self.onResponseListeners {
                        onResponseListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }
    
    func toAuthCache (key : String, withParser parser : JSONParser = {json in json}) -> ApiSimpleRequest {
        onResponse {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response)).rawStringValue
                    ApiHelper.setAuthCache(key, cache)
                } catch {
                    for onResponseListener in self.onResponseListeners {
                        onResponseListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }
    
    func chain(nextRequest: ApiRequest) -> ApiRequest {
        return ApiChainRequest(self, nextRequest)
    }
    
    func parallel(anotherRequest: ApiRequest) -> ApiRequest {
        return ApiParallelRequest(self, anotherRequest)
    }
    
    /**
     * 执行部分
     **/
    func run () {
        let request = Alamofire.request(isGet ? .GET : .POST, url!, parameters: map, encoding: .URL)
        
        request.responseString { response in
            if self.isDebug {
                debugPrint(request)
                debugPrint(response)
            }
            self.callback(response)
        }
    }
}

/**
 * ApiChainRequest | 顺次请求
 *
 * 利用 request1.chain(request2) 或 request1 * request2 运算可得到一个 ApiChainRequest
 * 当前一个子请求执行完毕后，判断其是否执行成功，若执行成功则启动后一个子请求，直到所有子请求结束。
 * 仅当所有子请求都执行成功，才视为 ApiChainRequest 执行成功。
 * 遵循短路原则，即若前面的请求执行失败，后面的请求将不会被执行。
 */
class ApiChainRequest : ApiRequest {

    var leftRequest : ApiRequest
    
    var rightRequest : ApiRequest
    
    init(_ left: ApiRequest, _ right: ApiRequest) {
        leftRequest = left
        rightRequest = right
        
        leftRequest.onFinish { success in
            if success {
                self.rightRequest.run()
            } else {
                for listener in self.onFinishListeners {
                    listener(false)
                }
            }
        }
        
        rightRequest.onFinish { success in
            for listener in self.onFinishListeners {
                listener(success)
            }
        }
    }
    
    func onResponse(listener: OnResponseListener) -> ApiRequest {
        leftRequest.onResponse(listener)
        rightRequest.onResponse(listener)
        return self
    }
    
    var onFinishListeners : [OnFinishListener] = []
    
    func onFinish(listener: OnFinishListener) -> ApiRequest {
        onFinishListeners.append(listener)
        return self
    }
    
    func chain(nextRequest: ApiRequest) -> ApiRequest {
        return ApiChainRequest(self, nextRequest)
    }
    
    func parallel(anotherRequest: ApiRequest) -> ApiRequest {
        return ApiParallelRequest(self, anotherRequest)
    }
    
    func run() {
        leftRequest.run()
    }
}
/**
 * ApiParallelRequest | 同时请求
 * 
 * 利用 request1.parallel(request2) 或 request1 + request2 运算可得到一个 ApiParallelRequest
 * 所有子请求同时开始执行，直到最后结束的请求结束。
 * 仅当所有子请求都执行成功，才视为 ApiParallelRequest 执行成功。
 **/
class ApiParallelRequest : ApiRequest {
    var leftRequest : ApiRequest
    
    var leftFinished = false
    
    var rightRequest : ApiRequest
    
    var rightFinished = false
    
    var success = true
    
    init(_ left: ApiRequest, _ right: ApiRequest) {
        leftRequest = left
        rightRequest = right
        
        leftRequest.onFinish { success in
            self.leftFinished = true
            if !success {
                self.success = false
            }
            if self.rightFinished {
                for listener in self.onFinishListeners {
                    listener(self.success)
                }
            }
        }
        
        rightRequest.onFinish { success in
            self.rightFinished = true
            if !success {
                self.success = false
            }
            if self.leftFinished {
                for listener in self.onFinishListeners {
                    listener(self.success)
                }
            }
        }
    }
    
    func onResponse(listener: OnResponseListener) -> ApiRequest {
        leftRequest.onResponse(listener)
        rightRequest.onResponse(listener)
        return self
    }
    
    var onFinishListeners : [OnFinishListener] = []
    
    func onFinish(listener: OnFinishListener) -> ApiRequest {
        onFinishListeners.append(listener)
        return self
    }
    
    func chain(nextRequest: ApiRequest) -> ApiRequest {
        return ApiChainRequest(self, nextRequest)
    }
    
    func parallel(anotherRequest: ApiRequest) -> ApiRequest {
        return ApiParallelRequest(self, anotherRequest)
    }
    
    func run() {
        leftRequest.run()
        rightRequest.run()
    }
}
