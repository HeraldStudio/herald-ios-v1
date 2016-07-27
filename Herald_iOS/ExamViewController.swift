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

class ExamViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader(.Right)
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableViewAutomaticDimension
        
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        
        showTipDialogIfUnknown("考试模块支持添加考试咯~\n\n点击右上角加号即可添加考试，添加好的考试与其它考试一样可以显示倒计时和通知提醒；\n\n点击添加好的考试也可以编辑或删除~", cachePostfix: "custom_exam") {}
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(swiper, 0xf5176c)
        loadCache()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance()
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
        
        // 学校考试
        let cache = CacheHelper.get("herald_exam")
        
        if cache == "" {
            refreshCache()
            return
        }
        
        // 自定义考试
        var customCache = CacheHelper.get("herald_exam_custom_\(ApiHelper.currentUser.userName)")
        if customCache == "" {
            customCache = "[]"
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        
        let jsonCustomCache = JSON.parse(customCache)
        
        sections.removeAll()
        titles.removeAll()
        endedExams.removeAll()
        comingExams.removeAll()
        
        for item in jsonCache.arrayValue {
            do {
                let model = try ExamModel(json: item)
                if model.days >= 0 {
                    comingExams.append(model)
                } else {
                    endedExams.append(model)
                }
            } catch {
                continue
            }
        }
        
        for i in 0 ..< jsonCustomCache.arrayValue.count {
            let item = jsonCustomCache.arrayValue[i]
            do {
                let model = try ExamModel(json: item)
                model.customIndex = i
                if model.days >= 0 {
                    comingExams.append(model)
                } else {
                    endedExams.append(model)
                }
            } catch {
                continue
            }
        }
        
        comingExams = comingExams.sort({$0.days < $1.days})
        endedExams = endedExams.sort({$0.days > $1.days})
        
        titles.append("考试倒计时")
        sections.append(comingExams)
        titles.append("已结束的考试")
        sections.append(endedExams)
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiSimpleRequest(.Post).api("exam").uuid()
            .toCache("herald_exam")
            .onResponse { success, _, _ in
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
        cell.time?.text = model.timeAndPlace
        cell.location?.text = model.period
        cell.days?.text = "还有\(abs(model.days))天"
        cell.days?.alpha = model.days >= 0 ? 1 : 0
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = sections[indexPath.section][indexPath.row]
        if item.customIndex == -1 {
            showMessage("固定的考试不允许编辑~")
        } else {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("MODULE_CUSTOM_EXAM") as! CustomExamViewController
            vc.index = item.customIndex
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}