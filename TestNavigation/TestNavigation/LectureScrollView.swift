//
//  CardChildScrollView.swift
//  TestNavigation
//
//  Created by Howie on 16/4/3.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class LectureScrollView: UIView {

    @IBOutlet weak var lectureTime: UILabel!
    @IBOutlet weak var lectureName: UILabel!
    @IBOutlet weak var lectureLocal: UILabel!
    @IBOutlet weak var lecturer: UILabel!
    
    var frameinit: CGRect!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.layer.cornerRadius = 5
        //layoutIfNeeded
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        frameinit = frame
    }
    
    
    override func drawRect(rect: CGRect) {
        
    }

}
