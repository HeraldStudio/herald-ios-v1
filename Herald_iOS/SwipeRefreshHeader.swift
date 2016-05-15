import UIKit

/// 一个简单的下拉刷新控件。使用该控件要注意以下几点（尤其最后四条）：
//- 0、本控件可以使用 contentView 设置子控件，也可以留空（只有下拉时才会出现）
//- 1、设置子控件时不要用 addSubView ，而是直接设置 contentView 成员
//- 2、父控件是 UIScrollView 或其子类，如 UITableView
//- 3、本控件要放在最顶部，例如可以作为 UITableView 的 tableHeaderView 使用
//- 4、初始 contentOffset.y 必须为零，因此不能放在开启 translucent 属性的 UINavigationBar 下
/// 5、将本控件添加到父控件前，要先设置 themeColor、refresher
/// 6、在父控件 scrollViewDidScroll 代理方法中要调用 syncApperance(_:)，参数是父控件的 contentOffset
/// 7、在父控件 scrollViewDidBeginDragging 代理方法中要调用 beginDrag()
/// 8、在父控件 scrollViewDidEndDragging 代理方法中要调用 endDrag()

class SwipeRefreshHeader : UIView {
    
    /// 背景不透明度从0淡入到1的距离。若 contentView 留空，则始终不透明，不会淡入淡出
    let fadeDistance : CGFloat = 150
    
    /// 触发刷新的最小滑动距离
    let refreshDistance : CGFloat = 80
    
    /// 嵌入的子视图，若非空，则以它的高度作为下拉刷新控件的初始高度
    var contentView : UIView?
    
    /// 刷新提示文本
    let refresh = UILabel()
    
    /// 刷新触发的事件
    var refresher : (() -> Void)?
    
    /// 下拉刷新时淡入淡出的背景色
    var themeColor : UIColor?
    
    /// 下拉刷新控件没有拉伸时的原始高度
    var realHeight = CGFloat(0)
    
    /// 视图被展示时的操作
    override func didMoveToSuperview() {
        
        // 先移除所有子视图，以防万一
        for k in subviews { k.removeFromSuperview() }
        
        // 计算原始高度并添加子视图
        realHeight = CGFloat(0)
        if contentView != nil {
            realHeight = contentView!.frame.height
            addSubview(contentView!)
        }
        
        // 计算尺寸
        self.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.width)!, height: realHeight)
        
        // 添加刷新提示文字
        refresh.frame = self.frame
        refresh.textAlignment = .Center
        refresh.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 54)
        addSubview(refresh)
        
        // 首次重绘
        syncApperance()
    }
    
    /// 重绘
    func syncApperance () {
        let x = (superview! as! UIScrollView).contentOffset.x
        let y = (superview! as! UIScrollView).contentOffset.y
        
        // 设置背景色
        if themeColor != nil {
            refresh.backgroundColor = themeColor!
        }
        
        // 上滑变色动效
        let alpha : CGFloat = -y < fadeDistance ? (-y) / fadeDistance : 1;
        
        // 更新刷新提示文字内容
        refresh.text = -y >= refreshDistance && dragging ? "[REFRESH]" : "REFRESH"
        
        // 根据有无子视图，设置对应的颜色和透明度
        if frame.maxY == 0 {
            refresh.alpha = 1
            refresh.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: min(1, alpha * 3))
        } else {
            refresh.alpha = alpha
            refresh.textColor = UIColor.whiteColor()
        }
        
        // 弹性放大动效
        refresh.frame = CGRect(x: x, y: min(y, 0), width: frame.width, height: frame.maxY - min(y, 0))
        contentView?.frame = CGRect(x: x, y: min(y, 0), width: frame.width, height: frame.maxY - min(y, 0))
    }
    
    /// 记录是否正在拖动
    // 一开始的方案没有这个 dragging，也没有 beginDrag 函数，但是这导致了一个小问题，假如触发刷新的距离是100，
    // 在拉到90的位置时松手，保留一个向下的速度，则由于惯性，松手后还有可能超过100，导致闪现出[REFRESH]字样
    // 但没有触发刷新，造成视觉上的不一致。因此有了这个 dragging 变量，只有拖动的时候才会显示[REFRESH]，
    // 不拖动时即使距离超过了触发距离也只显示REFRESH。
    var dragging = false
    
    /// 记录拖动开始，需要在父视图代理中调用
    func beginDrag () {
        dragging = true
    }
    
    /// 记录拖动结束，需要在父视图代理中调用
    func endDrag () {
        dragging = false
        guard let text = refresh.text else { return }
        if text == "[REFRESH]" {
            refresher?()
        }
    }
}