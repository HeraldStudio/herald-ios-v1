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
        refreshLeftBarItems()
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
            // 若是检查更新的链接，直接用 App Store 打开并关闭 Webview
            if url == R.string.update_url {
                UIApplication.sharedApplication().openURL(_url)
                dismiss()
            } else {
                webView.loadRequest(NSURLRequest(URL: _url))
            }
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
    
    func dismiss () {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func refreshLeftBarItems () {
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(self.dismiss)),
                UIBarButtonItem(title: "后退", style: .Plain, target: self, action: #selector(self.back))
            ]
        } else {
            navigationItem.leftBarButtonItems = nil
        }
    }
    
    @IBAction func refresh () {
        webView.reload()
    }
    
    @IBAction func back () {
        webView.goBack()
        refreshLeftBarItems()
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