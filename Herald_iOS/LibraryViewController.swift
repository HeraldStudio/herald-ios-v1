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

class LibraryViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView.tableHeaderView = swiper
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 72
        loadCache()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(swiper, 0xe53935)
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
    
    var list : [[LibraryBookModel]] = []
    
    func loadCache() {
        if Cache.libraryBorrowBook.isEmpty || Cache.libraryHotBook.isEmpty {
            refreshCache()
            return
        }
        
        let borrowCache = Cache.libraryBorrowBook.value
        let hotCache = Cache.libraryHotBook.value
        
        list.removeAll()
        var borrowList : [LibraryBookModel] = []
        
        if JSON.parse(borrowCache)["code"].intValue == 401 {
            displayLibraryAuthDialog()
        } else {
            // 解析已借图书缓存
            for k in JSON.parse(borrowCache)["content"].arrayValue {
                borrowList.append(LibraryBookModel(borrowedBookJson: k))
            }
        }
        list.append(borrowList)
        
        // 解析热门图书缓存
        var hotList : [LibraryBookModel] = []
        for k in JSON.parse(hotCache)["content"].arrayValue {
            hotList.append(LibraryBookModel(hotBookJson: k))
        }
        list.append(hotList)
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        
        (Cache.libraryBorrowBook.refresher | Cache.libraryHotBook.refresher).onFinish { success, _ in
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
                cell.count.text = model.count
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
        let barcode = list[indexPath.section][indexPath.row].barcode
        if barcode != "" {
            showProgressDialog()
            ApiSimpleRequest(.Post).api("renew").uuid().post("barcode", barcode).onResponse { _, _, response in
                self.hideProgressDialog()
                var response = JSON.parse(response)["content"].stringValue
                response = response == "success" ? "续借成功" : response
                self.showMessage(response)
            } .run()
        }
    }
    
    func displayLibraryAuthDialog () {
        let dialog = UIAlertController(title: "绑定图书馆账号", message: "你还没有绑定图书馆账号或账号不正确，请重新绑定：", preferredStyle: UIAlertControllerStyle.Alert)
        
        dialog.addTextFieldWithConfigurationHandler { field in
            field.placeholder = "图书馆密码（默认为一卡通号）"
            field.secureTextEntry = true
        }
        
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: {
            _ in
        }))
        
        dialog.addAction(UIAlertAction(title: "绑定", style: UIAlertActionStyle.Default, handler: { _ in
            if let libPassword = dialog.textFields![0].text {
                self.showProgressDialog()
                ApiSimpleRequest(.Post).url(ApiHelper.auth_update_url)
                    .post("cardnum", ApiHelper.currentUser.userName)
                    .post("password", ApiHelper.currentUser.password)
                    .post("lib_username", ApiHelper.currentUser.userName)
                    .post("lib_password", libPassword)
                    .onResponse { _, _, response in
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