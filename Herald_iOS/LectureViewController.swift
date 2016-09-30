//
//  LectureViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class LectureViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        tableView?.estimatedRowHeight = 70;
        tableView?.rowHeight = UITableViewAutomaticDimension;
        loadCache()
        refreshCache()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(swiper, 0xf44336)
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
    
    var list : [[LectureModel]] = []
    
    func loadCache() {
        let noticeCache = Cache.lectureNotices.value
        let recordCache = Cache.lectureRecords.value
        if noticeCache == "" || recordCache == "" {
            return
        }
        
        let count = JSON.parse(recordCache)["content"]["detial"].count
        title = "已听讲座：\(count)次"
        
        // 解析讲座预告缓存
        list.removeAll()
        var noticeList : [LectureModel] = []
        for k in JSON.parse(noticeCache)["content"].arrayValue {
            let model = LectureModel(json: k)
            noticeList.append(model)
        }
        list.append(noticeList)
        
        // 解析讲座记录缓存
        var recordList : [LectureModel] = []
        for k in JSON.parse(recordCache)["content"]["detial"].arrayValue {
            let dateTime = k["date"].stringValue
            let place = k["place"].stringValue
            
            let dateAndTime = dateTime.split(" ")
            let model = LectureModel(dateAndTime[0], "打卡时间：" + dateAndTime[1], "讲座地点：" + place)
            recordList.append(model)
        }
        list.append(recordList)
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        
        (Cache.lectureRecords.refresher | Cache.lectureNotices.refresher).onFinish { success, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache()
            } else {
                self.showMessage("刷新失败，请重试")
            }
        }.run()
    }
    
    func showError () {
        title = "人文讲座"
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 若无记录，添加一个条目显示没有记录
        return list[section].count == 0 ? 1 : list[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "讲座预告" : "听讲记录"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 若无记录，添加一个条目显示没有记录
        if list[indexPath.section].count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("LectureEmptyTableViewCell", forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LectureTableViewCell", forIndexPath: indexPath) as! LectureTableViewCell
        
            let model = list[indexPath.section][indexPath.row]
            cell.topic?.text = model.topic
            cell.speaker?.text = model.speaker
            cell.dateAndPlace?.text = model.dateAndPlace
            return cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}