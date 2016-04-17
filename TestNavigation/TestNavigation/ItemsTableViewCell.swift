//
//  ItemsTableViewCell.swift
//  TestNavigation
//
//  Created by Howie on 16/3/31.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var secondHeight: NSLayoutConstraint!
    @IBOutlet weak var thirdHeight: NSLayoutConstraint!
    @IBOutlet weak var customView: UIView!
    //@IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView3: UIStackView!
    
    var tempModule = [Array<NSObject>]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customView.layer.cornerRadius = 5
        
        for index in userModuleDict {
            if index[2] as! Bool {
                tempModule.append(index)
            }
        }
        //print(tempModule)
        
        //判断所读取的便捷模块数
        if tempModule.count < 5{
            stackView2.hidden = true
            stackView3.hidden = true
            secondHeight.constant = 0
            thirdHeight.constant = 0
            //loadLevel1(tempModule.count)
            for index in 0..<tempModule.count {
                stackView1.addSubview(loadLevel(index,level: 0))
            }
            stackView1.addSubview(loadAdd(tempModule.count, level: 0))
        } else if tempModule.count < 10 {
            stackView3.hidden = true
            thirdHeight.constant = 0
            for index in 0..<5 {
                stackView1.addSubview(loadLevel(index,level: 0))
            }
            for index in 5..<tempModule.count {
                stackView2.addSubview(loadLevel(index,level: 1))
            }
            stackView2.addSubview(loadAdd(tempModule.count, level: 1))
            //loadLevel1(5)
            //loadLevel2(tempModule.count)
        } else {
            for index in 0..<5 {
                stackView1.addSubview(loadLevel(index,level: 0))
            }
            for index in 5..<10 {
                stackView2.addSubview(loadLevel(index,level: 1))
            }
            for index in 10..<tempModule.count {
                stackView3.addSubview(loadLevel(index,level: 2))
            }
            stackView3.addSubview(loadAdd(tempModule.count, level: 2))
        }
        
    }
    
    func loadLevel(index: Int,level: Int) -> ItemView{
        let nib = NSBundle.mainBundle().loadNibNamed("ItemView", owner: self, options: nil)
        let view = nib[0] as! ItemView
        view.frame = CGRectMake(CGFloat(73 * (index - 5 * level)), 0.0, 73, 76)
        view.layer.cornerRadius = 5
        view.icon.setBackgroundImage(UIImage(named: "\(tempModule[index][0])"), forState: UIControlState.Normal)
        view.icon.setTitle("\(tempModule[index][1])", forState: UIControlState.Normal)
        view.icon.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        view.icon.titleEdgeInsets = UIEdgeInsetsMake(-10, -10, -80, -10)
        view.icon.titleLabel?.font = UIFont.systemFontOfSize(12)
        return view
    }
    
    func loadAdd(index: Int,level: Int) -> ItemView {
        let nib = NSBundle.mainBundle().loadNibNamed("ItemView", owner: self, options: nil)
        let view = nib[0] as! ItemView
        view.frame = CGRectMake(CGFloat(73 * (index - 5 * level)), 0.0, 73, 76)
        view.layer.cornerRadius = 5
        view.icon.setBackgroundImage(UIImage(named: "ic_add"), forState: UIControlState.Normal)
        view.icon.setTitle("模块管理", forState: UIControlState.Normal)
        view.icon.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        view.icon.titleEdgeInsets = UIEdgeInsetsMake(-10, -10, -80, -10)
        view.icon.titleLabel?.font = UIFont.systemFontOfSize(12)
        return view
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
