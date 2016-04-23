//
//  LibraryViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class LibraryViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    var list : [[LibraryBookModel]] = []
    
    func loadCache() {
        let borrowCache = CacheHelper.getCache("herald_library_borrowbook")
        let hotCache = CacheHelper.getCache("herald_library_hotbook")
        if borrowCache == "" || hotCache == "" {
            refreshCache()
            return
        }
        
        list.removeAll()
        // 解析已借图书缓存
        var borrowList : [LibraryBookModel] = []
        for k in JSON.parse(borrowCache)["content"].arrayValue {
            let dueDate = k["due_date"].stringValue
            let author = k["author"].stringValue
            let barcode = k["barcode"].stringValue
            let renderDate = k["render_date"].stringValue
            //  let place = k["place"].stringValue
            let title = k["title"].stringValue
            let renewTime = k["renew_time"].stringValue
            
            // 此处“未续借”、“已续借”字样若要修改，需要同时修改tableView(_:cellForRowAtIndexPath:)函数中的相应判断
            let model = LibraryBookModel(title, author, "\(renderDate)借书 \(dueDate)到期 \(renewTime == "0" ? "未续借" : "已续借")", barcode, "")
            borrowList.append(model)
        }
        list.append(borrowList)
        
        // 解析热门图书缓存
        var hotList : [LibraryBookModel] = []
        for k in JSON.parse(hotCache)["content"].arrayValue {
            let count = k["count"].stringValue
            let place = k["place"].stringValue
            let name = k["name"].stringValue
            let author = k["author"].stringValue
            
            let model = LibraryBookModel(name, author, place, "", count)
            hotList.append(model)
        }
        list.append(hotList)
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        
        ApiThreadManager().addAll(
            ApiRequest().api("library").uuid()
                .toCache("herald_library_borrowbook") {json -> String in
                    guard let str = json.rawString() else {return ""}
                    return str
                }.onFinish {
                    _, code, _ in
                    if code == 401 {
                        self.displayLibraryAuthDialog()
                    }
                }
            ,
            ApiRequest().api("library_hot").uuid()
                .toCache("herald_library_hotbook") {json -> String in
                    guard let str = json.rawString() else {return ""}
                    return str
            }
            ).onFinish { success in
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
        // 若无记录，添加一个条目显示没有记录
        return list[section].count == 0 ? 1 : list[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "我借阅的图书" : "热门图书"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 若无记录，添加一个条目显示没有记录
        if list[indexPath.section].count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("LibraryEmptyTableViewCell", forIndexPath: indexPath)
        } else {
            if indexPath.section == 0 { // 借阅书籍
                let cell = tableView.dequeueReusableCellWithIdentifier("LibraryBorrowBookTableViewCell", forIndexPath: indexPath) as! LibraryTableViewCell
            
                let model = list[indexPath.section][indexPath.row]
                cell.title.text = model.title
                cell.line1.text = model.line1
                cell.line2.text = model.line2
                cell.barcode = model.barcode
                cell.renew.alpha = model.line2.containsString("未续借") ? 0 : 1
                cell.renew.enabled = model.line2.containsString("未续借")
                
                cell.renew.addTarget(cell, action: #selector(cell.renewBook), forControlEvents: UIControlEvents.PrimaryActionTriggered)
                return cell
            } else { // 热门书籍
                let cell = tableView.dequeueReusableCellWithIdentifier("LibraryHotBookTableViewCell", forIndexPath: indexPath) as! LibraryTableViewCell
                
                let model = list[indexPath.section][indexPath.row]
                cell.title.text = model.title
                cell.line1.text = model.line1
                cell.line2.text = model.line2
                cell.count.text = model.count
                return cell
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func displayLibraryAuthDialog () {
        let dialog = UIAlertController(title: "绑定图书馆账号", message: "你还没有绑定图书馆账号，或者绑定的账号不正确，请输入在图书馆官网设定的图书馆密码，默认为一卡通号", preferredStyle: UIAlertControllerStyle.Alert)
        
        dialog.addTextFieldWithConfigurationHandler { field in
            field.placeholder = "密码"
            field.secureTextEntry = true
        }
        
        dialog.addAction(UIAlertAction(title: "绑定", style: UIAlertActionStyle.Default, handler: { _ in
            if let password = dialog.textFields![0].text {
                self.showProgressDialog()
                ApiRequest().url(ApiHelper.auth_update_url).plain()
                    .post("cardnum", ApiHelper.getUserName())
                    .post("password", ApiHelper.getPassword())
                    .post("lib_username", ApiHelper.getUserName())
                    .post("lib_password", password)
                    .onFinish { _, _, response in
                        if response == "OK" {
                            //返回OK说明认证成功
                            self.refreshCache()
                        } else {
                            self.showMessage("绑定失败，请重试")
                        }
                    }.run()
            }
        }))
        
        presentViewController(dialog, animated: true, completion: nil)
    }
}