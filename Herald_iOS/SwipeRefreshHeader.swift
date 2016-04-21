//
//  SwipeRefreshHeader.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/21.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

/// 一个简单的下拉刷新控件。使用该控件要注意以下几点（尤其最后四条）：
//- 0、本控件可以使用 contentView 设置子控件，也可以留空（只有下拉时才会出现）
//- 1、设置子控件时不要用 addSubView ，而是直接设置 contentView 成员
//- 2、父控件是 UIScrollView 或其子类，如 UITableView
//- 3、本控件要放在最顶部，例如可以作为 UITableView 的 tableHeaderView 使用
/// 4、将本控件添加到父控件前，要先设置 themeColor、refresher
/// 5、在父控件 scrollViewDidScroll 代理方法中要调用 syncApperance(_:)，参数是父控件的 contentOffset.y
/// 6、在父控件 scrollViewDidBeginDragging 代理方法中要调用 beginDrag()
/// 7、在父控件 scrollViewDidEndDragging 代理方法中要调用 endDrag()

class SwipeRefreshHeader : UIView {
    
    let fadeDistance : CGFloat = 150
    
    let refreshDistance : CGFloat = 80
    
    var contentView : UIView?
    
    let refresh = UILabel()
    
    var refresher : (() -> Void)?
    
    var themeColor : UIColor?
    
    var realHeight = CGFloat(0)
    
    override func didMoveToSuperview() {
        for k in subviews { k.removeFromSuperview() }
        
        realHeight = CGFloat(0)
        if contentView != nil {
            realHeight = contentView!.frame.height
            addSubview(contentView!)
        }
        self.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.width)!, height: realHeight)
        
        refresh.frame = self.frame
        refresh.textColor = UIColor.whiteColor()
        refresh.textAlignment = .Center
        refresh.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 54)
        refresh.backgroundColor = themeColor
        
        addSubview(refresh)
        syncApperance(CGPoint(x: 0, y: 0))
    }
    
    func syncApperance (contentOffset : CGPoint) {
        let x = contentOffset.x
        let y = contentOffset.y
        
        // 上滑变色动效
        var alpha : CGFloat = -y < fadeDistance ? (-y) / fadeDistance : 1;
        if frame.maxY == 0 { alpha = 1 }
        
        refresh.text = -y >= refreshDistance && dragging ? "[REFRESH]" : "REFRESH"
        refresh.alpha = alpha
        
        // 弹性放大动效
        refresh.frame = CGRect(x: x, y: min(y, 0), width: frame.width, height: frame.maxY - min(y, 0))
        contentView?.frame = CGRect(x: x, y: min(y, 0), width: frame.width, height: frame.maxY - min(y, 0))
    }
    
    var dragging = false
    
    func beginDrag () {
        dragging = true
    }
    
    func endDrag () {
        dragging = false
        guard let text = refresh.text else { return }
        if text == "[REFRESH]" {
            refresher?()
        }
    }
}