//
//  SchoolbusViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SchoolbusViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var control : UISegmentedControl!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        swiper.themeColor = navigationController?.navigationBar.backgroundColor
        tableView?.tableHeaderView = swiper
        loadCache(nowWeekend())
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance((tableView?.contentOffset)!)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    var sections : [[SchoolbusModel]] = []
    
    var titles : [String] = []
    
    func loadCache(weekend : Bool) {
        control.selectedSegmentIndex = weekend ? 1 : 0
        
        let cache = CacheHelper.getCache("herald_schoolbus")
        if cache == "" {
            refreshCache()
            return
        }
        
        let day = weekend ? "weekend" : "weekday"
        let jsonCache = JSON.parse(cache)["content"][day]
        
        sections.removeAll()
        titles.removeAll()
        for section in jsonCache {
            if section.1.count == 0 {
                continue
            }
            
            var list : [SchoolbusModel] = []
            for experiment in section.1 {
                let time = experiment.1["time"].stringValue
                let desc = experiment.1["bus"].stringValue
                let startEndStamps = time.componentsSeparatedByString("-")
                let startStamps = startEndStamps[0].componentsSeparatedByString(":")
                let endStamps = startEndStamps[1].componentsSeparatedByString(":")
                guard let startHour = Int(startStamps[0]) else { showError(); return }
                guard let startMinute = Int(startStamps[1]) else { showError(); return }
                guard let endHour = Int(endStamps[0]) else { showError(); return }
                guard let endMinute = Int(endStamps[1]) else { showError(); return }
                
                // 如果今天双休日，要显示的也是双休日，或者今天工作日，要显示的也是工作日，则判断并高亮当前的车
                if nowWeekend() == weekend {
                    let nowComp = NSCalendar.currentCalendar().components(NSCalendarUnit(arrayLiteral: .Hour, .Minute), fromDate: NSDate())
                    
                    let nowTime60 = nowComp.hour * 60 + nowComp.minute
                    let startTime60 = startHour * 60 + startMinute
                    let endTime60 = endHour * 60 + endMinute
                
                    let busNow = startTime60 <= nowTime60 && nowTime60 < endTime60
                
                    let model = SchoolbusModel(time, desc, busNow)
                    list.append(model)
                } else {
                    // 否则，要显示的跟当前情况不符，则不高亮
                    let model = SchoolbusModel(time, desc, false)
                    list.append(model)
                }
            }
            sections.append(list)
            titles.append(section.0)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("schoolbus").uuid().toCache("herald_schoolbus") {
            json -> String in
            guard let str = json.rawString() else {return ""}
            return str
            }
            .onFinish { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.loadCache(self.nowWeekend())
                } else {
                    self.showMessage("刷新失败，请重试")
                }
            }.run()
    }
    
    func showError () {
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SchoolbusTableViewCell", forIndexPath: indexPath) as! SchoolbusTableViewCell
        
        let model = sections[indexPath.section][indexPath.row]
        cell.time.text = model.time
        cell.desc.text = model.desc
        cell.nowIndicator.alpha = model.now ? 1 : 0
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func nowWeekend () -> Bool {
        let nowComp = NSCalendar.currentCalendar().components(NSCalendarUnit(arrayLiteral: .Weekday), fromDate: NSDate())
        
        let dayOfWeek = (nowComp.weekday + 5) % 7
        
        return dayOfWeek >= 5
    }
    
    @IBAction func switchWeekdayAndWeekend () {
        let weekend = control.selectedSegmentIndex == 1
        loadCache(weekend)
    }
}