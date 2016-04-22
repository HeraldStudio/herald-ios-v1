//
//  BaseViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/17.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class BaseViewController : UIViewController {
    
    var progressDialog : MBProgressHUD?
    
    var alertDialog : MBProgressHUD?
    
    func showProgressDialog () {
        hideProgressDialog()
        progressDialog = MBProgressHUD(view: view)
        UIApplication.sharedApplication().delegate?.window!!.addSubview(progressDialog!)
        progressDialog?.show(true)
        progressDialog?.labelText = "请稍候…"
    }
    
    func hideProgressDialog () {
        progressDialog?.hide(true)
    }
    
    func showMessage (message : String) {
        alertDialog = MBProgressHUD(view: view)
        UIApplication.sharedApplication().delegate?.window!!.addSubview(alertDialog!)
        alertDialog?.show(true)
        alertDialog?.labelText = message
        alertDialog?.mode = .Text
        alertDialog?.minShowTime = Float(message.characters.count / 10) + 1
        alertDialog?.hide(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        hideProgressDialog()
    }
    
    func showTipDialogIfUnknown (message: String, cachePostfix: String, runAfter: () -> Void) {
        let shown = CacheHelper.getCache("tip_ignored_" + cachePostfix) == "1"
        if !shown {
            let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
                (action: UIAlertAction) -> Void in runAfter()})
            dialog.addAction(UIAlertAction(title: "不再提示", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in
                CacheHelper.setCache("tip_ignored_" + cachePostfix, cacheValue: "1")
                runAfter()
            })
            presentViewController(dialog, animated: true, completion: nil)
        } else {
            runAfter()
        }
    }
}