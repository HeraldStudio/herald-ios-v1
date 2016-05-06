//
//  TodayViewController.swift
//  Herald_iOS_Today
//
//  Created by 于海通 on 16/5/6.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var greetLabel : UILabel!
    @IBOutlet var tipLabel : UILabel!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var descLabel : UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let hour = GCalendar().hour
        let greetings = ["早上好，起的好早喔~", "早上好~", "上午好~", "中午好~", "下午好~", "晚上好~", "已经深夜了，注意休息喔~"]
        let greetingIndex = [6, 6, 6, 6, 6, 0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 6]
        let greeting = greetings[greetingIndex[hour]]
        greetLabel.text = greeting
        
        let noti = getNewestNotification()
        tipLabel.text = noti.tip
        titleLabel.text = noti.title
        descLabel.text = noti.desc

        completionHandler(NCUpdateResult.NewData)
    }
    
    func getNewestNotification() -> NotificationModel {
        if !ApiHelper.isLogin() {
            return NotificationModel("你还没有登录，登录后可在此查看最新提醒", "", "")
        }
        if let noti = ExperimentNotifier.getNotification() {
            return noti
        }
        if let noti = CurriculumNotifier.getNotification() {
            return noti
        }
        return NotificationModel("暂无提醒", "", "")
    }
}
