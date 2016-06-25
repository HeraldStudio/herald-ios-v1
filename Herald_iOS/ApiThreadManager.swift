import Foundation

class ApiThreadManager {
    
    var requests : [ApiRequest] = []
    
    var isRequestFinished : [Bool] = []
    
    typealias Runnable = () -> Void
    
    var onResponse : (Bool, Int, String) -> Void = { _,_,_ in }
    
    var onFinish : (Bool) -> Void = { _ in }
    
    var errorPool = NSMutableArray()
    
    var isDebug = false
    
    func debug () -> ApiThreadManager {
        isDebug = true
        return self
    }
    
    func add (request : ApiRequest) -> ApiThreadManager {
        // 吃掉该线程的消息显示
        request.errorPool(errorPool)
        // 在数组中加入代表该线程的bool
        let i = isRequestFinished.count
        isRequestFinished.append(false)
        // 在线程列表中加入该线程
        requests.append(request)
        // Debug设置
        if isDebug {
            request.debug()
        }
        // 设置该线程结束时执行的操作
        request.onFinish { success, code, response in
            // 在数组中标记该线程已结束
            self.isRequestFinished[i] = true
            // 执行单个线程结束时的指定操作
            self.onResponse(success, code, response)
            // 如果所有线程都结束了，执行所有线程结束时的指定操作
            for k in self.isRequestFinished {
                if !k { return }
            }
            self.onFinish(self.errorPool.count == 0)
        }
        return self
    }
    
    func addAll (newRequests : [ApiRequest]) -> ApiThreadManager {
        for request in newRequests {
            add(request)
        }
        return self
    }
    
    func onResponse (handler : (Bool, Int, String) -> Void) -> ApiThreadManager {
        self.onResponse = handler
        return self
    }
    
    func onFinish (handler : (Bool) -> Void) -> ApiThreadManager {
        self.onFinish = handler
        return self
    }
    
    func run () {
        for k in requests {
            k.run()
        }
    }
}