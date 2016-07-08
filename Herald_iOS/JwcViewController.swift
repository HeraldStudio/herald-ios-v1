//
//  JwcViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class JwcViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader(.Right)
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        tableView?.estimatedRowHeight = 64;
        tableView?.rowHeight = UITableViewAutomaticDimension;
        loadCache()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(swiper, 0x1976d2)
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
    
    var noticeList : [[JwcNoticeModel]] = []
    
    var sectionList : [String] = []
    
    func loadCache() {
        let cache = CacheHelper.get("herald_jwc")
        if cache == "" {
            refreshCache()
            return
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        
        noticeList.removeAll()
        sectionList.removeAll()
        for section in jsonCache {
            if section.1.count == 0 || section.0 == "最新动态" {
                continue
            }
            
            var list : [JwcNoticeModel] = []
            for experiment in section.1.arrayValue {
                list.append(JwcNoticeModel(json: experiment))
            }
            noticeList.append(list)
            sectionList.append(section.0)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("jwc").uuid().toCache("herald_jwc")
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
        return noticeList[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JwcTableViewCell", forIndexPath: indexPath) as! JwcTableViewCell
        
        let model = noticeList[indexPath.section][indexPath.row]
        cell.title?.text = model.title
        cell.time?.text = model.time
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        AppModule(title: "教务通知", url: noticeList[indexPath.section][indexPath.row].url).open()
    }
}