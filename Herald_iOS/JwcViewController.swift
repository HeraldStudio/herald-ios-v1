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

class JwcViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        tableView?.estimatedRowHeight = 64;
        tableView?.rowHeight = UITableViewAutomaticDimension;
        loadCache()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x1976d2)
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
    
    var noticeList : [[JwcNoticeModel]] = []
    
    var sectionList : [String] = []
    
    func loadCache() {
        if Cache.jwc.isEmpty {
            refreshCache()
            return
        }
        
        let cache = Cache.jwc.value
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
        Cache.jwc.refresh { success, _ in
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
        return noticeList[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JwcTableViewCell", for: indexPath) as! JwcTableViewCell
        
        let model = noticeList[indexPath.section][indexPath.row]
        cell.title?.text = model.title
        cell.time?.text = model.time
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        AppModule(title: "教务通知", url: noticeList[indexPath.section][indexPath.row].url).open()
    }
}
