//
//  ModuleTableViewCell.swift
//  TestNavigation
//
//  Created by Howie on 16/3/29.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class ModuleTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var detail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
