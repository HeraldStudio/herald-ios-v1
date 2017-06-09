//
//  ExtUIView.swift
//  Herald_iOS
//
//  Created by Vhyme on 2017/1/14.
//  Copyright © 2017年 HeraldStudio. All rights reserved.
//

import UIKit

extension UIView {
    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
