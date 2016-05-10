//
//  Dialogs.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import SVProgressHUD

class Dialogs {
    
    static func showProgressDialog () {
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.show()
    }
    
    static func hideProgressDialog () {
        SVProgressHUD.dismiss()
    }
    
    static func showMessage (vc : UIViewController, message : String) {
        var style = ToastStyle()
        style.messageFont = UIFont.systemFontOfSize(14)
        style.horizontalPadding = 20
        style.verticalPadding = 10
        style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        ToastManager.shared.style = style
        let toastPoint = CGPoint(x: vc.view.bounds.width / 2, y: vc.view.bounds.maxY - 100)
        vc.view.makeToast(message, duration: 1, position: toastPoint)
    }
    
    static func showQuestionDialog (vc : UIViewController, message: String, runAfter: () -> Void) {
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
                (action: UIAlertAction) -> Void in runAfter()})
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in })
        vc.presentViewController(dialog, animated: true, completion: nil)
    }
    
    static func showTipDialogIfUnknown (vc : UIViewController, message: String, cachePostfix: String, runAfter: () -> Void) {
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
            vc.presentViewController(dialog, animated: true, completion: nil)
        } else {
            runAfter()
        }
    }
}