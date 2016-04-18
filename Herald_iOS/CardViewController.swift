//
//  CardViewController.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/18.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

class CardViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    override func viewDidLoad() {
        let cache = CacheHelper.getCache("herald_card")
        if cache != "" {
            loadCache()
        } else {
            //refreshCache()
        }
    }
    
    func loadCache() {
        let cache = CacheHelper.getCache("herald_card")
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("CardTableViewCell", forIndexPath: indexPath)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
}