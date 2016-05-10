//
//  UIViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Toast_Swift

extension UIViewController {
    func showProgressDialog() {
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.show()
    }
    
    func hideProgressDialog() {
        SVProgressHUD.dismiss()
    }
    
    func showMessage(message : String) {
        if let vc = getTopViewController() {
            var style = ToastStyle()
            style.messageFont = UIFont.systemFontOfSize(14)
            style.horizontalPadding = 20
            style.verticalPadding = 10
            style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            ToastManager.shared.style = style
            let toastPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.maxY - 100)
            vc.view.makeToast(message, duration: 1, position: toastPoint)
        }
    }
    
    func showQuestionDialog (message: String, runAfter: () -> Void) {
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
            (action: UIAlertAction) -> Void in runAfter()})
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
            (action: UIAlertAction) -> Void in })
        getTopViewController()?.presentViewController(dialog, animated: true, completion: nil)
    }
    
    func showTipDialogIfUnknown (message: String, cachePostfix: String, runAfter: () -> Void) {
        let shown = CacheHelper.get("tip_ignored_" + cachePostfix) == "1"
        if !shown {
            let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
                (action: UIAlertAction) -> Void in runAfter()})
            dialog.addAction(UIAlertAction(title: "不再提示", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in
                CacheHelper.set("tip_ignored_" + cachePostfix, "1")
                runAfter()
                })
            getTopViewController()?.presentViewController(dialog, animated: true, completion: nil)
        } else {
            runAfter()
        }
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
    
    func getTopViewController() -> UIViewController? {
        let frontToBackWindows = UIApplication.sharedApplication().windows.reverse()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.mainScreen()
            let windowIsVisible = !window.hidden && window.alpha > 0
            let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
            
            if windowOnMainScreen && windowIsVisible && windowLevelNormal {
                if let frontToBackViewControllers = window.rootViewController?.childViewControllers.reverse() {
                    for vc in frontToBackViewControllers {
                        print(vc)
                        if vc.isViewLoaded() {
                            return vc
                        }
                    }
                    return nil
                } else {
                    return window.rootViewController
                }
            }
        }
        return nil
    }
}