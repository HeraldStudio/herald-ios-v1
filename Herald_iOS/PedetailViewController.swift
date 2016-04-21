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

class PedetailViewController : BaseViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar : FSCalendar!
    
    @IBOutlet weak var countLabel : UILabel!
    
    @IBOutlet weak var remainLabel : UILabel!
    
    override func viewDidLoad() {
        themeColor = UIColor(red: 38/255, green: 166/255, blue: 154/255, alpha: 1)
        
        let cache = CacheHelper.getCache("herald_pedetail")
        if cache != "" {
            loadCache()
        } else {
            refreshCache()
        }
    }
    
    var history : [NSDate] = []
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_pedetail")
        let count = CacheHelper.getCache("herald_pe_count")
        let remain = CacheHelper.getCache("herald_pe_remain")
        countLabel.text = count
        remainLabel.text = remain
        calendar?.reloadData()
        
        let jsonArray = JSON.parse(cache)["content"]
        
        history.removeAll()
        
        // 遍历所有跑操记录
        for k in jsonArray.arrayValue {
            guard let date = k["sign_date"].string else { showError(); return }
            
            let ymd = date.stringByReplacingOccurrencesOfString("-", withString: "/").componentsSeparatedByString("/")
            let unit = NSCalendarUnit(arrayLiteral: .Year, .Month, .Day)
            let comp = NSCalendar.currentCalendar().components(unit, fromDate: NSDate())
            
            guard let year = Int(ymd[0]) else { showError(); return }
            guard let month = Int(ymd[1]) else { showError(); return }
            guard let day = Int(ymd[2]) else { showError(); return }
            comp.year = year; comp.month = month; comp.day = day
            
            guard let historyDate = NSCalendar.currentCalendar().dateFromComponents(comp) else { showError(); return }
            calendar?.selectDate(historyDate)
            history.append(historyDate)
        }
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiThreadManager().addAll(
            ApiRequest().api("pedetail").uuid().toCache("herald_pedetail") {
                json -> String in
                    guard let str = json.rawString() else {return ""}
                    return str
                },
            ApiRequest().api("pe").uuid().toCache("herald_pe_count") {
                json -> String in
                    guard let str = json["content"].rawString() else {return ""}
                    return str
                }.toCache("herald_pe_remain") {
                    json -> String in
                    guard let str = json["remain"].rawString() else {return ""}
                    return str
                }
        ).onFinish { success in
            self.hideProgressDialog()
            if success {
                self.loadCache()
                self.showMessage("刷新成功")
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
        let unit = NSCalendarUnit(arrayLiteral: .Year, .Month, .Day)
        let comp = NSCalendar.currentCalendar().components(unit, fromDate: date)
        guard let sharpDate = NSCalendar.currentCalendar().dateFromComponents(comp) else { return false }
        for k in history {
            if k.compare(sharpDate) == NSComparisonResult.OrderedSame { return true }
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