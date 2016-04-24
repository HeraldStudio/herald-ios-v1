//
//  ExamViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//


import Foundation
import UIKit
import SwiftyJSON

class ExamViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        swiper.themeColor = navigationController?.navigationBar.backgroundColor
        tableView?.tableHeaderView = swiper
        loadCache()
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
    
    var sections : [[ExamModel]] = []
    var titles : [String] = []
    var endedExams : [ExamModel] = []
    var comingExams : [ExamModel] = []
    
    func loadCache() {
        let cache = CacheHelper.get("herald_exam")
        if cache == "" {
            refreshCache()
            return
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        
        sections.removeAll()
        titles.removeAll()
        endedExams.removeAll()
        comingExams.removeAll()
        
        for item in jsonCache {
            let course = item.1["course"].stringValue
            let time = item.1["time"].stringValue
            let location = item.1["location"].stringValue
            let hour = item.1["hour"].stringValue
            let teacher = item.1["teacher"].stringValue
            
            let ymd = time.componentsSeparatedByString(" ")[0].componentsSeparatedByString("-")
            let comp = NSCalendar.currentCalendar()
                .components(NSCalendarUnit(arrayLiteral: .Year, .Month, .Day), fromDate: NSDate())
            
            guard let fromDate = NSCalendar.currentCalendar().dateFromComponents(comp) else {showError(); return}
            
            guard let year = Int(ymd[0]) else {showError(); return}
            guard let month = Int(ymd[1]) else {showError(); return}
            guard let day = Int(ymd[2]) else {showError(); return}
            
            comp.year = year
            comp.month = month
            comp.day = day
            
            guard let toDate = NSCalendar.currentCalendar().dateFromComponents(comp) else {showError(); return}

            let interval = Int(toDate.timeIntervalSinceDate(fromDate) / 86400)
            
            let model = ExamModel(course, time, "地点：\(location) 时长：\(hour)分钟 教师：\(teacher)"
, interval)
            if interval >= 0 {
                comingExams.append(model)
            } else {
                endedExams.append(model)
            }
        }
        
        titles.append("考试倒计时")
        sections.append(comingExams)
        titles.append("已结束的考试")
        sections.append(endedExams)
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("exam").uuid()
            .toCache("herald_exam") {json -> String in
                guard let str = json.rawString() else {return ""}
                return str
            }
            .onFinish { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.loadCache()
                } else {
                    self.showMessage("刷新失败，请重试")
                }
            }.run()
    }
    
    func showError () {
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 考试倒计时页面如果为空，加一个提示；已结束的考试为空则不加提示
        if section == 0 && sections[section].count == 0 {
            return 1
        }
        return sections[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 考试倒计时页面如果为空，加一个提示；已结束的考试为空则不加提示
        if section == 1 && sections[section].count == 0 { return nil }
        return titles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if sections[indexPath.section].count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("ExamEmptyTableViewCell", forIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ExamTableViewCell", forIndexPath: indexPath) as! ExamTableViewCell
        
        let model = sections[indexPath.section][indexPath.row]
        cell.course?.text = model.course
        cell.time?.text = "考试时间：" + model.timeAndPlace
        cell.location?.text = model.periodAndTeacher
        cell.days?.text = String(abs(model.days))
        cell.days?.alpha = model.days >= 0 ? 1 : 0
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}