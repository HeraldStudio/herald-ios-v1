//
//  FeedbackViewControlelr.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/24.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewController : UIViewController {
    
    @IBOutlet var editor : UITextView!
    
    @IBOutlet var contact : UITextField!
    
    override func viewDidAppear(animated: Bool) {
        editor.becomeFirstResponder()
    }
    
    @IBAction func submit () {
        endEdit()
        
        let content = editor.text!
        let contact = self.contact.text!
        if content == "" {
            return
        }
        
        showProgressDialog()
        
        ApiSimpleRequest(checkJson200: true).url(ApiHelper.feedback_url)
            .post("cardnum", ApiHelper.getUserName())
            .post("content", "[来自iOS版] \(content) [联系方式：\(contact)]")
            .onResponse { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.showMessage("您的反馈已发送，感谢支持！")
                    self.editor.text = ""
                }
            }.run()
    }
    
    @IBAction func endEdit () {
        editor.resignFirstResponder()
        contact.resignFirstResponder()
    }
}