//
//  ExperimentViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ExperimentViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        loadCache()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(0x673ab7)
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
    
    var experimentList : [[ExperimentModel]] = []

    var sectionList : [String] = []
    
    func loadCache() {
        if Cache.experiment.isEmpty {
            refreshCache()
            return
        }
        
        let cache = Cache.experiment.value
        let jsonCache = JSON.parse(cache)["content"]
        
        experimentList.removeAll()
        sectionList.removeAll()
        for section in jsonCache {
            if section.1.count == 0 {
                continue
            }
            
            var list : [ExperimentModel] = []
            for experiment in section.1 {
                let model = ExperimentModel(json: experiment.1)
                list.append(model)
            }
            experimentList.append(list)
            sectionList.append(section.0)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        Cache.experiment.refresh { success, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache()
            } else {
                self.showMessage("刷新失败，请重试")
            }
        }
    }
    
    func showError () {
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        if sectionList.count == 0 { return 1 }
        return experimentList[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 若为空，加一个条目提示用户这里是空的
        if sectionList.count == 0 { return nil }
        return sectionList[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 若为空，加一个条目提示用户这里是空的
        if sectionList.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("ExperimentEmptyTableViewCell", forIndexPath: indexPath)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("ExperimentTableViewCell", forIndexPath: indexPath) as! ExperimentTableViewCell
        
        let model = experimentList[indexPath.section][indexPath.row]
        cell.name?.text = model.name
        cell.timeAndPlace?.text = model.timeAndPlace
        cell.teacher?.text = model.teacher
        cell.grade?.text = model.grade == "" ? "" : "成绩：\(model.grade)"
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        return sectionList.count > 0 ? sectionList.count : 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}