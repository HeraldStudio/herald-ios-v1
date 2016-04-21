//
//  CardViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CardViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    var history : [[CardHistoryModel]] = []
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_card")
        if cache == "" {
            refreshCache()
            return
        }
        
        let jsonCache = JSON.parse(cache)["content"]
        let jsonArray = jsonCache["detial"]
        guard let extra = jsonCache["left"].string else { self.showError(); return }
        title = "余额：" + extra
            
        history.removeAll()
        if jsonArray.count > 0 {
            guard let lastLeftStr = jsonArray[0]["left"].string else { self.showError(); return }
            guard let lastLeft = Float(lastLeftStr) else { self.showError(); return }
            guard let left = Float(extra) else { self.showError(); return }
            var todayCost = String(format: "%.2f", left - lastLeft)
            if !todayCost.containsString("-") && !todayCost.containsString("+") {
                todayCost = (todayCost == "0.00" ? "-" : "+") + todayCost
            }
            history.append([CardHistoryModel(date: "今天", time: "你可以到充值页面提前查看当天消费流水", place: "今日总消费", type: "未出账", cost: todayCost, left: extra)])
        }
        
        var lastDate = ""
        for i in 0 ..< jsonArray.count {
            let obj = jsonArray[i]
            guard let datetimeStr = obj["date"].string else { self.showError(); return }
            let date = datetimeStr.componentsSeparatedByString(" ")[0]
            let time = datetimeStr.componentsSeparatedByString(" ")[1]
            guard let place = obj["system"].string else { self.showError(); return }
            guard let type = obj["type"].string else { self.showError(); return }
            guard var cost = obj["price"].string else { self.showError(); return }
            guard let left = obj["left"].string else { self.showError(); return }
            if date != lastDate {
                history.append([])
                lastDate = date
            }
            if !cost.containsString("-") && !cost.containsString("+") {
                cost = (cost == "0.00" ? "-" : "+") + cost
            }
            let newElement = CardHistoryModel(date: date, time: time, place: place, type: type, cost: cost, left: left)
            guard var lastSection = history.last else { self.showError(); return }
            history.removeLast()
            lastSection.append(newElement)
            history.append(lastSection)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        ApiRequest().api("card").uuid().post("timedelta", "31")
            .toCache("herald_card") {json -> String in
                guard let str = json.rawString() else {return ""}
                return str
            }
            .onFinish { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.loadCache()
                    self.showMessage("刷新成功")
                } else {
                    self.showMessage("刷新失败，你也可以到充值页面查询")
                }
            }.run()
    }
    
    func showError () {
        title = "一卡通"
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return history[section][0].date
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CardTableViewCell", forIndexPath: indexPath) as! CardTableViewCell
        
        let model = history[indexPath.section][indexPath.row]
        cell.time?.text = model.time
        cell.place?.text = model.place
        cell.type?.text = model.type
        cell.cost?.text = model.cost
        cell.left?.text = model.left
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return history.count
    }
    
    @IBAction func goToChargePage () {
        showTipDialogIfUnknown("注意：由于一卡通中心配置问题，充值之后需要刷卡消费一次，一卡通余额才能正常显示哦", cachePostfix: "card_charge") {
            () -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "http://58.192.115.47:8088/wechat-web/login/initlogin.html")!)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}