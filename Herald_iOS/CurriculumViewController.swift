//
//  ViewController.swift
//  curriculum
//
//  Created by 于海通 on 16/2/24.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import UIKit
import SwiftyJSON

class CurriculumViewController : UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, LoginUserNeeded {
    
    enum Mode : Int {
        case Weekly = 0
        case Overview = 1
        case List = 2
    }
    
    var mode : Mode {
        return Mode(rawValue: segmentedControl.selectedSegmentIndex) ?? .Weekly
    }
    
    var thisWeek = 0
    
    var term: String = ""
    
    var tempCache : String = ""
    
    @IBOutlet var scrollView : UIScrollView!
    
    @IBOutlet var tableView : UITableView!
    
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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 36
        tableView.showsVerticalScrollIndicator = false
        
        if term != "" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(self.setAsCurrentTerm))
        }
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
        
        if term == "" { // 当前设定学期的显示
            Cache.curriculum.refresher.onFinish { success, _ in
                self.hideProgressDialog()
                if success {
                    self.readLocal()
                } else {
                    self.showMessage("刷新失败")
                }
            }.run()
        } else { // 临时自定义学期的显示
            ApiSimpleRequest(.post).api("curriculum").uuid().post("term", term).onResponse { s, c, r in
                self.hideProgressDialog()
                if s {
                    self.tempCache = r
                    self.readLocal()
                } else {
                    self.showMessage("刷新失败")
                }
            }.run()
        }
    }
    
    // 默认参数，如果带自定义参数说明使用自定义学期，而不用当前学期的缓存
    @IBAction func readLocal () {
        
        var cache = ""
        
        if term == "" {
            cache = Cache.curriculum.value
        } else {
            cache = tempCache
        }
        
        if cache == "" {
            refreshCache()
            return
        }
        
        let json = JSON.parse(cache)
            
        // 读取json内容
        let content = json["content"]
        
        var sidebarList : [String:String] = [:]
        
        // 将课程的授课教师和学分信息放入键值对
        let sidebarArray = json["sidebar"]
        for i in 0 ..< sidebarArray.count {
            let obj = sidebarArray[i]
            let lecturer = obj["lecturer"].stringValue
            let credit = obj["credit"].stringValue
            let course = obj["course"].stringValue
            sidebarList.updateValue("授课教师：\(lecturer)\n课程学分：\(credit)", forKey: course)
        }
        
        // 概览模式
        switch mode {
        case .Weekly:
            tableView.isHidden = true
            scrollView.isHidden = false
            tableView.tableHeaderView = nil
            
            var maxWeek = 0
            
            // 计算总周数
            for weekNum in WEEK_NUMS {
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
                showMessage("当前学期没有详细课程安排，您可以查看所有课程列表")
                
                segmentedControl.selectedSegmentIndex = 2
                segmentedControl.isHidden = true
                readLocal()
                
                return
            } else {
                segmentedControl.isHidden = false
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
            title = "\(page + 1)周"
            
            scrollView?.addSubview(swiper)
            
        case .Overview:
            tableView.isHidden = true
            scrollView.isHidden = false
            tableView.tableHeaderView = nil
            
            removeAllPages()
            updateContentSize(1)
            
            let page = CurriculumOverviewView()
            page.data(obj: content, sidebar: sidebarList)
            page.view.frame = CGRect(x: 0, y: 0, width: (scrollView?.frame.width)!, height: (scrollView?.frame.height)!)
            scrollView?.addSubview(page.view)
            page.loadData()
            
            scrollView?.addSubview(swiper)
            title = "按周"
            
        case .List:
            tableView.isHidden = false
            scrollView.isHidden = true
            tableView.tableHeaderView = swiper
            
            removeAllPages()
            updateContentSize(0)
            
            sidebarClasses = sidebarArray.arrayValue.map { SidebarClassModel(sidebarJson: $0) }
            
            tableView.reloadData()
            title = "按周"
        }
    }
    
    func showError () {
        title = "按周"
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
        
        if mode == .Weekly {
            let page = abs(Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5))
            title = "\(page + 1)周"
        }
        swiper.syncApperance()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    var sidebarClasses = [SidebarClassModel]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, sidebarClasses.count)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "所有课程列表"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sidebarClasses.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "CurriculumEmptyTableViewCell")!
        }
        return CurriculumFloatClassTableViewCell.instance(for: tableView, sidebarModel: sidebarClasses[indexPath.row])
    }
    
    @objc func setAsCurrentTerm() {
        showQuestionDialog("确定保存\(term)为当前学期吗？\n该学期将自动匹配到离现在最近且合适的开学日期。若要还原，直接在课表助手中进行刷新即可。") {
            if self.term == "" || self.tempCache == "" {
                self.showMessage("该学期数据未加载，无法保存为当前学期！")
                return
            }
            Cache.curriculum.value = self.tempCache
            self.showMessage("已将\(self.term)保存为当前学期，若要还原，直接在课表助手中进行刷新即可。")
        }
    }
}
