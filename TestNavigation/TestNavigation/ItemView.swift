//
//  ItemView.swift
//  TestNavigation
//
//  Created by Howie on 16/3/31.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class ItemView: UIView {
    @IBOutlet weak var icon: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.layer.cornerRadius = 5
    }
    
    func tapped() {
        print("tapped")
    }
    override func drawRect(rect: CGRect) {
        //icon.addTarget(self, action: #selector(ItemView.tapped), forControlEvents: UIControlEvents.TouchUpInside)
    }
}
