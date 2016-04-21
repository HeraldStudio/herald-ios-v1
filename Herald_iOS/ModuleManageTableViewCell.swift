//
//  ModuleManageTableViewCell.swift
//  TestNavigation
//
//  Created by Howie on 16/3/29.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class ModuleManageTableViewCell: UITableViewCell {
    
    var module = 0
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cardSwitch: UISwitch!
    @IBOutlet weak var shortcutSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            if !cardSwitch.enabled {
                switchShortcut()
            }
        }
        // Configure the view for the selected state
    }
    
    @IBAction func switchShortcut () {
        let oldEnabled = SettingsHelper.getModuleShortcutEnabled(module)
        SettingsHelper.setModuleShortCutEnabled(module, enabled: !oldEnabled)
        shortcutSwitch.setOn(!oldEnabled, animated: true)
    }
    
    @IBAction func switchCard () {
        let oldEnabled = SettingsHelper.getModuleCardEnabled(module)
        SettingsHelper.setModuleCardEnabled(module, enabled: !oldEnabled)
        cardSwitch.setOn(!oldEnabled, animated: true)
    }
}
