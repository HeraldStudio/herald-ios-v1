//
//  SeuNetViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import MagicPie

class SeuNetViewController : UIViewController {
    
    @IBOutlet var usage : UILabel!
    
    @IBOutlet var left : UILabel!
    
    @IBOutlet var state : UILabel!
    
    @IBOutlet var container : UIView!
    
    var used : Float = 0.0
    
    var remain : Float = 10.0
    
    let usedColor = UIColor(red: 255/255, green: 139/255, blue: 0/255, alpha:1)
    
    let leftColor = UIColor(red: 156/255, green: 220/255, blue: 27/255, alpha:1)
    
    override func viewDidLoad() {
        loadCache(false)
    }
    
    // 把这个操作延迟到视图加载完成后，否则饼图会错位
    override func viewDidAppear(animated: Bool) {
        loadPie()
    }
    
    func loadCache (showPie : Bool) {
        let cache = CacheHelper.get("herald_nic")
        if cache == "" {
            refreshCache()
            return
        }
        
        var usageStr = JSON.parse(cache)["content"]["web"]["used"].stringValue
        var stateStr = JSON.parse(cache)["content"]["web"]["state"].stringValue
        var leftStr = JSON.parse(cache)["content"]["left"].stringValue
        
        usageStr = usageStr.componentsSeparatedByString(" ")[0]
        stateStr = "当前状态：" + stateStr.stringByReplacingOccurrencesOfString(",", withString: "，")
        leftStr = leftStr.componentsSeparatedByString(" ")[0]
        
        usage.text = usageStr
        state.text = stateStr
        left.text = leftStr
        
        guard let used = Float(usageStr) else { showError(); return }
        self.used = used
        var total : Float = 10
        while used > total {
            total += 10
        }
        remain = total - used
        
        if showPie {
            loadPie()
        }
    }
    
    func loadPie () {
        if container.layer.sublayers != nil {
            for k in container.layer.sublayers! {
                k.removeFromSuperlayer()
            }
        }
        let pie = PieLayer()
        pie.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        container.layer.addSublayer(pie)
        
        let usedElem = PieElement(value: used, color: usedColor)
        let remainElem = PieElement(value: remain, color: leftColor)
        usedElem.showTitle = true
        remainElem.showTitle = true
        
        pie.addValues([usedElem, remainElem], animated: true)
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("nic").uuid()
            .toCache("herald_nic") {json -> String in
                guard let str = json.rawString() else {return ""}
                return str
        }.onFinish { success, _, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache(true)
            } else {
                self.showMessage("刷新失败，请重试")
            }
        }.run()
    }
    
    func showError() {
        showMessage("解析失败，请刷新")
    }
}