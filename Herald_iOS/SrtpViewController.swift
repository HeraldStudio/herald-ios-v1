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

class SrtpViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()

    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        loadCache()
        tableView.estimatedRowHeight = 105;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0xef5350)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        swiper.syncApperance()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    var items : [SrtpModel] = []
    
    func loadCache() {
        
        if Cache.srtp.isEmpty {
            refreshCache()
            return
        }
        
        let cache = Cache.srtp.value
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
                var totalCredit = item["total credit"].stringValue
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
                let model = SrtpModel(date, project, department, type, totalCredit, "学分："+credit)
                items.append(model)
            }
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        Cache.srtp.refresh { success, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache()
            } else {
                self.showMessage("刷新失败，请重试")
            }
        }
    }
    
    static func remoteRefreshNotifyDotState() -> ApiRequest {
        return Cache.srtp.refresher
    }
    
    func showError () {
        title = "课外研学"
        showMessage("解析失败，请刷新")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count > 0 ? items.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        if items.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SrtpTableViewCell", for: indexPath) as! SrtpTableViewCell
        
            let model = items[indexPath.row]
            cell.time.text = model.time
            cell.title.text = model.title
            cell.department.text = model.department
            cell.type.text = model.type
            cell.proportion.text = model.proportion
            cell.score.text = model.score
        
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "SrtpEmptyTableViewCell", for: indexPath)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "我参加的项目"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
