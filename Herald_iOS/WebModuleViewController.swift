//
//  WebModule.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class WebModuleViewController : BaseViewController {
    
    @IBOutlet var webView : UIWebView!
    
    override func viewDidLoad () {
        title = CacheHelper.getCache("herald_webmodule_title")
        webView.loadRequest(NSURLRequest(URL: NSURL(string: CacheHelper.getCache("herald_webmodule_url"))!))
    }
    
    @IBAction func refresh () {
        webView.reload()
    }
    
    @IBAction func back () {
        webView.goBack()
    }
    
    @IBAction func forward () {
        webView.goForward()
    }
}