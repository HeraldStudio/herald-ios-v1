//
//  TodayAutoColorImageView.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/12/26.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import UIKit

class TodayAutoColorImageView : UIImageView {
    
    override var image: UIImage? {
        set {
            super.image = newValue?.withRenderingMode(.alwaysTemplate)
            if #available(iOSApplicationExtension 10.0, *) {
                tintColor = .darkGray
            } else {
                tintColor = .white
            }
        }
        get {
            if #available(iOSApplicationExtension 10.0, *) {
                tintColor = .darkGray
            } else {
                tintColor = .white
            }
            return super.image?.withRenderingMode(.alwaysTemplate)
        }
    }
}
