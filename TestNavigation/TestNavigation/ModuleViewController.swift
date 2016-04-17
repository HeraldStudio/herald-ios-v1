//
//  ModuleViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/3/29.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

//第二个子页面

class ModuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var moduleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moduleTableView.delegate = self
        self.view.backgroundColor = UIColor.clearColor()
        //detailTableView.bounces = false
        
        moduleTableView.backgroundView?.backgroundColor = UIColor.clearColor()
        moduleTableView.backgroundColor = UIColor.clearColor()
        moduleTableView.showsHorizontalScrollIndicator = false
        moduleTableView.showsVerticalScrollIndicator = false
        //moduleTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //setupModuleManager()
        self.moduleTableView.estimatedRowHeight=74;
        
        self.moduleTableView.rowHeight=UITableViewAutomaticDimension;
    }
    
    var tapGestureRecogniser:UITapGestureRecognizer!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupModuleManager() {
        let topManager = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 80))
        topManager.backgroundColor = UIColor.whiteColor()
        let img = UIImageView(image: UIImage(named: "ic_menu_manage"))
        img.frame = CGRectMake(16, 26, 25, 25)
        topManager.addSubview(img)
        
        let label = UILabel(frame: CGRect(x: 156, y: 26, width: 64, height: 22))
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.text = "模块管理"
        topManager.addSubview(label)
        
        moduleTableView.tableHeaderView = topManager
        
    }

    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moduleCell = moduleTableView.dequeueReusableCellWithIdentifier("moduleCell", forIndexPath: indexPath) as! ModuleTableViewCell
        //moduleCell.selectionStyle = UITableViewCellSelectionStyle.None
        moduleCell.icon.image = UIImage(named: "\(moduleDict[indexPath.row][0])")
        moduleCell.label.text = moduleDict[indexPath.row][1]
        moduleCell.detail.text = moduleDict[indexPath.row][2]
        return moduleCell
    }
    
    /*func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)
        -> CGFloat {
        return 74
    }*/
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}
