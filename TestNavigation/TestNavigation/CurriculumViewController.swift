//
//  CurriculumViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/4/2.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class CurriculumViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NSDate {
    func dayOfWeek() -> Int {
        let interval = self.timeIntervalSince1970;
        let days = Int(interval / 86400);
        return (days - 3) % 7;
    }
}