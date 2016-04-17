//
//  ModuleManaTableViewCell.swift
//  TestNavigation
//
//  Created by Howie on 16/3/31.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

//对应模块选择页面跳转到管理的代理协议
@objc protocol TableViewControllerDelegate{
    func reloadData()
}

class ModuleManaTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var card: UISwitch!
    @IBOutlet weak var module: UISwitch!
    
    var cellNum: Int!
    //weak var delegate: TableViewControllerDelegate?
    /*override func drawRect(rect: CGRect) {
        switch cellNum {
        case 0,2,3,5,9,10:
            break
        default:
            self.card.hidden = true
        }
    }*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        card.addTarget(self, action: #selector(ModuleManaTableViewCell.didCardSwitch), forControlEvents: UIControlEvents.ValueChanged)
        module.addTarget(self, action: #selector(ModuleManaTableViewCell.didModuleSwitch), forControlEvents: UIControlEvents.ValueChanged)
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func didCardSwitch() {
        userModuleDict[cellNum][3] = card.on
        NEED_RELOAD_VIEW = true
        //self.delegate?.reloadData()
    }
    
    func didModuleSwitch() {
        userModuleDict[cellNum][2] = module.on
        NEED_RELOAD_VIEW = true
        //self.delegate?.reloadData()
    }

}
