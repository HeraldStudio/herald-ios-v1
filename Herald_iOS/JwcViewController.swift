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

class JwcViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView?
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        swiper.themeColor = navigationController?.navigationBar.backgroundColor
        tableView?.tableHeaderView = swiper
        tableView?.estimatedRowHeight = 64;
        tableView?.rowHeight = UITableViewAutomaticDimension;
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
    
    var noticeList : [[JwcNoticeModel]] = []
    
    var sectionList : [String] = []
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_jwc")
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
            for experiment in section.1 {
                guard let title = experiment.1["title"].string else {showError(); return}
                guard let time = experiment.1["date"].string else {showError(); return}
                guard let url = experiment.1["href"].string else {showError(); return}
                
                let model = JwcNoticeModel(title, time, url)
                list.append(model)
            }
            noticeList.append(list)
            sectionList.append(section.0)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("jwc").uuid().toCache("herald_jwc") {
            json -> String in
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
        UIApplication.sharedApplication().openURL(NSURL(string: noticeList[indexPath.section][indexPath.row].url)!)
    }
}