//
//  TopScrollViewController.swift
//  TestNavigation
//
//  Created by Howie on 16/3/30.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class TopScrollViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var pageControl: UIPageControl!
    var pageControl = UIPageControl()
    var timer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
        //scrollView.contentSize = CGSizeMake(750, 166)
        pageControl.frame = CGRectMake(320, 121, 39, 37)
        pageControl.numberOfPages = 2
        scrollView.addSubview(pageControl)
        addTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //print(scrollView.contentOffset.x)
        pageControl.frame = CGRectMake(320 + scrollView.contentOffset.x,pageControl.frame.origin.y,pageControl.frame.size.width,pageControl.frame.size.height)
        let page = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5)
        pageControl.currentPage = page
        //print(pageControl.frame)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        pageControl.frame = CGRectMake(320 + scrollView.contentOffset.x,pageControl.frame.origin.y,pageControl.frame.size.width,pageControl.frame.size.height)
        let page = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5)
        pageControl.currentPage = page
    }

    func nextImage(sender:AnyObject!){//图片轮播；
        var page:Int = self.pageControl.currentPage
        if(page == 1){   //循环；
            page = 0
        }else{
            page += 1
        }
        let x:CGFloat = CGFloat(page) * 375
        scrollView.scrollRectToVisible(CGRectMake(x, 0.0, 375, 166), animated: true)
    }
    
    func addTimer(){   //图片轮播的定时器；
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(TopScrollViewController.nextImage(_:)), userInfo: nil, repeats: true);
    }
    
    func detailTableViewDidScroll(detailTableView: UIScrollView) {
        //这里的代码是在detailTableView滚动后执行的操作，并不是执行detailTableView的代码；
        //这里只是为了设置下面的页码提示器；该操作是在图片滚动之后操作的；
        let detailTableViewW:CGFloat = detailTableView.frame.size.width
        let x:CGFloat = detailTableView.contentOffset.x
        let page:Int = (Int)((x + detailTableViewW / 2) / detailTableViewW)
        pageControl.currentPage = page
        
    }

}
