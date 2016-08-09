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

class SeuNetViewController : UIViewController, ForceTouchPreviewable, LoginUserNeeded {
    
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
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x7cb342)
    }
    
    // 把这个操作延迟到视图加载完成后，否则饼图会错位
    override func viewDidAppear(animated: Bool) {
        loadPie()
    }
    
    func loadCache (showPie : Bool) {
        if Cache.seunet.isEmpty {
            refreshCache()
            return
        }
        
        let cache = Cache.seunet.value
        var usageStr = JSON.parse(cache)["content"]["web"]["used"].stringValue
        var stateStr = JSON.parse(cache)["content"]["web"]["state"].stringValue
        var leftStr = JSON.parse(cache)["content"]["left"].stringValue
        
        let usageUnit = usageStr.split(" ").count > 1 ? usageStr.split(" ")[1] : ""
        usageStr = usageStr.split(" ")[0]
        stateStr = "当前状态：" + stateStr.replaceAll(",", "，")
        leftStr = leftStr.split(" ")[0]
        
        state.text = stateStr
        left.text = leftStr
        
        // 有些人没开通网络服务，used这里的值是"暂无流量信息"，这种不能识别为数字的要当成数字0
        let _used = Float(usageStr)
        used = _used == nil ? 0 : _used!
        if usageUnit == "KB" {
            used /= 1024 * 1024
        } else if usageUnit == "MB" {
            used /= 1024
        }
        
        var total : Float = 10
        while used > total {
            total += 10
        }
        remain = total - used
        
        usage.text = String(format: "%.2f", used)
        
        if showPie {
            loadPie()
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        loadPie()
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
        Cache.seunet.refresh { success, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache(true)
            } else {
                self.showMessage("刷新失败，请重试")
            }
        }
    }
    
    func showError() {
        showMessage("解析失败，请刷新")
    }
}