//
//  LibraryTableViewCell.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class LibraryTableViewCell : UITableViewCell {
    @IBOutlet var title : UILabel!
    @IBOutlet var line1 : UILabel!
    @IBOutlet var line2 : UILabel!
    @IBOutlet var renew : UIButton!
    @IBOutlet var count : UILabel!
    
    var barcode : String?
    
    @IBAction func renewBook () {
        renew.enabled = false
        renew.titleLabel?.text = "续借中.."
        ApiRequest().api("renew").uuid().post("barcode", barcode!).onFinish { success, _, _ in
            self.renew.titleLabel?.text = success ? "续借成功" : "续借失败"
            self.renew.enabled = !success
        }.run()
    }
}