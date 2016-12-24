//
//  ViewController.swift
//  curriculum
//
//  Created by 于海通 on 16/2/24.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import UIKit
import SwiftyJSON

class CurriculumViewController : UIViewController, UIScrollViewDelegate, LoginUserNeeded {
    
    var overviewMode : Bool {
        return segmentedControl.selectedSegmentIndex != 0
    }
    
    var thisWeek = 0
    
    @IBOutlet var scrollView : UIScrollView!
    
    @IBOutlet var segmentedControl : UISegmentedControl!
    
    override var title: String? {
        didSet {
            segmentedControl.setTitle(title, forSegmentAt: 0)
        }
    }
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        let top = (navigationController?.navigationBar.bounds.height)! + UIApplication.shared.statusBarFrame.height
        scrollView?.frame = CGRect(x: 0, y: top, width: AppDelegate.instance.rightController!.view.bounds.width, height: view.bounds.height - top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x00abd4)
        swiper.bgColor = navigationController?.navigationBar.barTintColor
        readLocal()
    }
    
    /// 当屏幕旋转时重新布局（平板用）
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        readLocal()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        (Cache.curriculumSidebar.refresher | Cache.curriculum.refresher).onFinish { success, _ in
            self.hideProgressDialog()
            if success {
                self.readLocal()
            } else {
                self.showMessage("刷新失败")
            }
        }.run()
    }
    
    @IBAction func readLocal () {
        let data = Cache.curriculum.value
        let sidebar = Cache.curriculumSidebar.value
        
        if data == "" {
            refreshCache()
            return
        }
            
        // 读取json内容
        let content = JSON.parse(data)
        
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
        
        // 概览模式
        if overviewMode {
            removeAllPages()
            updateContentSize(1)
            
            let page = CurriculumOverviewView()
            page.data(obj: content, sidebar: sidebarList)
            page.view.frame = CGRect(x: 0, y: 0, width: (scrollView?.frame.width)!, height: (scrollView?.frame.height)!)
            scrollView?.addSubview(page.view)
            page.loadData()
            
            scrollView?.addSubview(swiper)
            title = "按周"
        } else {
            var maxWeek = 0
            
            // 计算总周数
            for weekNum in CurriculumView.WEEK_NUMS {
                let arr = content[weekNum]
                for i in 0 ..< arr.count {
                    do {
                        let info = try ClassModel(json: arr[i])
                        if info.endWeek > maxWeek {
                            maxWeek = info.endWeek
                        }
                    } catch {}
                }
            }
            
            // 如果没课，什么也不做
            if maxWeek < 1 {
                removeAllPages()
                showMessage("暂无固定课程")
                return
            }
            
            // 读取开学日期
            let startMonth = content["startdate"]["month"].intValue
            let startDate = content["startdate"]["day"].intValue
            let today = GCalendar(.Day)
            let beginOfTerm = GCalendar(.Day)
            
            // 服务器端返回的startMonth是Java/JavaScript型的月份表示，变成实际月份要加1
            beginOfTerm.month = startMonth + 1
            beginOfTerm.day = startDate
            
            // 如果开学日期比今天晚了超过两个月，则认为是去年开学的。这里用while保证了thisWeek永远大于零
            while (beginOfTerm - today > 60 * 86400) {
                beginOfTerm.year -= 1
            }
            
            // 为了保险，检查开学日期的星期，不是周一的话往前推到周一
            let k = beginOfTerm.dayOfWeekFromMonday.rawValue
            
            // 将开学日期往前推到周一
            beginOfTerm -= k * 86400
            
            // 计算当前周
            thisWeek = (today - beginOfTerm) / 86400 / 7 + 1
            
            // 实例化各页
            removeAllPages()
            updateContentSize(maxWeek)
            
            for i in 1 ... maxWeek {
                let page = CurriculumView()
                page.data(obj: content, sidebar: sidebarList, week: i, curWeek: i == thisWeek, beginOfTerm : beginOfTerm)
                page.view.frame = CGRect(x: CGFloat(i - 1) * (scrollView?.frame.width)!, y: 0, width: (scrollView?.frame.width)!, height: (scrollView?.frame.height)!)
                scrollView?.addSubview(page.view)
                page.loadData()
            }
            
            // 防止当前学期结束导致下标越界
            // 不过前面已经保证过这里 scrollView.subviews.count > 0，不需要再做此判断
            let curPage = max(0, min(thisWeek - 1, scrollView.subviews.count - 1))
            scrollView?.scrollRectToVisible((scrollView?.subviews[curPage].frame)!, animated: false)// 这里false防止打开按周视图瞬间切换回概览时页面无显示
            
            let page = abs(Int(scrollView!.contentOffset.x / scrollView!.frame.width))
            title = "第 \(page + 1) 周"
            
            scrollView?.addSubview(swiper)
        }
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
    
    func updateContentSize (_ pages : Int) {
        scrollView?.contentSize = CGSize(width: CGFloat(pages) * (scrollView?.frame.width)!, height: (scrollView?.frame.height)!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果没课，什么也不做
        if scrollView.contentSize.width == 0 { return }
        
        if !overviewMode {
            let page = abs(Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5))
            title = "第 \(page + 1) 周"
        }
        swiper.syncApperance()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
}
