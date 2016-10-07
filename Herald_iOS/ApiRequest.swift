import Alamofire
import SwiftyJSON

/**
 * ApiRequest | 通用联网请求接口
 *
 * 设计要求：
 *  以 SimpleApiRequest(简单请求) 为单元，通过 chain(顺次执行) 和 parallel(同时执行) 两种
 *  运算，可以得到满足不同需求的复合请求，而复合请求又可以作为新的单元，形成更大的复合请求。
 *
 * 大坑提醒：
 *  请务必注意 ** 类都是引用类型 **，因此请不要在多处使用同一个已经定义的 ApiRequest。
 *  如果在多处使用同一个 ApiRequest 的引用，其中任意一处执行的 onResponse()，onFinish()，
 *  toCache() 等将会影响到其它位置持有的 ApiRequest 引用的运行结果。
 *  如果要定义一个需要在多处使用的 ApiRequest，请用一个返回 ApiRequest 的闭包代替。
 **/

/// 合并两个错误码，即去掉其中错误轻的，保留错误严重的代码
/// 具体逻辑是以401为最严重，其它错误数字越大越严重
func mergeStatusCodes (leftCode : Int, _ rightCode : Int) -> Int {
    if leftCode == 401 || rightCode == 401 {
        return 401
    }
    return max(leftCode, rightCode)
}

/// 闭包类型，表示当前请求中各个简单请求结束的事件。
/// 若当前请求就是简单请求，则只触发一次，相当于请求结束的事件；
/// 若当前请求是复合请求，其中包含的每个简单请求结束时都会触发一次
typealias OnResponseListener = (Bool, Int, String) -> Void

/// 闭包类型，表示整个请求结束的事件。
/// 由于请求结束的事件可能是简单请求结束，也可能是复合请求结束，
/// 而复合请求作为一个整体，本身没有 code 和 response 值，
/// 这里定义：** 一个复合请求中所有简单请求返回的 code 的最大值，作为这个复合请求的 code。**
/// 所以这个 listener 有两个参数。
/// 如要监听简单请求结束的事件，可使用OnResponseListener
typealias OnFinishListener = (Bool, Int) -> Void

/// 用来在将要运行的请求中优先加入 401 错误的监听器
/// 所有复合请求的 run() 函数必须首先调用本函数
/// 当请求出现致命错误时，提示身份过期并退出登录
func addFatalErrorListenerInOnFinishList(inout list: [OnFinishListener]) {
    let listener : OnFinishListener = { _, code in
        if code == 401 {
            ApiHelper.notifyUserIdentityExpired()
        }
    }
    list = [listener] + list
}

/// 用来在将要运行的请求中优先加入 401 错误的监听器
/// 所有简单请求的 run() 函数必须首先调用本函数
/// 当请求出现致命错误时，提示身份过期并退出登录
func addFatalErrorListenerInOnResponseList(inout list: [OnResponseListener]) {
    let listener : OnResponseListener = { _, code, _ in
        if code == 401 {
            ApiHelper.notifyUserIdentityExpired()
        }
    }
    list = [listener] + list
}

/// 协议，空请求、简单请求、顺次复合请求、同时复合请求都要遵守该协议，以保证这种递归式的多态性
protocol ApiRequest {

    func onResponse(listener : OnResponseListener) -> ApiRequest

    func onFinish(listener : OnFinishListener) -> ApiRequest

    /// 不添加 4xx 错误监听器，直接运行。
    /// 该函数用于外层复合请求调用内层请求时使用，防止 4xx 错误监听器重复添加。
    /// 在需要忽略 4xx 错误的情况下，此函数也可以从外部调用。
    func runWithoutFatalListener()

    /// 添加 4xx 错误监听器并运行。
    func run()
}

/// 用-号表示顺次复合运算
func - (left: ApiRequest, right: ApiRequest) -> ApiRequest {
    return ApiChainRequest(left, right)
}

func -= (inout left: ApiRequest, right: ApiRequest) {
    left = left - right
}

/// 用|号表示同时复合运算
func | (left: ApiRequest, right: ApiRequest) -> ApiRequest {
    return ApiParallelRequest(left, right)
}

func |= (inout left: ApiRequest, right: ApiRequest) {
    left = left | right
}

/**
 * ApiEmptyRequest | 空请求
 * 请求运算中的单位元，任何请求与空请求做运算都得到其本身。
 **/
class ApiEmptyRequest : ApiRequest {

    var onResponseListeners : [OnResponseListener] = []

    func onResponse (listener : OnResponseListener) -> ApiRequest {
        onResponseListeners.append(listener)
        return self
    }

    func onFinish(listener: OnFinishListener) -> ApiRequest {
        return onResponse { success, code, response in listener(success, code) }
    }

    func runWithoutFatalListener() {
        for listener in onResponseListeners {
            listener(true, 200, "Warning: This is an empty request.")
        }
    }

    func run() {
        runWithoutFatalListener()
    }
}

/**
 * ApiSimpleRequest | 简单请求
 * 网络请求的一个基本单元，包含一次请求和一次回调。
 **/
class ApiSimpleRequest : ApiRequest {

    enum Method {
        case Post
        case Get
    }

    var method : Method

    /**
     * 构造部分
     **/
    init(_ method: Method){
        self.method = method
    }

    var url : String?

    func url (url : String) -> ApiSimpleRequest {
        self.url = url
        return self
    }

