//
//  WebModule.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class WebModuleViewController : UIViewController, UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        showProgressDialog()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        hideProgressDialog()
    }
    
    let webModuleColors = [
        Module.Schedule : 0xe54f40,
        Module.GymReserve : 0x377ef4,
        Module.EmptyRoom : 0x3188cb,
        Module.Quanyi : 0xed7f0e
    ]
    
    @IBOutlet var webView : UIWebView!
    
    var url : String = ""
    
    override func viewDidLoad () {
        title = CacheHelper.get("herald_webmodule_title")
        url = CacheHelper.get("herald_webmodule_url")
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
    }
    
    override func viewWillAppear(animated: Bool) {
        for (key, value) in webModuleColors {
            if url == SettingsHelper.MODULES[key.rawValue].controller {
                setNavigationColor(nil, value)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        hideProgressDialog()
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
    
    @IBAction func share () {
        let _shareUrl = webView.stringByEvaluatingJavaScriptFromString("window.location.href")
        let shareUrl = _shareUrl == nil ? "" : _shareUrl!
        
        let module = (title == nil || title! == "小猴偷米") ? "" : " - \(title!)"
        let prefix = "来自小猴偷米App\(module)的分享："
        let __title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        let _title = __title == nil ? "" : __title!
        let shareText = prefix + _title + " " + shareUrl
        
        let items : [AnyObject] = [shareText]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]
        presentViewController(vc, animated: true, completion: nil)
    }
}