//
//  LibraryBookModel.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/23.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation

class LibraryBookModel {
    var title : String
    var line1 : String
    var line2 : String
    var barcode : String
    var count : String
    
    init (_ title : String, _ line1 : String, _ line2 : String, _ barcode : String, _ count : String) {
        self.title = title
        self.line1 = line1
        self.line2 = line2
        self.barcode = barcode
        self.count = count
    }
}