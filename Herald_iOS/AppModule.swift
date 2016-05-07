//
//  AppModule.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/22.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class AppModule {
    var id : Int
    var name : String
    var nameTip : String
    var desc : String
    var controller : String
    var icon : String
    var hasCard : Bool
    
    init (id : Int, name : String, nameTip : String, desc : String,
          controller : String, icon : String, hasCard : Bool) {
        self.id = id
        self.name = name
        self.nameTip = nameTip
        self.desc = desc
        self.controller = controller
        self.icon = icon
        self.hasCard = hasCard
    }
    
    /// 创建一个基于webview的页面，注意这里url中必须含有http
    convenience init (title: String, url : String) {
        self.init (id: -1, name: "", nameTip: title, desc: "", controller: url, icon: "", hasCard: false)
    }
    
    func open (navigationController : UINavigationController?) {
        if controller == "" { return }
        if controller.containsString("http") {
            CacheHelper.set("herald_webmodule_title", nameTip)
            CacheHelper.set("herald_webmodule_url", controller)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(controller)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}