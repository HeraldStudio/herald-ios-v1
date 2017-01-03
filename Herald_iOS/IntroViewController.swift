//
//  IntroViewController.swift
//  Herald_iOS
//
//  Created by Vhyme on 2017/01/03.
//  Copyright © 2017年 HeraldStudio. All rights reserved.
//

import UIKit
import ZYBannerView

class IntroViewController : UIViewController, ZYBannerViewDataSource, ZYBannerViewDelegate {
    
    @IBOutlet var bannerView : ZYBannerView!
    
    override func viewDidLoad() {
        bannerView.showFooter = true
        bannerView.autoScroll = false
        bannerView.shouldLoop = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hideProgressDialog()
    }
    
    public func numberOfItems(inBanner banner: ZYBannerView!) -> Int {
        return 3
    }
    
    func banner(_ banner: ZYBannerView!, viewForItemAt index: Int) -> UIView! {
        let v = UIImageView(image: [#imageLiteral(resourceName: "intro-1"), #imageLiteral(resourceName: "intro-2"), #imageLiteral(resourceName: "intro-3")][index])
        v.contentMode = .scaleAspectFit
        return v
    }
    
    func banner(_ banner: ZYBannerView!, titleForFooterWith footerState: ZYBannerFooterState) -> String! {
        return "马上进入"
    }
    
    func bannerFooterDidTrigger(_ banner: ZYBannerView!) {
        dismiss(animated: true, completion: nil)
    }
}
