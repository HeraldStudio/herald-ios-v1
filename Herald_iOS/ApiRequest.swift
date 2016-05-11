//
//  ApiRequest.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiRequest {
    
    static let CONN_TIMEOUT = 10000, READ_TIMEOUT = 10000
    
    /**
     * 构造部分
     * context  当前上下文
     * exceptionPool   是否吞掉错误消息
     * url      请求的目标url
     **/
    var errorPool : NSMutableArray?
    
    var url : String?

    func errorPool (pool : NSMutableArray) -> ApiRequest {
        errorPool = pool
        return self
    }
    
    func url (url : String) -> ApiRequest {
        self.url = url
        return self
    }
    
    func api (api : String) -> ApiRequest {
        return url(ApiHelper.getApiUrl(api))
    }
    
    var dontCheck200 = false
    
    func noCheck200 () -> ApiRequest {
        dontCheck200 = true
        return self
    }
    
    var isGet = false
    
    func get () -> ApiRequest {
        isGet = true
        return self
    }
    
    /**
     * 联网设置部分
     * builder  参数表
     **/
    var map : [String : AnyObject] = [:]
    
    func uuid () -> ApiRequest {
        map.updateValue(ApiHelper.getUUID(), forKey: "uuid")
        return self
    }
    
    func post (map : String...) -> ApiRequest {
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
            if dontCheck200 {
                for onFinishListener in onFinishListeners {
                    onFinishListener(true, code, resp)
                }
            } else {
                guard let jsonStr = responseJson.rawString() else { fallthrough }
                guard code == 200 else { fallthrough }
                
                for onFinishListener in onFinishListeners {
                    onFinishListener(true, code, jsonStr)
                }
            }
        case .Failure:
            errorPool?.addObject(NSObject())
            
            for onFinishListener in onFinishListeners {
                onFinishListener(false, code, resp)
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
    typealias OnFinishListener = (Bool, Int, String) -> Void
    
    var onFinishListeners : [(Bool, Int, String) -> Void] = []
    
    func onFinish (listener : OnFinishListener) -> ApiRequest {
        onFinishListeners.append(listener)
        return self
    }
    
    /**
     * 三级回调设置部分
     * 三级回调是对一些比较典型的回调策略的包装，此处暂时只实现了将数据存入缓存这一种三级回调策略
     *
     * JSONParser   将原始数据转换为要存入缓存的目标数据的中转过程
     * toCache      将目标数据存入缓存的回调策略
     * toCache()    用于设置三级回调策略的函数
     **/
    typealias JSONParser = JSON throws -> String
    
    func toCache (key : String, withParser parser : JSONParser) -> ApiRequest {
        onFinish {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response))
                    CacheHelper.set(key, cache)
                } catch {
                    for k in self.onFinishListeners {
                        let onFinishListener = k
                        onFinishListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }
    
    func toServiceCache (key : String, withParser parser : JSONParser) -> ApiRequest {
        onFinish {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response))
                    ServiceHelper.set(key, cache)
                } catch {
                    for onFinishListener in self.onFinishListeners {
                        onFinishListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }
    
    func toAuthCache (key : String, withParser parser : JSONParser) -> ApiRequest {
        onFinish {
            success, _, response in
            if(success) {
                do {
                    let cache = try parser(JSON.parse(response))
                    ApiHelper.setAuthCache(key, cache)
                } catch {
                    for onFinishListener in self.onFinishListeners {
                        onFinishListener(false, 0, "")
                    }
                }
            }
        }
        return self
    }
    
    /**
     * 执行部分
     **/
    func run () {
        let request = Alamofire.request(isGet ? .GET : .POST, url!, parameters: map, encoding: .URL)
        request.responseString(completionHandler: callback)
    }
}