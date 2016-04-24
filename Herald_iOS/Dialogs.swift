//
//  Dialogs.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class Dialogs {
    
    static var map : [UIViewController : Dialogs] = [:]
    
    var vc : UIViewController
    
    private init (_ vc : UIViewController) {
        self.vc = vc
    }
    
    static func getInstanceForVc (vc : UIViewController) -> Dialogs {
        if let dialog = map[vc] {
            return dialog
        } else {
            let newDialog = Dialogs(vc)
            map.updateValue(newDialog, forKey: vc)
            return newDialog
        }
    }
    
    var progressDialog : MBProgressHUD?
    
    var alertDialog : MBProgressHUD?
    
    func showProgressDialog () {
        hideProgressDialog()
        progressDialog = MBProgressHUD(view: vc.view)
        UIApplication.sharedApplication().delegate?.window!!.addSubview(progressDialog!)
        progressDialog?.show(true)
        progressDialog?.labelText = "请稍候…"
    }
    
    func hideProgressDialog () {
        progressDialog?.hide(true)
    }
    
    func showMessage (message : String) {
        alertDialog = MBProgressHUD(view: vc.view)
        UIApplication.sharedApplication().delegate?.window!!.addSubview(alertDialog!)
        alertDialog?.show(true)
        alertDialog?.labelText = message
        alertDialog?.mode = .Text
        alertDialog?.minShowTime = Float(message.characters.count / 10) + 1
        alertDialog?.hide(true)
    }
    
    func showQuestionDialog (message: String, runAfter: () -> Void) {
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
                (action: UIAlertAction) -> Void in runAfter()})
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in })
        vc.presentViewController(dialog, animated: true, completion: nil)
    }
    
    func showTipDialogIfUnknown (message: String, cachePostfix: String, runAfter: () -> Void) {
        let shown = CacheHelper.get("tip_ignored_" + cachePostfix) == "1"
        if !shown {
            let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
                (action: UIAlertAction) -> Void in runAfter()})
            dialog.addAction(UIAlertAction(title: "不再提示", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in
                CacheHelper.set("tip_ignored_" + cachePostfix, cacheValue: "1")
                runAfter()
                })
            vc.presentViewController(dialog, animated: true, completion: nil)
        } else {
            runAfter()
        }
    }
}