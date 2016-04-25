//
//  UIViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController {
    func showProgressDialog() {
        Dialogs.getInstanceForVc(self).showProgressDialog()
    }
    
    func hideProgressDialog() {
        Dialogs.getInstanceForVc(self).hideProgressDialog()
    }
    
    func showMessage(message : String) {
        Dialogs.getInstanceForVc(self).showMessage(message)
    }
    
    func showTipDialogIfUnknown (message: String, cachePostfix: String, runAfter: () -> Void) {
        Dialogs.getInstanceForVc(self).showTipDialogIfUnknown(message, cachePostfix: cachePostfix, runAfter: runAfter)
    }
    
    func showQuestionDialog (message: String, runAfter: () -> Void) {
        Dialogs.getInstanceForVc(self).showQuestionDialog(message, runAfter: runAfter)
    }
    
    func setNavigationColor (swiper: SwipeRefreshHeader?, _ color: Int) {
        var color = color
        let blue = CGFloat(color % 0x100) / 0xFF
        color /= 0x100
        let green = CGFloat(color % 0x100) / 0xFF
        color /= 0x100
        let red = CGFloat(color % 0x100) / 0xFF
        let _color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = _color
        swiper?.themeColor = _color
    }
}