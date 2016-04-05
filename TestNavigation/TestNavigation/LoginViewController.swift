//
//  ViewController.swift
//  Herald
//
//  Created by Howie on 16/3/24.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func loginTapped(sender: AnyObject) {
        if (username.text!.isEmpty) {
            let ac = UIAlertController(title: nil, message: "不要调皮~~，请输入一卡通号", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        if (password.text!.isEmpty) {
            let ac = UIAlertController(title: nil, message: "也别忘了输入密码", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://115.28.27.150/uc/auth")!)
        request.HTTPMethod = "POST"
        let postString = "appid=9f9ce5c3605178daadc2d85ce9f8e064&password=\(password.text!)&user=\(username.text!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue()) { [] in
                if responseString!.hasPrefix("<html>") {
                    let ac = UIAlertController(title: nil, message: "Oops,账号密码错了", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Again", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                    return
                }
                else {
                    self.performSegueWithIdentifier("login", sender: self)
                }
            }
        }
        task.resume()
        
        //self.performSegueWithIdentifier("login", sender: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //username.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self
        password.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        //uuid = NSUUID().UUIDString/
        uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString.stringByReplacingOccurrencesOfString("-", withString: "").lowercaseString
        print(uuid)
        
        let userPaddingView = UIView(frame: CGRectMake(0, 0, 44, self.username.frame.height))
        self.username.leftView = userPaddingView
        self.username.leftViewMode = .Always
        
        let passPaddingView = UIView(frame: CGRectMake(0, 0, 44, self.password.frame.height))
        self.password.leftView = passPaddingView
        self.password.leftViewMode = .Always
        
        let userImageView = UIImageView(image: UIImage(named: "User"))
        userImageView.frame.origin = CGPoint(x: 13, y: 14)
        self.username.addSubview(userImageView)
        
        let passImageView = UIImageView(image: UIImage(named: "Key"))
        passImageView.frame.origin = CGPoint(x: 12, y: 14)
        self.password.addSubview(passImageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login"{
        }
    }
    
    
}

