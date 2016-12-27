//
//  TodayAutoColorLabel.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/12/26.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit

class TodayAutoColorLabel : UILabel {
    override func didMoveToSuperview() {
        if #available(iOSApplicationExtension 10.0, *) {
            textColor = .darkGray
        } else {
            textColor = .white
        }
    }
}
