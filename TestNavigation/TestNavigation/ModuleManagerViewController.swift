//
//  ModuleManagerViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/3/31.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

@objc protocol ReloadViewControllerDelegate{
    func setupDetailVC()
}

class ModuleManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {

    @IBOutlet weak var moduleTableView: UITableView!
    //weak var delegate: ReloadViewControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        //labelMonkey.removeFromSuperview()
        underLineView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moduleTableView.delegate = self
        moduleTableView.showsHorizontalScrollIndicator = false
        moduleTableView.showsVerticalScrollIndicator = false
        //moduleTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.moduleTableView.estimatedRowHeight=64;
        self.moduleTableView.rowHeight=UITableViewAutomaticDimension;
        
        setupNavBar()
        
        //var backButton = UIBarButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ModuleManagerViewController.cancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true
        
        //let  beforeVC = navigationController?.viewControllers[(navigationController?.viewControllers.count)! - 2] as! ViewController
        //beforeVC.moduleVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavBar() {
        let navBar = UIView(frame: CGRectMake(0.0,64.0,375,50))
        navBar.backgroundColor = UIColor.whiteColor()
        let module = UILabel(frame: CGRectMake(23.0,20.0,40,20))
        module.text = "模块"
        module.textAlignment = NSTextAlignment.Center
        module.textColor = UIColor.lightGrayColor()
        module.font = UIFont.systemFontOfSize(14)
        
        let card = UILabel(frame: CGRectMake(237.0,20.0,40,20))
        card.text = "卡片"
        card.textAlignment = NSTextAlignment.Center
        card.textColor = UIColor.lightGrayColor()
        card.font = UIFont.systemFontOfSize(14)
        
        let shortcut = UILabel(frame: CGRectMake(300.0,20.0,50,20))
        shortcut.text = "快捷栏"
        shortcut.textAlignment = NSTextAlignment.Center
        shortcut.textColor = UIColor.lightGrayColor()
        shortcut.font = UIFont.systemFontOfSize(14)
        
        navBar.addSubview(module)
        navBar.addSubview(card)
        navBar.addSubview(shortcut)
        self.view.addSubview(navBar)
    }
    
    func cancel()
    {
        print("")
        navigationController?.popViewControllerAnimated(true)
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView€: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 14
        } else {
            return 1
        }
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "moduleCell"
        let moduleManaCell = moduleTableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! ModuleManaTableViewCell
        
        //cell复用必须重新隐藏
        moduleManaCell.card.hidden = false
        
        moduleManaCell.cellNum = indexPath.row
        moduleManaCell.selectionStyle = UITableViewCellSelectionStyle.None
        moduleManaCell.icon.image = UIImage(named: "\(userModuleDict[indexPath.row][0])")
        moduleManaCell.label.text = String(userModuleDict[indexPath.row][1])
        moduleManaCell.card.on = userModuleDict[indexPath.row][3] as! Bool
        moduleManaCell.module.on = userModuleDict[indexPath.row][2] as! Bool
        
        switch moduleDict[indexPath.row][1] {
        case "一卡通","跑操助手","课表助手","实验助手","人文讲座","教务通知":
            break
        default:
            moduleManaCell.card.hidden = true
        }
        return moduleManaCell
    }
}
