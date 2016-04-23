//
//  GradeViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class GradeViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var gpa : UILabel!
    
    @IBOutlet var gpaWithoutRevamp : UILabel!
    
    @IBOutlet var calculateTime : UILabel!

    override func viewDidLoad() {
        loadCache()
    }
    
    var sections : [[GradeModel]] = []
    var titles : [String] = []
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_grade_gpa")
        if cache == "" {
            refreshCache()
            return
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        
        sections.removeAll()
        titles.removeAll()
        
        for item in jsonCache.arrayValue {
            if item.dictionaryValue.keys.contains("gpa") {
                let gpaStr = item["gpa"].stringValue
                let gpaWithoutRevampStr = item["gpa without revamp"].stringValue
                let calculateTimeStr = item["calculate time"].stringValue
                
                gpa.text = gpaStr
                gpaWithoutRevamp.text = gpaWithoutRevampStr
                calculateTime.text = "数据取自教务处，最后计算时间：" + calculateTimeStr
            } else {
                let name = item["name"].stringValue
                let extra = item["extra"].stringValue
                let credit = item["credit"].stringValue
                let semester = item["semester"].stringValue
                let score = item["score"].stringValue
                let type = item["type"].stringValue
                
                var desc = type
                if extra != "" { desc += " (\(extra))" }
                desc += " 学分：\(credit)"
                
                let model = GradeModel(name, desc, score)
                if titles.last == nil || titles.last! != semester {
                    sections.append([])
                    titles.append(semester)
                }
                
                var last = sections.last!
                sections.removeLast()
                last.append(model)
                sections.append(last)
            }
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("gpa").uuid()
            .toCache("herald_grade_gpa") {json -> String in
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
        // 若为空，加一个条目提示用户这里是空的
        if sections.count == 0 { return 1 }
        return sections[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 若为空，加一个条目提示用户这里是空的
        if sections.count == 0 { return nil }
        return titles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 若为空，加一个条目提示用户这里是空的
        if sections.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("GradeEmptyTableViewCell", forIndexPath: indexPath)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("GradeTableViewCell", forIndexPath: indexPath) as! GradeTableViewCell
        
        let model = sections[indexPath.section][indexPath.row]
        cell.course?.text = model.course
        cell.desc?.text = model.desc
        cell.score?.text = model.score
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        return sections.count > 0 ? sections.count : 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}