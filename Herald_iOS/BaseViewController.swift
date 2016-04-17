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
    
    override func viewDidLoad() {
        progressDialog = MBProgressHUD(view: view)
    }
    
    func showProgressDialog () {
        progressDialog?.show(true)
    }
    
    func hideProgressDialog () {
        progressDialog?.hide(true)
    }
}