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
    
    override func viewDidLoad() {
        let cache = CacheHelper.getCache("herald_card")
        if cache != "" {
            loadCache()
        } else {
            refreshCache()
        }
    }
    
    var history : [[CardHistoryModel]] = []
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_card")
        if cache != "" {
            let jsonCache = JSON.parse(cache)["content"]
            let jsonArray = jsonCache["detial"]
            let extra = jsonCache["left"].string
            if extra != nil {
                title = "余额：" + extra!
            } else {
                title = "一卡通"
                showMessage("解析失败，请手动刷新")
            }
            
            history.removeAll()
            var lastDate = ""
            for i in 0 ..< jsonArray.count {
                let obj = jsonArray[i]
                guard let datetimeStr = obj["date"].string else { continue }
                let date = datetimeStr.componentsSeparatedByString(" ")[0]
                let time = datetimeStr.componentsSeparatedByString(" ")[1]
                guard let place = obj["system"].string else { continue }
                guard let type = obj["type"].string else { continue }
                guard let cost = obj["price"].string else { continue }
                guard let left = obj["left"].string else { continue }
                if date != lastDate {
                    history.append([])
                    lastDate = date
                }
                let newElement = CardHistoryModel(date: date, time: time, place: place, type: type, cost: cost, left: left)
                guard var lastSection = history.last else { continue }
                history.removeLast()
                lastSection.append(newElement)
                history.append(lastSection)
            }
        }
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
                }
            }.run()
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