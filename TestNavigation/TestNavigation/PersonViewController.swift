//
//  PersonViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/4/1.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

//第三个子页面

class PersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self

        tableView.backgroundView?.backgroundColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor.clearColor()
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        
        self.tableView.estimatedRowHeight=300;
        
        self.tableView.rowHeight=UITableViewAutomaticDimension;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else if section == 1{
            return 1
        }
        else {
            return 3
        }
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let personCell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as! PersonTableViewCell
        personCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 0{
            personCell.label.text = "退出登录"
        }else if indexPath.section == 1{
            personCell.label.text = "摇一摇登录校园网"
        }else {
            switch indexPath.row {
            case 0:
                personCell.label.text = "关于我们"
            case 1:
                personCell.label.text = "意见反馈"
            case 2:
                personCell.label.text = "检查更新"
            default:
                break
            }
        }
        return personCell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let indicateView = UIView()
        indicateView.frame.size = CGSizeMake(375,50)
        
        var indicateName = ""
        switch section {
        case 0:
            indicateName = "\(user["name"]!)"
        case 1:
            indicateName = "校园网设置"
        case 2:
            indicateName = "小猴偷米"
        default:
            break
        }
        
        let nameLabel = UILabel(frame: CGRectMake(20,20,80,20))
        nameLabel.text = indicateName
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.textColor = selfcolor
        nameLabel.font = UIFont.systemFontOfSize(15)
        indicateView.addSubview(nameLabel)
        
        indicateView.backgroundColor = UIColor.whiteColor()
        return indicateView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}
