//
//  ViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/3/27.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

var underLineView = UIView()



//主页面
class ViewController: UIViewController, UIScrollViewDelegate {

    var scrollView = UIScrollView()
    var controller = DetailViewController()
    var moduleVC = ModuleViewController()
    var personVC = PersonViewController()
    var monkey = MonkeyGet()
    
    var frame = CGRect()
    var barHeight = CGFloat()
    var labelMonkey = UILabel()

    //var childPage = DetailPage()
    
    //navigationbar页面按钮
    @IBAction func homeTapped(sender: AnyObject) {
        scrollView.scrollRectToVisible(CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    @IBAction func moduleTapped(sender: AnyObject) {
        scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width, y: 0.0, width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    @IBAction func personTappde(sender: AnyObject) {
        scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width * CGFloat(2), y: 0.0, width: self.view.frame.width, height: self.view.frame.height), animated: true)
        //underLineView = UIView(frame: CGRectMake(220, 40,45, 2))
    }
    
    //设置页面标记线
    override func viewWillAppear(animated: Bool) {
        let detailTableViewW:CGFloat = scrollView.frame.size.width;
        let x:CGFloat = scrollView.contentOffset.x;
        let page:Int = (Int)((x + detailTableViewW / 2) / detailTableViewW);
        setupUnderline(page)
        
        reloadDetailVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.sharedApplication().statusBarFrame.height
        frame = self.view.bounds
        
        //self.monkey.monkeyAPI(.user){(dictget,error) -> Void in
        
        
        scrollviewSetup()
        setupDetailVC()
        setupModuleVC()
        setupPersonVC()
        
        
        /*dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            self.monkey.monkeyAPI(.card){(dictget,error) -> Void in
                dispatch_async(dispatch_get_main_queue()) { [] in
                    self.reloadDetailVC()
                }
            }
        }*/
    }
    
    func setupModuleVC() {
        moduleVC = storyboard?.instantiateViewControllerWithIdentifier("moduleViewController") as! ModuleViewController
        moduleVC.view.frame = CGRectMake(frame.size.width*CGFloat(1),barHeight,frame.size.width,frame.size.height - barHeight)
        
        let topManager = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 80))
        topManager.backgroundColor = UIColor.whiteColor()
        let img = UIImageView(image: UIImage(named: "ic_menu_manage"))
        img.frame = CGRectMake(16, 26, 25, 25)
        topManager.addSubview(img)
        
        let label = UILabel(frame: CGRect(x: 156, y: 26, width: 64, height: 22))
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.text = "模块管理"
        topManager.addSubview(label)
        
        moduleVC.moduleTableView.tableHeaderView = topManager
        
        moduleVC.tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(_:)))
        moduleVC.moduleTableView.tableHeaderView!.addGestureRecognizer(moduleVC.tapGestureRecogniser)
        
        scrollView.addSubview(moduleVC.view)
    }
    
    internal func didTap(recognizer:UITapGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Ended
        {
            let moduleVC = storyboard?.instantiateViewControllerWithIdentifier("moduleManagerViewController") as! ModuleManagerViewController
            //moduleVC.delegate = self
            navigationController?.pushViewController(moduleVC, animated: true)
        }
    }
    
    func setupDetailVC() {
        /*if controller.horizonScrollView != nil {
            controller.horizonScrollView.removeFromSuperview()
        }*/
        controller = storyboard?.instantiateViewControllerWithIdentifier("detailViewController") as! DetailViewController
        //controller.view.frame = self.view.bounds
        controller.view.frame = CGRectMake(frame.size.width*CGFloat(0),barHeight,frame.size.width,frame.size.height - barHeight)
        scrollView.addSubview(controller.view)
    }
    
    func setupPersonVC() {
        personVC = storyboard?.instantiateViewControllerWithIdentifier("personViewController") as! PersonViewController
        //controller.view.frame = self.view.bounds
        personVC.view.frame = CGRectMake(frame.size.width*CGFloat(2),barHeight,frame.size.width,frame.size.height - barHeight)
        scrollView.addSubview(personVC.view)
    }
    
    func scrollviewSetup() {
        scrollView.backgroundColor = UIColor.clearColor()
        let img = UIImageView(image: UIImage(named: "blur"))
        img.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        
        frame = self.view.bounds
        scrollView.delegate = self
        scrollView.frame = self.view.bounds
        scrollView.contentSize=CGSizeMake(frame.size.width*CGFloat(3),frame.size.height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.contentOffset = CGPointZero
        self.view.addSubview(scrollView)
        self.view.insertSubview(img, belowSubview: scrollView)
    }
    
    func setupUnderline(page: Int) {
        //let underLineViewX:CGFloat = (homeNavigationBar.frame.size.width - 4)
        underLineView .frame = CGRectMake(220 + CGFloat(53 * page), 40, 45, 2)
        underLineView.backgroundColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.addSubview(underLineView)
        underLineView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        underLineView.frame = CGRectMake(220 + scrollView.contentOffset.x * 0.1413, underLineView.frame.origin.y, underLineView.frame.width, underLineView.frame.height)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        underLineView.frame = CGRectMake(220 + scrollView.contentOffset.x * 0.1413, underLineView.frame.origin.y, underLineView.frame.width, underLineView.frame.height)
    }
    
    func gotoModuleManagerView() {
        //self.performSegueWithIdentifier("moduleMana", sender: nil)
        let moduleVC = ModuleManagerViewController()
        //moduleVC = storyboard?.instantiateViewControllerWithIdentifier("moduleManagerViewController") as! ModuleManagerViewController
        self.navigationController?.pushViewController(moduleVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDetailVC() {
        if NEED_RELOAD_VIEW {
            controller.horizonScrollView.removeFromSuperview()
            setupDetailVC()
        }
    }
    
    @IBAction func centerButtonBeTapped(sender: AnyObject) {
        let vcname = sender.titleLabel?!.text
        if let desVC = dicVC[vcname!] {
            gotoView(desVC)
        }
    }
}



