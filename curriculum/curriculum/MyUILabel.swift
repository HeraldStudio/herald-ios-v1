//
//  UILabel.swift
//  curriculum
//
//  Created by 于海通 on 16/2/27.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import Foundation;
import UIKit;

class MyUILabel : UILabel {
    var info : String = "";
    var root : UIViewController?;
    func showInfo(){
        // 初始化对话框
        var dialog :UIAlertController;
        dialog = UIAlertController(title: "课程信息", message: info,
            preferredStyle: UIAlertControllerStyle.Alert);
        dialog.addAction(UIAlertAction(title: "确定", style: .Default, handler: {
            (action : UIAlertAction) -> Void in
        }));
        if(root != nil){
            root!.presentViewController(dialog, animated: true, completion: nil);
        }
    }
}