    func api (api : String) -> ApiSimpleRequest {
        return url(ApiHelper.getApiUrl(api))
    }

    var isDebug = false

    func debug () -> ApiSimpleRequest {
        isDebug = true
        return self
    }

    /**
     * 联网设置部分
     * builder  参数表
     **/
    var map : [String : AnyObject] = [:]

    func uuid () -> ApiSimpleRequest {
        map.updateValue(ApiHelper.currentUser.uuid, forKey: "uuid")
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

        // 解析错误码（这里指的是 HTTP Response Status Code，不考虑 JSON 中返回的 code）
        if let httpCode = response.response?.statusCode {

            // 取返回的字符串值
            var responseString = ""
            if let stringResponse = response.result.value {
                responseString = stringResponse
            }
            
            // 将 HTTP Response Status Code 与 JSON code 合并, 取其中较严重的一个。
            // 若返回字符串无法解析成 JSON, 按照我们的 JSON 解析库的实现, 后一个参数将为0, 仍取前一个参数作为 code
            let code = mergeStatusCodes(httpCode, JSON.parse(responseString)["code"].intValue)

            // 按照错误码判断是否成功
            let success = code < 300

            // 触发回调
            for listener in onResponseListeners {
                listener(success, code, responseString)
            }
        } else {

            // 连接失败，触发回调
            for listener in onResponseListeners {
                listener(false, 500, "Connection Error")
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
        return onResponse { success, code, response in listener(success, code) }
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
    func toCache (key : String, withParser parser : JSONParser = {json in json}) -> ApiSimpleRequest {
        onResponse {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response)).rawStringValue
                    CacheHelper.set(key, cache)
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
                    ApiHelper.set(key, cache)
                } catch {
                    for onResponseListener in self.onResponseListeners {
                        onResponseListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }

    /**
     * 执行部分
     **/
    func runWithoutFatalListener() {
        
        let request = Alamofire.request([Method.Get: .GET, Method.Post: .POST][method]!,
            url!, parameters: map, encoding: .URL)

        request.responseString { response in
            if self.isDebug {
                debugPrint(request)
                debugPrint(response)
            }
            self.callback(response)
        }
        
    }

    func run () {
        addFatalErrorListenerInOnResponseList(&onResponseListeners)
        runWithoutFatalListener()
    }
}

/**
 * ApiChainRequest | 短路顺次请求
 *
 * 利用 request1 - request2 运算可得到一个 ApiChainRequest
 * 当前一个子请求执行完毕后，判断其是否执行成功，若执行成功则启动后一个子请求，直到所有子请求结束。
 * 仅当所有子请求都执行成功，才视为 ApiChainRequest 执行成功。
 * 此请求是短路的，即左边的请求如果失败，将不会继续向右执行。
 */
class ApiChainRequest : ApiRequest {

    var leftRequest : ApiRequest

    var rightRequest : ApiRequest

    var code = 0

    init(_ left: ApiRequest, _ right: ApiRequest) {
        leftRequest = left
        rightRequest = right

        leftRequest.onFinish { success, code in

            // 首先更新复合请求的 code
            self.code = mergeStatusCodes(self.code, code)

            // 若前一个请求成功，运行下一个请求
            if success {
                self.rightRequest.runWithoutFatalListener()
            } else {
                // 否则直接报告请求结束
                for listener in self.onFinishListeners {
                    listener(self.code < 300, self.code)
                }
            }
        }

        rightRequest.onFinish { _, code in

            // 首先更新复合请求的 code
            self.code = mergeStatusCodes(self.code, code)

            // 报告请求结束
            for listener in self.onFinishListeners {
                listener(self.code < 300, self.code)
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

    func runWithoutFatalListener() {
        leftRequest.runWithoutFatalListener()
    }

    func run() {
        addFatalErrorListenerInOnFinishList(&onFinishListeners)
        runWithoutFatalListener()
    }
}

/**
 * ApiParallelRequest | 同时请求
 *
 * 利用 request1 | request2 运算可得到一个 ApiParallelRequest
 * 所有子请求同时开始执行，直到最后结束的请求结束。
 * 仅当所有子请求都执行成功，才视为 ApiParallelRequest 执行成功。
 **/
class ApiParallelRequest : ApiRequest {
    var leftRequest : ApiRequest

    var leftFinished = false

    var rightRequest : ApiRequest

    var rightFinished = false

    var code = 0

    init(_ left: ApiRequest, _ right: ApiRequest) {
        leftRequest = left
        rightRequest = right

        leftRequest.onFinish { _, code in
            self.invokeCallback(code, &self.leftFinished, &self.rightFinished)
        }

        rightRequest.onFinish { _, code in
            self.invokeCallback(code, &self.rightFinished, &self.leftFinished)
        }
    }

    func invokeCallback(code : Int, inout _ thisFinished : Bool, inout _ anotherFinished : Bool) {
        synchronized(self) {
            thisFinished = true

            // 首先更新复合请求的 code
            self.code = mergeStatusCodes(self.code, code)

            if anotherFinished {
                for listener in self.onFinishListeners {
                    listener(self.code < 300, self.code)
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

    func runWithoutFatalListener() {
        leftRequest.runWithoutFatalListener()
        rightRequest.runWithoutFatalListener()
    }

    func run() {
        addFatalErrorListenerInOnFinishList(&onFinishListeners)
        runWithoutFatalListener()
    }
}
