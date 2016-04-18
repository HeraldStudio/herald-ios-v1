//
//  ApiThreadManager.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/11.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class ApiThreadManager {
    
    var requests : [ApiRequest] = []
    
    var isRequestFinished : [Bool] = []
    
    typealias Runnable = () -> Void
    
    var onResponse : Runnable = { }
    
    var onFinish : Runnable = { }
    
    var errorPool = NSMutableArray()
    
    func add (request : ApiRequest) -> ApiThreadManager {
        // 吃掉该线程的消息显示
        request.errorPool(errorPool)
        // 在数组中加入代表该线程的bool
        let i = isRequestFinished.count
        isRequestFinished.append(false)
        // 在线程列表中加入该线程
        requests.append(request)
        // 设置该线程结束时执行的操作
        request.onFinish { _, _, _ in
            // 在数组中标记该线程已结束
            self.isRequestFinished[i] = true
            // 执行单个线程结束时的指定操作
            self.onResponse()
            // 如果所有线程都结束了，执行所有线程结束时的指定操作
            for k in self.isRequestFinished {
                if !k { return }
                self.onFinish()
            }
        }
        return self
    }
    
    func addAll (newRequests : ApiRequest...) -> ApiThreadManager {
        for request in newRequests {
            add(request)
        }
        return self
    }
    
    func onResponse (runnable : () -> Void) {
        self.onResponse = runnable
    }
    
    func onFinish (runnable : () -> Void) {
        self.onFinish = runnable
    }
    
    func flushExceptions (message : String) {
        // TODO
    }
}