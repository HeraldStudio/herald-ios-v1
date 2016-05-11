//
//  ActivityViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/11.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ActivityViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var page = 0
    
    /// 下拉刷新和上拉加载方面的处理
    let swiper = SwipeRefreshHeader()
    let puller = PullLoadFooter()
    
    override func viewDidLoad() {
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)! + 8
        puller.frame = CGRect(x: 0, y: 0, width: tw, height: th)
        puller.loader = {() in
            self.showProgressDialog()
            self.performSelector(#selector(self.loadNextPage), withObject: nil, afterDelay: 1)
        }
        tableView.tableFooterView = puller
        
        tableView.estimatedRowHeight = 240;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        swiper.themeColor = navigationController?.navigationBar.barTintColor
        swiper.refresher = {() in
            self.showProgressDialog()
            self.performSelector(#selector(self.refresh), withObject: nil, afterDelay: 1)
        }
        tableView?.tableHeaderView = swiper
        refresh()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance((tableView?.contentOffset)!)
        puller.syncApperance()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
        puller.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
        puller.endDrag()
    }
    
    /// 主体部分
    @IBAction func refresh() {
        showProgressDialog()
        ApiRequest().get().url("http://115.28.27.150/herald/api/v1/huodong/get").toCache("herald_activity") { json in json.rawString()! }
            .onFinish { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.data.removeAll()
                    self.page = 1
                    
                    for k in JSON.parse(CacheHelper.get("herald_activity"))["content"].arrayValue {
                        self.data.append(ActivityModel(k))
                    }
                    
                    self.puller.enable()
                    self.tableView.reloadData()
                } else {
                    self.showMessage("刷新失败，请重试")
                }
        }.run()
    }
    
    func loadNextPage() {
        showProgressDialog()
        ApiRequest().get().url("http://115.28.27.150/herald/api/v1/huodong/get?page=\(page + 1)").onFinish { success, _, response in
                self.hideProgressDialog()
                if success {
                    self.page += 1
                    let array = JSON.parse(response)["content"].arrayValue
                    for k in array {
                        self.data.append(ActivityModel(k))
                    }
                    
                    if array.count == 0 {
                        self.showMessage("没有更多数据")
                        self.puller.disable("没有更多数据")
                    }
                    self.tableView.reloadData()
                } else {
                    self.showMessage("加载失败，请重试")
                }
        }.run()
    }
    
    var data : [ActivityModel] = []
    
    /// 表格数据源的处理
    @IBOutlet var tableView : UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count > 0 ? data.count : 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if data.count == 0 { return }
        
        let model = data[indexPath.row]
        
        if model.detailUrl != "" {
            AppModule(title: "校园活动", url: model.detailUrl).open(navigationController)
        } else {
            showMessage("该活动没有详情页面")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if data.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("ActivityEmptyTableViewCell", forIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityTableViewCell", forIndexPath: indexPath) as! ActivityTableViewCell
        let model = data[indexPath.row]
        
        cell.title.text = model.title
        cell.assoc.text = model.assoc
        cell.state.text = model.state.rawValue
        cell.state.textColor = model.state == .Going ? navigationController?.navigationBar.barTintColor : UIColor.grayColor()
        
        cell.pic.kf_setImageWithURL(NSURL(string: model.picUrl)!, placeholderImage: UIImage(named: "default_herald"))
        cell.intro.text = "活动时间：\(model.activityTime) / 地点：\(model.location)\n\(model.intro)"
        
        return cell
    }
}