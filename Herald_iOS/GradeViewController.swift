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

class GradeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var gpa : UILabel!
    
    @IBOutlet var gpaWithoutRevamp : UILabel!
    
    @IBOutlet var calculateTime : UILabel!

    override func viewDidLoad() {
        loadCache()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x4caf50)
    }
    
    var sections : [[GradeModel]] = []
    var titles : [String] = []
    
    func loadCache() {
        if Cache.grade.isEmpty {
            refreshCache()
            return
        }
        
        let cache = Cache.grade.value
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
                
                let model = GradeModel(name, desc, "成绩："+score)
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
        Cache.grade.refresh { success, _ in
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        if sections.count == 0 { return 1 }
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 若为空，加一个条目提示用户这里是空的
        if sections.count == 0 { return nil }
        return titles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        // 若为空，加一个条目提示用户这里是空的
        if sections.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "GradeEmptyTableViewCell", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradeTableViewCell", for: indexPath) as! GradeTableViewCell
        
        let model = sections[indexPath.section][indexPath.row]
        cell.course?.text = model.course
        cell.desc?.text = model.desc
        cell.score?.text = model.score
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        return sections.count > 0 ? sections.count : 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
