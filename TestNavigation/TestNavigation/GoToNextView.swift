//
//  GoToNextView.swift
//  TestNavigation
//
//  Created by Howie on 16/4/2.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit
import Foundation

extension ViewController {
    func gotoView(destinaView: String){
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier(destinaView)
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
}