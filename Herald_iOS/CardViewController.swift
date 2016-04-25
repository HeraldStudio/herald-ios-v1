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

class CardViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    static let url = "http://58.192.115.47:8088/wechat-web/login/initlogin.html"
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        swiper.themeColor = navigationController?.navigationBar.backgroundColor
        tableView?.tableHeaderView = swiper
        loadCache()
        refreshCache() // 自动判断是否需要刷新流水，不需要的话只刷新余额
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
    
    var history : [[CardHistoryModel]] = []
    
    func loadCache() {
        // 仅有余额的缓存，这个缓存刷新永远比完整的缓存快
        let leftCache = CacheHelper.get("herald_card_left")
        let cache = CacheHelper.get("herald_card")
        if cache == "" || leftCache == "" {
            return
        }
        
        let extra = JSON.parse(leftCache)["content"]["left"].stringValue
        title = "余额：" + extra
        
        let jsonCache = JSON.parse(cache)["content"]
        let jsonArray = jsonCache["detial"]
            
        history.removeAll()
        if jsonArray.count > 0 {
            let lastLeftStr = jsonArray[0]["left"].stringValue
            
            // 如果能查到上次余额，计算当天的总消费并显示成第一项
            // 如果查不到上次余额，即31天内没有消费过，则无法计算当天总消费项目，直接跳过
            if let lastLeft = Float(lastLeftStr) {
                guard let left = Float(extra) else { self.showError(); return }
                var todayCost = String(format: "%.2f", left - lastLeft)
                if !todayCost.containsString("-") && !todayCost.containsString("+") {
                    todayCost = (todayCost == "0.00" ? "-" : "+") + todayCost
                }
                history.append([CardHistoryModel("今天", "你可以到充值页面提前查看当天消费流水", "今日总收支", "未出账", todayCost, extra)])
            }
        }
        
        var lastDate = ""
        for i in 0 ..< jsonArray.count {
            let obj = jsonArray[i]
            let datetimeStr = obj["date"].stringValue
            let date = datetimeStr.split(" ")[0]
            let time = datetimeStr.split(" ")[1]
            let place = obj["system"].stringValue
            let type = obj["type"].stringValue
            var cost = obj["price"].stringValue
            let left = obj["left"].stringValue
            
            if date != lastDate {
                history.append([])
                lastDate = date
            }
            if !cost.containsString("-") && !cost.containsString("+") {
                cost = (cost == "0.00" ? "-" : "+") + cost
            }
            let newElement = CardHistoryModel(date, time, place, type, cost, left)
            guard var lastSection = history.last else { self.showError(); return }
            history.removeLast()
            lastSection.append(newElement)
            history.append(lastSection)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        
        // 先加入刷新余额的请求
        let manager = ApiThreadManager().add(
            ApiRequest().api("card").uuid()
                .toCache("herald_card_left") {json -> String in
                    guard let str = json.rawString() else {return ""}
                    return str
            })
        
        // 取上次刷新日期，与当前日期比较
        let lastRefresh = CacheHelper.get("herald_card_date")
        let dateComp = NSCalendar.currentCalendar().components(NSCalendarUnit(rawValue: UInt.max), fromDate: NSDate())
        let stamp = "\(dateComp.year)/\(dateComp.month)/\(dateComp.day)"
        
        // 若与当前日期不同，刷新完整流水记录
        if lastRefresh != stamp {
            manager.add(ApiRequest().api("card").uuid().post("timedelta", "31")
                .toCache("herald_card") {json -> String in
                    guard let str = json.rawString() else {return ""}
                    return str
                })
        }
        
        // 若刷新成功，保存当前日期
        manager.onFinish { success in
                    self.hideProgressDialog()
                    if success {
                        CacheHelper.set("herald_card_date", cacheValue: stamp)
                        self.loadCache()
                    } else {
                        self.showMessage("刷新失败，请重试或到充值页面查询")
                    }
                }.run()
    }
    
    func showError () {
        title = "一卡通"
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        if history.count == 0 { return 1 }
        return history[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 若为空，加一个条目提示用户这里是空的
        if history.count == 0 {
            return nil
        }
        return history[section][0].date
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 若为空，加一个条目提示用户这里是空的
        if history.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("CardEmptyTableViewCell", forIndexPath: indexPath)
        }
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
        // 若为空，加一个条目提示用户这里是空的
        return history.count > 0 ? history.count : 1
    }
    
    @IBAction func goToChargePage () {
        showTipDialogIfUnknown("注意：由于一卡通中心配置问题，充值之后需要刷卡消费一次，一卡通余额才能正常显示哦", cachePostfix: "card_charge") {
            () -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: CardViewController.url)!)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}