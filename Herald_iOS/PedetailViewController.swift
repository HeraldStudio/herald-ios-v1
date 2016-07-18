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

class PedetailViewController : UIViewController, FSCalendarDelegate {
    
    @IBOutlet weak var calendar : FSCalendar!
    
    @IBOutlet weak var countLabel : UILabel!
    
    @IBOutlet weak var remainLabel : UILabel!
    
    override func viewDidLoad() {
        calendar.delegate = self
        let cache = CacheHelper.get("herald_pedetail")
        if cache != "" {
            loadCache()
        } else {
            refreshCache()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x26a69a)
    }
    
    var history : [NSDate] = []
    
    func loadCache() {
        let cache = CacheHelper.get("herald_pedetail")
        let count = CacheHelper.get("herald_pe_count")
        let remain = CacheHelper.get("herald_pe_remain")
        countLabel.text = count
        remainLabel.text = remain
        calendar?.reloadData()
        
        let jsonArray = JSON.parse(cache)["content"]
        
        history.removeAll()
        
        // 遍历所有跑操记录
        for k in jsonArray.arrayValue {
            let date = k["sign_date"].stringValue
            
            let ymd = date.replaceAll("-", "/").split("/")
            let comp = GCalendar(.Day)
            
            guard let year = Int(ymd[0]) else { showError(); return }
            guard let month = Int(ymd[1]) else { showError(); return }
            guard let day = Int(ymd[2]) else { showError(); return }
            comp.year = year; comp.month = month; comp.day = day
            
            calendar?.selectDate(comp.getDate())
            history.append(comp.getDate())
        }
        
        if history.count == 0 {
            showMessage("本学期暂时没有跑操记录")
        }
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        PedetailCard.getRefresher().onFinish { success in
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
    
    func hasDate(date : NSDate) -> Bool {
        for k in history {
            if k.timeIntervalSince1970 == date.timeIntervalSince1970 { return true }
        }
        return false
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        if !hasDate(date) { calendar.deselectDate(date) }
    }
    
    func calendar(calendar: FSCalendar, didDeselectDate date: NSDate) {
        if hasDate(date) { calendar.selectDate(date) }
    }
}