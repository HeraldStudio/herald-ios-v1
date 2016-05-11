//
//  ActivityTableViewCell.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/5/11.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation
import UIKit

class ActivityTableViewCell : UITableViewCell {
    @IBOutlet var title : UILabel!
    @IBOutlet var assoc : UILabel!
    @IBOutlet var state : UILabel!
    @IBOutlet var pic : UIImageView!
    @IBOutlet var intro : UILabel!
    
    override func didMoveToSuperview() {
        backgroundView = UIImageView(image: UIImage(named: "activity_card_bg"))
        selectedBackgroundView = UIImageView(image: UIImage(named: "activity_card_bg_selected"))
    }
}