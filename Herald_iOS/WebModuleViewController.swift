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
        R.module.schedule : 0xe54f40,
        R.module.emptyroom : 0x3188cb,
        R.module.quanyi : 0xed7f0e
    ]
    
    @IBOutlet var webView : UIWebView!
    
    var url : String = ""
    
    override func viewDidLoad () {
        if let _url = NSURL(string: url) {
            webView.loadRequest(NSURLRequest(URL: _url))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        for (key, value) in webModuleColors {
            if url == key.controller {
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
        
        let prefix = "[分享自小猴偷米App] "
        let __title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        let _title = __title == nil ? "" : __title!
        let shareText = prefix + _title + " " + shareUrl
        
        let items : [AnyObject] = [shareText]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]
        presentViewController(vc, animated: true, completion: nil)
    }
}