//
//  ModuleManageTableViewCell.swift
//  TestNavigation
//
//  Created by Howie on 16/3/29.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class ModuleManageTableViewCell: UITableViewCell {
    
    var module : AppModule?
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cardSwitch: UISwitch!
    @IBOutlet weak var shortcutSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            if !cardSwitch.isEnabled {
                switchShortcut()
            }
        }
        // Configure the view for the selected state
    }
    
    @IBAction func switchShortcut () {
        if module != nil {
            module!.shortcutEnabled = !(module!.shortcutEnabled)
            shortcutSwitch.setOn(module!.shortcutEnabled, animated: true)
        }
    }
    
    @IBAction func switchCard () {
        if module != nil {
            if !(module?.hasCard)! { return }
            module!.cardEnabled = !(module!.cardEnabled)
            cardSwitch.setOn(module!.cardEnabled, animated: true)
        }
    }
}
