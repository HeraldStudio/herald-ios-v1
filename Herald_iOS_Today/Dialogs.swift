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
    
    var progressDialogShown = false
    
    var alertDialog : MBProgressHUD?
    
    func showProgressDialog () {
        if progressDialogShown { return }
        progressDialogShown = true
        progressDialog = MBProgressHUD(view: vc.view)
        vc.view.addSubview(progressDialog!)
        progressDialog?.show(true)
        progressDialog?.labelText = "请稍候…"
    }
    
    func hideProgressDialog () {
        if !progressDialogShown { return }
        progressDialogShown = false
        progressDialog?.hide(true)
    }
    
    func showMessage (message : String) {
        // 先立即隐藏上一条消息
        alertDialog?.minShowTime = 0
        alertDialog?.hide(true)
        
        alertDialog = MBProgressHUD(view: vc.view)
        vc.view.addSubview(alertDialog!)
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
}