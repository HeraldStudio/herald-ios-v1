//
//  ViewController.swift
//  curriculum
//
//  Created by 于海通 on 16/2/24.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import UIKit
import SwiftyJSON

class CurriculumViewController : UIViewController, UIScrollViewDelegate {
    
    var thisWeek = 0
    
    @IBOutlet var scrollView : UIScrollView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        let top = (navigationController?.navigationBar.bounds.height)! + UIApplication.sharedApplication().statusBarFrame.height
        scrollView?.frame = CGRect(x: 0, y: top, width: view.bounds.width, height: view.bounds.height - top)
        readLocal()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(swiper, 0x00abd4)
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiThreadManager().addAll([
            ApiRequest().api("sidebar").uuid().toCache("herald_sidebar") {
                    json in json["content"]
                },
                ApiRequest().api("curriculum").uuid().toCache("herald_curriculum") {
                    json in json["content"]
                }
            ]).onFinish { success in
                self.hideProgressDialog()
                if success {
                    self.readLocal()
                } else {
                    self.showMessage("刷新失败")
                }
        }.run()
    }
    
    func readLocal () {
        let data = CacheHelper.get("herald_curriculum")
        let sidebar = CacheHelper.get("herald_sidebar")
        if data == "" {
            refreshCache()
            return
        }
        
        var maxWeek = 0
        
        // 读取json内容
        let content = JSON.parse(data)
        
        // 计算总周数
        for weekNum in CurriculumView.WEEK_NUMS {
            let arr = content[weekNum]
            for i in 0 ..< arr.count {
                do {
                    let info = try ClassInfo(json: arr[i])
                    if info.endWeek > maxWeek {
                        maxWeek = info.endWeek
                    }
                } catch {}
            }
        }
        
        // 如果没课，什么也不做
        if maxWeek < 1 {
            showMessage("暂无课程")
            return
        }
        
        var sidebarList : [String:String] = [:]
        
        // 将课程的授课教师和学分信息放入键值对
        let sidebarArray = JSON.parse(sidebar)
        for i in 0 ..< sidebarArray.count {
            let obj = sidebarArray[i]
            let lecturer = obj["lecturer"].stringValue
            let credit = obj["credit"].stringValue
            let course = obj["course"].stringValue
            sidebarList.updateValue("授课教师：\(lecturer)\n课程学分：\(credit)", forKey: course)
        }
        
        // 读取开学日期
        let startMonth = content["startdate"]["month"].intValue
        let startDate = content["startdate"]["day"].intValue
        let cal = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        let beginOfTerm = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        
        // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
        beginOfTerm.month = startMonth + 1
        beginOfTerm.day = startDate
        
        // 如果开学日期比今天还晚，则是去年开学的。这里用while保证了thisWeek永远大于零
        let now = NSCalendar.currentCalendar().dateFromComponents(cal)!
        var begin = NSCalendar.currentCalendar().dateFromComponents(beginOfTerm)!
        while (now.compare(begin) == NSComparisonResult.OrderedAscending) {
            beginOfTerm.year -= 1
            begin = NSCalendar.currentCalendar().dateFromComponents(beginOfTerm)!
        }
        
        // 为了保险，检查开学日期的星期，不是周一的话往前推到周一
        let k = (NSCalendar.currentCalendar().components([.Weekday], fromDate: begin).weekday + 5) % 7
        
        // 将开学日期往前推到周一
        begin = begin.dateByAddingTimeInterval(Double(-k * 86400))
        
        // 计算当前周
        thisWeek = Int(now.timeIntervalSinceDate(begin)) / 86400 / 7 + 1
        
        // 实例化各页
        removeAllPages()
        updateContentSize(maxWeek)
        
        for i in 1 ... maxWeek {
            let page = CurriculumView()
            page.data(content, sidebar: sidebarList, week: i, curWeek: i == thisWeek)
            page.view.frame = CGRect(x: CGFloat(i - 1) * (scrollView?.frame.width)!, y: 0, width: (scrollView?.frame.width)!, height: (scrollView?.frame.height)!)
            scrollView?.addSubview(page.view)
            page.loadData()
        }
        
        scrollView?.scrollRectToVisible((scrollView?.subviews[thisWeek - 1].frame)!, animated: true)
        let page = abs(Int(scrollView!.contentOffset.x / scrollView!.frame.width))
        title = "第 \(page + 1) 周"
        
        scrollView?.addSubview(swiper)
    }
    
    func showError () {
        title = "课表助手"
        showMessage("解析失败，请刷新")
    }
    
    func removeAllPages () {
        for k in scrollView!.subviews {
            k.removeFromSuperview()
        }
    }
    
    func updateContentSize (pages : Int) {
        scrollView?.contentSize = CGSize(width: CGFloat(pages) * (scrollView?.frame.width)!, height: (scrollView?.frame.height)!)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // 如果没课，什么也不做
        if scrollView.contentSize.width == 0 { return }
        let page = abs(Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5))
        title = "第 \(page + 1) 周"
        swiper.syncApperance()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
}