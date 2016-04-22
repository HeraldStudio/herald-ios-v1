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
    var shortcutEnabled = false
    var cardEnabled = false
    
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
    
    func open (navigationController : UINavigationController?) {
        if controller.containsString("http") {
            CacheHelper.setCache("herald_webmodule_title", cacheValue: nameTip)
            CacheHelper.setCache("herald_webmodule_url", cacheValue: controller)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(controller)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}