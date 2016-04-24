//
//  SrtpViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SrtpViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        loadCache()
        tableView.estimatedRowHeight = 105;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    var items : [SrtpModel] = []
    
    func loadCache() {
        
        /* 示例数据
         {
            "content": [
                {   "score": "及格", "total": "2.3", "name": "何永东", "card number": "09013123"     },
         
                {   "credit": "1.3", "proportion": "20%", "project": "东南大学先声校园客户端 良好",
                    "department": "计算机科学与工程学院", "date": "2015年1月", "type": "研学作品", "total credit": "6.5"    },
         
                {   "credit": "1.0", "proportion": "", "project": "研讨课（92）—创业成功案例 朱志坚",
                    "department": "", "date": "2015年5月", "type": "其它", "total credit": ""   }
            ],
            "code": 200
         }
         */
        let cache = CacheHelper.get("herald_srtp")
        if cache == "" {
            refreshCache()
            return
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        
        items.removeAll()
        
        for item in jsonCache.arrayValue {
            if item.dictionaryValue.keys.contains("score") {
                let total = item["total"].stringValue
                
                title = "总SRTP：" + total
            } else {
                let date = item["date"].stringValue
                let project = item["project"].stringValue
                var department = item["department"].stringValue
                var type = item["type"].stringValue
                var totalCredit = item["totalCredit"].stringValue
                let proportion = item["proportion"].stringValue
                let credit = item["credit"].stringValue
                
                if department != "" {
                    department = "项目所属：" + department
                }
                if type != "" {
                    type = "项目类型：" + type
                }
                if totalCredit != "" {
                    totalCredit = "总学分：" + totalCredit
                }
                if proportion != "" {
                    totalCredit += " (工作比例：\(proportion))"
                }
                let model = SrtpModel(date, project, department, type, totalCredit, credit)
                items.append(model)
            }
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("srtp").uuid().post("schoolnum", ApiHelper.getSchoolnum())
            .toCache("herald_srtp") {json -> String in
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
        title = "课外研学"
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count > 0 ? items.count : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if items.count > 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SrtpTableViewCell", forIndexPath: indexPath) as! SrtpTableViewCell
        
            let model = items[indexPath.row]
            cell.time.text = model.time
            cell.title.text = model.title
            cell.department.text = model.department
            cell.type.text = model.type
            cell.proportion.text = model.proportion
            cell.score.text = model.score
        
            return cell
        } else {
            return tableView.dequeueReusableCellWithIdentifier("SrtpEmptyTableViewCell", forIndexPath: indexPath)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "我参加的项目"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}