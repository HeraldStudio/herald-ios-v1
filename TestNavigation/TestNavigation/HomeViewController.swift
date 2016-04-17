//
//  HomeViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/3/27.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

//let CFSLogoColorBlue = 0x00AAEE

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, al: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: al)
    }
    
    convenience init(netHex:Int, alpha: CGFloat) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, al: alpha)
    }
}

class HomeViewController: UINavigationController {

    //@IBOutlet weak var homeNavigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let backColor = UIColor(red: 67.0/255.0, green: 151.0/255.0, blue: 196.0/255.0, alpha: 1)
        // Do any additional setup after loading the view.
        homeNavigationBar.barTintColor = backColor
        homeNavigationBar.frame = CGRectMake(0.0, 20.0, 375.0, 200)
        
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(334, 12, 30, 30)
        button.tintColor = backColor
        button.setImage(UIImage(named: "ic_person"), forState: .Normal)
        homeNavigationBar.addSubview(button)
        
        let button1 = UIButton(type: .Custom)
        button1.frame = CGRectMake(280, 12, 33, 33)
        button1.tintColor = backColor
        //button.setTitle("OA办公", forState:UIControlState.Normal)
        button1.setImage(UIImage(named: "ic_view_module"), forState: .Normal)
        homeNavigationBar.addSubview(button1)
        
        let button2 = UIButton(type: .Custom)
        button2.frame = CGRectMake(229, 12, 30, 30)
        //button.setTitle("OA办公", forState:UIControlState.Normal)
        button2.setImage(UIImage(named: "ic_home"), forState: .Normal)
        homeNavigationBar.addSubview(button2)*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
