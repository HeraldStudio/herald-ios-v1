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
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        showProgressDialog()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
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
        if let _url = URL(string: url) {
            // 若是检查更新的链接，直接用 App Store 打开并关闭 Webview
            if url == StringUpdateUrl {
                UIApplication.shared.openURL(_url)
                _dismiss()
            } else {
                webView.loadRequest(URLRequest(url: _url))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for (key, value) in webModuleColors {
            if url == key.destination {
                setNavigationColor(value)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        hideProgressDialog()
    }
    
    func _dismiss () {
        navigationController?.popViewController(animated: true)
    }
    
    func refreshLeftBarItems () {
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self._dismiss)),
                UIBarButtonItem(title: "后退", style: .plain, target: self, action: #selector(self.back))
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
        
        let _shareUrl = webView.stringByEvaluatingJavaScript(from: "window.location.href")
        let shareUrl = _shareUrl == nil ? "" : _shareUrl!
        
        let prefix = "[分享自小猴偷米App] "
        let __title = webView.stringByEvaluatingJavaScript(from: "document.title")
        let _title = __title == nil ? "" : __title!
        let shareText = prefix + _title + " " + shareUrl
        
        ShareHelper.share(shareText)
    }
}
