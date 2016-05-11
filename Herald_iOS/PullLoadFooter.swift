//
//  SwipeRefreshHeader.swift
//  Herald_iOS
//
//  Created by 于海通 on 16/4/21.
//  Copyright © 2016年 于海通. All rights reserved.
//

import Foundation
import UIKit

/// 一个简单的上拉加载控件。使用该控件要注意以下几点（尤其最后四条）
//- 0、父控件是 UIScrollView 或其子类，如 UITableView
//- 1、本控件要放在最底部，例如可以作为 UITableView 的 tableFooterView 使用
/// 2、将本控件添加到父控件前，要先设置 loader
/// 3、在父控件 scrollViewDidScroll 代理方法中要调用 syncApperance(_:)，参数是父控件的 contentOffset.y
/// 4、在父控件 scrollViewDidBeginDragging 代理方法中要调用 beginDrag()
/// 5、在父控件 scrollViewDidEndDragging 代理方法中要调用 endDrag()

class PullLoadFooter : UIView {
    
    let fadeDistance : CGFloat = 150
    
    let loadDistance : CGFloat = 48
    
    var contentView : UIView?
    
    let load = UILabel()
    
    var loader : (() -> Void)?
    
    var realHeight = CGFloat(0)
    
    override func didMoveToSuperview() {
        for k in subviews { k.removeFromSuperview() }
        
        realHeight = self.frame.height
        self.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.width)!, height: realHeight)
        
        load.frame = self.frame
        load.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        load.textAlignment = .Center
        load.font = UIFont.systemFontOfSize(16)
        
        addSubview(load)
        syncApperance()
    }
    
    func syncApperance () {
        let topPadding = max(0, (superview?.frame.height)! - (superview! as! UIScrollView).contentSize.height)
        
        let height = max((superview?.frame.height)! + (superview! as! UIScrollView).contentOffset.y - (superview! as! UIScrollView).contentSize.height - topPadding, 0)
        if enabled {
            load.text = height >= loadDistance && dragging ? "松手加载" : "上拉加载"
        }
        
        load.alpha = min(height / realHeight, 1)
        load.frame = CGRect(x: 0, y: topPadding, width: frame.width, height: height)
    }
    
    var dragging = false
    
    func beginDrag () {
        dragging = true
    }
    
    func endDrag () {
        dragging = false
        guard let text = load.text else { return }
        if text == "松手加载" && enabled {
            loader?()
        }
    }
    
    var enabled = true
    
    func enable() {
        enabled = true
    }
    
    func disable(placeholder : String) {
        enabled = false
        load.text = placeholder
    }
}