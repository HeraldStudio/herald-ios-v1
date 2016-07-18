import UIKit

/**
 * ShortcutBoxView | 快捷栏视图
 * 仅用于在 CardsTableView 中显示快捷栏。如要用作他用，请做修改
 */
class ShortcutBoxView : UIView {
    
    /// 最小列宽
    static let minCellWidth : CGFloat = 64
    
    /// 行高
    static let cellHeight : CGFloat = 86
    
    /// 数据源，包括表示模块管理按钮的伪模块
    var dataSource : [AppModule] = []
    
    /// 初始化完成后，载入数据
    override func didMoveToSuperview() {
        loadData()
        SettingsHelper.addModuleSettingsChangeListener {
            self.loadData()
        }
    }
    
    /// 预计算高度，因为 TableView 是先取得 cell 高度再布局各个 cell 的
    /// 所以需要在 tableView(_:heightForRowAtIndexPath:) 中提前调用此方法得知快捷栏高度
    static func precalculateHeight() -> CGFloat {
        
        // 此处假定在 iPad 端快捷栏始终显示在左侧栏
        let width = AppDelegate.instance.leftController.view.frame.width
        
        // 获取已启用快捷方式的模块列表
        let dataSource = R.module.array.filter { $0.shortcutEnabled } + [R.module.moduleManager]
        
        // 根据尺寸计算列数
        let columnCount = Int(width / minCellWidth)
        
        // 根据总数和列数计算行数
        let rowCount = Int(ceil(Float(dataSource.count) / Float(columnCount)))
        
        // 根据行数计算高度
        return cellHeight * CGFloat(rowCount)
    }
    
    /// 重新载入数据
    func loadData() {
        
        /// 恢复初始状态
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        /// 初始化、调整布局属性
        // 获取已启用快捷方式的模块列表
        dataSource = R.module.array.filter { $0.shortcutEnabled } + [R.module.moduleManager]
        
        let width = AppDelegate.instance.leftController.view.frame.width
        
        // 根据尺寸计算列数
        let columnCount = Int(width / ShortcutBoxView.minCellWidth)
        
        // 根据总数和列数计算行数
        let rowCount = Int(ceil(Float(dataSource.count) / Float(columnCount)))
        
        // 根据行数计算高度
        let height = ShortcutBoxView.cellHeight * CGFloat(rowCount)
        
        // 设置高度
        frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: height)
        
        // 设置背景色
        backgroundColor = UIColor.whiteColor()
        
        /// 布局各个快捷图标
        // 根据尺寸计算实际列宽
        let cellWidth = width / CGFloat(columnCount)
        
        for index in 0 ..< dataSource.count {
            
            // 计算图标位置
            let xPos = index % columnCount
            let yPos = index / columnCount
            let x = CGFloat(xPos) * cellWidth
            let y = CGFloat(yPos) * ShortcutBoxView.cellHeight
            
            // 得到图标区域
            let rect = CGRect(x: x, y: y, width: cellWidth, height: ShortcutBoxView.cellHeight)
            
            let cell = layoutCellAt(index, inRect: rect)
            
            cell.backgroundColor = ((xPos + yPos) % 2 == 0) ? UIColor(white: 248/255, alpha: 1) : UIColor.whiteColor()
        }
    }
    
    /// 布局单个图标
    func layoutCellAt(index : Int, inRect rect : CGRect) -> ShortcutBoxCell {
        let module = dataSource[index]
        
        let cell = ShortcutBoxCell(frame: rect, module: module)
        
        addSubview(cell)
        
        return cell
    }
}

/// 快捷栏图标
class ShortcutBoxCell : UIView {
    
    /// 图标尺寸
    let iconSize : CGFloat = 42
    
    /// 字体大小
    let fontSize : CGFloat = 12
    
    /// 小红点大小
    let notifyDotSize : CGFloat = 12
    
    /// 当前图标代表的模块
    var module : AppModule
    
    /// 拒绝遵守反序列化协议
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 使用显示区域和模块对象构造一个图标
    init(frame : CGRect, module : AppModule) {
        self.module = module
        super.init(frame: frame)
    }
    
    /// 初始化完成后，显示该图标
    override func didMoveToSuperview() {
        
        /// 首先进行必要的前置计算
        // 去除图标和文字以外的剩余空间总高度
        let totalSpace = frame.height - iconSize - fontSize
        
        // 图标和文字之间的距离
        let middlePadding = totalSpace * 1 / 4
        
        // 图标上方、文字下方到边缘的距离
        let outerPadding = (totalSpace - middlePadding) / 2
        
        // 图标左右两边到边缘的距离
        let iconSidePadding = (frame.width - iconSize) / 2
        
        /// 初始化并放置图片视图
        // 图标视图
        let icon = UIImageView(image: UIImage(named: module.icon))
        
        // 设置图标显示区域
        icon.frame = CGRect(x: iconSidePadding, y: outerPadding, width: iconSize, height: iconSize)
        
        // 放置图标
        addSubview(icon)
        
        /// 初始化并放置文字标签
        let label = UILabel()
        
        // 设置文字内容
        label.text = module.nameTip.split(" ")[0]
        
        // 设置文字字体
        label.font = UIFont.systemFontOfSize(fontSize)
        
        // 设置文字颜色
        label.textColor = UIColor(white: 0.4, alpha: 1)
        
        // 设置文字对齐
        label.textAlignment = .Center
        
        // 设置文字显示区域
        label.frame = CGRect(x: 0, y: outerPadding + iconSize + middlePadding, width: frame.width, height: fontSize)
        
        // 放置文字
        addSubview(label)
        
        /// 初始化并放置小红点
        if module.hasUpdates {
            
            // 计算位置
            let notifyDotX = iconSidePadding + iconSize - notifyDotSize
            let notifyDotY = outerPadding
            
            // 初始化小红点控件
            let notifyDot = UIImageView(image: UIImage(named: "notify_dot"))
            
            // 设置小红点显示区域
            notifyDot.frame = CGRect(x: notifyDotX, y: notifyDotY, width: notifyDotSize, height: notifyDotSize)
            
            // 放置小红点
            addSubview(notifyDot)
        }
        
        /// 设置点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.launch))
        addGestureRecognizer(tapGesture)
        
        /// 设置长按事件（模块管理按钮不设置）
        if module == R.module.moduleManager {
            return
        }
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.askToDelete))
        addGestureRecognizer(longGesture)
    }
    
    /// 打开该模块
    func launch() {
        if module.hasUpdates {
            module.hasUpdates = false
        }
        module.open()
    }
    
    /// 询问删除快捷方式
    func askToDelete() {
        AppDelegate.instance.leftController.showQuestionDialog("确定移除此模块的快捷方式吗？") {
            self.module.shortcutEnabled = false
        }
    }
}
