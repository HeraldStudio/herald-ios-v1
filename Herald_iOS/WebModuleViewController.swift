//
//  WebModule.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class WebModuleViewController : UIViewController, UIWebViewDelegate, ForceTouchPreviewable {
    
    func webViewDidStartLoad(webView: UIWebView) {
        showProgressDialog()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        hideProgressDialog()
        refreshLeftBarItems()
    }
    
    let webModuleColors = [
        ModuleSchedule : 0xe54f40,
        ModuleEmptyRoom : 0x3188cb,
        ModuleQuanYi : 0xed7f0e
    ]
    
    @IBOutlet var webView : UIWebView!
    
    var url : String = ""
    
    override func viewDidLoad () {
        if let _url = NSURL(string: url) {
            // 若是检查更新的链接，直接用 App Store 打开并关闭 Webview
            if url == StringUpdateUrl {
                UIApplication.sharedApplication().openURL(_url)
                dismiss()
            } else {
                webView.loadRequest(NSURLRequest(URL: _url))
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        for (key, value) in webModuleColors {
            if url == key.destination {
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
        
        /// 各类分享对话框、ActionSheet等，展示前必须设置sourceView，否则在iPad上会导致崩溃
        vc.popoverPresentationController?.sourceView = self.view
        
        presentViewController(vc, animated: true, completion: nil)
    }
}