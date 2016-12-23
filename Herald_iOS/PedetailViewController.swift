//
//  CardViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import FSCalendar

class PedetailViewController : UIViewController, FSCalendarDelegate, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet weak var calendar : FSCalendar!
    
    @IBOutlet weak var countLabel : UILabel!
    
    @IBOutlet weak var remainLabel : UILabel!
    
    override func viewDidLoad() {
        calendar.delegate = self
        let cache = Cache.peDetail.value
        if cache != "" {
            loadCache()
        } else {
            refreshCache()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x26a69a)
    }
    
    var history : [Date] = []
    
    func loadCache() {
        let cache = Cache.peDetail.value
        let count = Cache.peCount.value
        let remain = Cache.peRemain.value
        countLabel.text = count
        remainLabel.text = remain
        
        // 清除所有日历事件
        calendar?.reloadData()
        
        let jsonArray = JSON.parse(cache)["content"]
        
        history.removeAll()
        
        // 遍历所有跑操记录
        for k in jsonArray.arrayValue {
            let date = k["sign_date"].stringValue
            
            let ymd = date.replaceAll("-", "/").split("/")
            let comp = GCalendar(.Minute)
            
            if ymd.count < 3 { continue }
            guard let year = Int(ymd[0]), let month = Int(ymd[1]), let day = Int(ymd[2]) else {
                continue
            }
            comp.year = year; comp.month = month; comp.day = day
            
            var time = k["sign_time"].stringValue.replaceAll(".", ":").split(":")
            
            // 由于体育系程序员是体育老师教的，他们直接把小数点分隔的时分当作小数来储存，百分位上的0会被抹去
            // 所以一位字符表示的分钟要在其后补0
            if time.count < 2 { continue }
            if time[1].characters.count < 2 {
                time[1] += "0"
            }
            guard let hour = Int(time[0]), let minute = Int(time[1]) else {
                continue
            }
            comp.hour = hour; comp.minute = minute
            
            calendar?.select(comp.getDate())
            history.append(comp.getDate())
        }
        
        if history.count == 0 {
            showMessage("本学期暂时没有跑操记录")
        }
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        PedetailCard.getRefresher().onFinish { success, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache()
            } else {
                self.showMessage("刷新失败，请重试")
            }
        }.run()
    }
    
    func showError () {
        title = "跑操助手"
        showMessage("解析失败，请刷新")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        if !history.contains(date) {
            calendar.deselect(date)
            showMessage("该日无跑操记录")
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        if history.contains(date) {
            calendar.select(date)
            for index in 0 ..< history.count {
                let k = history[index]
                if k == date {
                    let k = GCalendar(date)
                    let timeStr = String(format: "%d/%d/%d %d:%02d", k.year, k.month, k.day, k.hour, k.minute)
                    showMessage("(第 \(index + 1) 次跑操) 打卡时间：" + timeStr)
                }
            }
        }
    }
}
