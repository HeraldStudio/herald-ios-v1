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
        progressDialog = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressDialog?.labelText = "请稍候…"
    }
    
    func hideProgressDialog () {
        progressDialog?.hide(true)
    }
    
    func showMessage (message : String) {
        alertDialog = MBProgressHUD.showHUDAddedTo(view, animated: true)
        alertDialog?.labelText = message
        alertDialog?.mode = .Text
        alertDialog?.minShowTime = 2
        alertDialog?.hide(true)
    }
}