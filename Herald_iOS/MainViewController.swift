//
//  MainViewController.swift
//  主界面分页滑动切换
//
//  Created by Howie on 16/3/27.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

var underLineView = UIView()

/// 主页面
class MainViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var controller = CardsViewController()
    var moduleVC = ModulesViewController()
    var personVC = MyInfoViewController()
    
    var frame = CGRect()
    var barHeight = CGFloat()
    var labelMonkey = UILabel()
    
    /// 启动时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barHeight = (self.navigationController?.navigationBar.frame.maxY)!
        frame = self.view.bounds
        
        setupScrollView()
        addViewForCards()
        addViewForModules()
        addViewForMyInfo()
        
        let detailTableViewW:CGFloat = scrollView.frame.size.width;
        let x:CGFloat = scrollView.contentOffset.x;
        let page:Int = (Int)((x + detailTableViewW / 2) / detailTableViewW);
        setupUnderline(page)
        
        for v in (navigationController?.navigationBar.subviews)! {
            for u in v.subviews {
                if u is UILabel && (u as! UILabel).text == "返回" {
                    u.alpha = 0
                }
            }
        }
    }
    
    /// 初始化水平分页视图
    func setupScrollView() {
        scrollView.backgroundColor = UIColor.whiteColor()
        
        frame = self.view.bounds
        scrollView.delegate = self
        scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        scrollView.contentSize=CGSizeMake(frame.size.width*CGFloat(3),frame.size.height - barHeight)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.contentOffset = CGPointZero
        scrollView.bounces = false
        self.view.addSubview(scrollView)
    }
    
    /// 添加卡片列表页
    func addViewForCards() {
        controller = storyboard?.instantiateViewControllerWithIdentifier("CardsViewController")
            as! CardsViewController
        controller.view.frame = CGRectMake(frame.size.width*CGFloat(0),0,
                                           frame.size.width,frame.size.height - barHeight)
        
        controller.parent = self
        scrollView.addSubview(controller.view)
    }
    
    /// 添加模块列表页
    func addViewForModules() {
        moduleVC = storyboard?.instantiateViewControllerWithIdentifier("ModulesViewController")
            as! ModulesViewController
        moduleVC.view.frame = CGRectMake(frame.size.width*CGFloat(1),0,
                                         frame.size.width,frame.size.height - barHeight)
        
        moduleVC.parent = self
        scrollView.addSubview(moduleVC.view)
    }
    
    /// 添加我的列表页
    func addViewForMyInfo() {
        personVC = storyboard?.instantiateViewControllerWithIdentifier("MyInfoViewController")
            as! MyInfoViewController
        personVC.view.frame = CGRectMake(frame.size.width*CGFloat(2),0,
                                         frame.size.width,frame.size.height - barHeight)
        
        personVC.parent = self
        scrollView.addSubview(personVC.view)
    }
    
    /// 卡片按钮点击事件
    @IBAction func cardsTapped(sender: AnyObject) {
        scrollView.scrollRectToVisible(CGRect(x: 0.0, y: 0.0,
            width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    
    /// 模块列表按钮点击事件
    @IBAction func modulesTapped(sender: AnyObject) {
        scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width, y: 0.0,
            width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    
    /// 我的按钮点击事件
    @IBAction func myInfoTapped(sender: AnyObject) {
        scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width * CGFloat(2), y: 0.0,
            width: self.view.frame.width, height: self.view.frame.height), animated: true)
    }
    
    /// 启动时，初始化页面标记线
    func setupUnderline(page: Int) {
        underLineView.frame = CGRectMake(CGFloat(53 * page), 41, 46, 2)
        underLineView.backgroundColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.addSubview(underLineView)
        underLineView.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 界面显示时，显示页面标记线
    override func viewWillAppear(animated: Bool) {
        underLineView.alpha = 1
    }
    
    /// 界面隐藏时，隐藏页面标记线
    override func viewWillDisappear(animated: Bool) {
        underLineView.alpha = 0
    }
    
    /// 滑动时移动页面标记线
    func scrollViewDidScroll(scrollView: UIScrollView) {
        underLineView.frame = CGRectMake(223 + scrollView.contentOffset.x * 0.1413, underLineView.frame.origin.y, underLineView.frame.width, underLineView.frame.height)
    }
}



