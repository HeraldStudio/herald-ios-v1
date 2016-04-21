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

class ExperimentViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView?
    
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
    
    var experimentList : [[ExperimentModel]] = []

    var sectionList : [String] = []
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_experiment")
        if cache == "" {
            refreshCache()
            return
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        
        experimentList.removeAll()
        sectionList.removeAll()
        for section in jsonCache {
            if section.1.count == 0 {
                continue
            }
            
            var list : [ExperimentModel] = []
            for experiment in section.1 {
                guard let name = experiment.1["name"].string else {showError(); return}
                guard let date = experiment.1["Date"].string else {showError(); return}
                guard let day = experiment.1["Day"].string else {showError(); return}
                guard let place = experiment.1["Address"].string else {showError(); return}
                guard let teacher = experiment.1["Teacher"].string else {showError(); return}
                
                var grade : String = ""
                if experiment.1["Grade"].string != nil {
                    grade = experiment.1["Grade"].string!
                }
                let model = ExperimentModel(name, date + day + " @" + place, teacher, grade)
                list.append(model)
            }
            experimentList.append(list)
            sectionList.append(section.0)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("phylab").uuid()
            .toCache("herald_experiment") {json -> String in
                guard let str = json.rawString() else {return ""}
                return str
            }
            .onFinish { success, _, _ in
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
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experimentList[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExperimentTableViewCell", forIndexPath: indexPath) as! ExperimentTableViewCell
        
        let model = experimentList[indexPath.section][indexPath.row]
        cell.name?.text = model.name
        cell.timeAndPlace?.text = model.timeAndPlace
        cell.teacher?.text = model.teacher
        cell.grade?.text = model.grade
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}