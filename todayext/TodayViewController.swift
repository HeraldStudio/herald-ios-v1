//
//  TodayViewController.swift
//  todayext
//
//  Created by Vhyme on 2016/12/25.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var seuStatus : UILabel!
    
    @IBOutlet weak var refresh_iv : UIImageView!
    
    @IBOutlet weak var curriculum : UITableView!
    
    @IBOutlet weak var highlight_view : UIView!
    
    var data = [(UIImage, String)]()
    
    var curriculumList = [ClassModel]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 36
        
        curriculum.rowHeight = UITableViewAutomaticDimension
        curriculum.estimatedRowHeight = 48 // 这个一定要准，否则会导致展开状态刷新时高度不正确
        
        // 9以下隐藏高光背景因为会丑
        if #available(iOSApplicationExtension 10.0, *) {
            highlight_view.isHidden = false
        } else {
            highlight_view.isHidden = true
        }
        
        updateSize()
        
        //如果需要折叠
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCache() {
        data.removeAll()
        
        // 有实验消息的时候只显示实验；否则显示考试
        if let experimentNoti = TodayNotiExperiment.getNoti() {
            data.append((#imageLiteral(resourceName: "ic_experiment_invert"), experimentNoti))
        } else if let curriculumNoti = TodayNotiCurriculum.getNoti() {
            data.append((#imageLiteral(resourceName: "ic_curriculum_invert"), curriculumNoti))
        }
        if let cardNoti = TodayNotiCard.getNoti() {
            data.append((#imageLiteral(resourceName: "ic_card_invert"), cardNoti))
        }
        if let pedetailNoti = TodayNotiPedetail.getNoti() {
            data.append((#imageLiteral(resourceName: "ic_pedetail_invert"), pedetailNoti))
        }
        
        if data.count == 0 {
            if ApiHelper.isLogin() {
                data.append((#imageLiteral(resourceName: "ic_view_module"), "连接失败，请检查网络"))
            } else {
                data.append((#imageLiteral(resourceName: "ic_view_module"), "未登录，请打开小猴进行登录"))
            }
        }
        curriculumList = TodayCurriculumList.classList
        WifiLoginHelper(self).checkOnly()
        tableView.reloadData()
        curriculum.reloadData()
        updateSize()
    }
    
    var expanded = true
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        expanded = activeDisplayMode == .expanded
        updateSize()
    }
    
    func updateSize() {
        UIView.beginAnimations(nil, context: nil)
        if expanded {
            preferredContentSize = CGSize(width: view.frame.width, height: curriculum.frame.minY + curriculum.contentSize.height)
            highlight_view.alpha = 1
        } else {
            preferredContentSize = CGSize(width: view.frame.width, height: 95)
            highlight_view.alpha = 0
        }
        UIView.commitAnimations()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadCache()
        (TodayNotiPedetail.getRefresher() | TodayNotiCard.getRefresher()).onResponse { s, c, r in
            self.loadCache()
        }.run()
        completionHandler(NCUpdateResult.newData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView:
            return data.count
        case self.curriculum:
            return max(curriculumList.count, 1)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.tableView:
            let data = self.data[indexPath.row]
            return TodayNotiTableViewCell.instance(for: tableView, image: data.0, content: data.1)
        case self.curriculum:
            if curriculumList.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "TodayEmptyTableViewCell") ?? UITableViewCell()
            }
            let data = self.curriculumList[indexPath.row]
            return TodayCurriculumListTableViewCell.instance(for: tableView, model: data)
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func wifiLogin() {
        showMessage("请稍候")
        WifiLoginHelper(self).checkAndLogin()
    }
    
    @IBAction func refresh() {
        (TodayNotiPedetail.getRefresher() | TodayNotiCard.getRefresher()).onResponse { s, c, r in
            self.loadCache()
            }.run()
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.repeatCount = 1
        anim.duration = 1
        anim.isRemovedOnCompletion = false
        refresh_iv.layer.add(anim, forKey: nil)
        curriculum.reloadData()
    }
    
    override func showMessage(_ message: String) {
        seuStatus.text = message
    }
}
