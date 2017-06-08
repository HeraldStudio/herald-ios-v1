import UIKit

/**
 * ShortcutBoxView | 快捷栏视图
 * 仅用于在 CardsTableView 中显示快捷栏。如要用作他用，请做修改
 */
class ShortcutBoxView : UIView {
    
    /// 最小列宽
    static let minCellWidth : CGFloat = 80
    
    /// 左右边距
    static let paddings : CGFloat = 15
    
    /// 行高
    static let cellHeight : CGFloat = 42
    
    /// 数据源，包括表示模块管理按钮的伪模块
    var dataSource : [AppModule] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 初始化完成后，载入数据
    override func didMoveToSuperview() {
        loadData()
        SettingsHelper.addModuleSettingsChangeListener {
            self.loadData()
        }
        ApiHelper.addUserChangedListener { 
            self.loadData()
        }
    }
    
    /// 重新载入数据
    func loadData() {
        
        /// 恢复初始状态
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        /// 初始化、调整布局属性
        // 获取已启用快捷方式的模块列表
        dataSource = Modules.filter { $0.shortcutEnabled }
        
        let width = AppDelegate.instance.leftController!.view.frame.width - ShortcutBoxView.paddings * 2
        
        // 根据尺寸计算列数；为了防止列宽大于屏幕造成除以零错误，限制最小列数为1
        let columnCount = max(1, Int(width / ShortcutBoxView.minCellWidth))
        
        // 根据总数和列数计算行数
        let rowCount = Int(ceil(Float(dataSource.count) / Float(columnCount)))
        
        // 根据行数计算高度
        let height = ShortcutBoxView.cellHeight * CGFloat(rowCount)
        
        // 设置高度
        frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: height)
        
        // 设置背景色
        backgroundColor = UIColor.white
        
        /// 布局各个快捷图标
        // 根据尺寸计算实际列宽
        let cellWidth = width / CGFloat(columnCount)
        
        for index in 0 ..< dataSource.count {
            
            // 计算图标位置
            let xPos = index % columnCount
            let yPos = index / columnCount
            let x = CGFloat(xPos) * cellWidth + ShortcutBoxView.paddings
            let y = CGFloat(yPos) * ShortcutBoxView.cellHeight
            
            // 得到图标区域
            let rect = CGRect(x: x, y: y, width: cellWidth, height: ShortcutBoxView.cellHeight)
            
            layoutCellAt(index, inRect: rect)
        }
        
        self.removeConstraints(constraints)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: height))
        self.updateConstraintsIfNeeded()
    }
    
    /// 布局单个图标
    func layoutCellAt(_ index : Int, inRect rect : CGRect) {
        let module = dataSource[index]
        
        let cell = UIViewController(nibName: "ShortcutBoxCell", bundle: nil)
        cell.view.frame = rect
        (cell.view as! ShortcutBoxCell).module = module
        
        addSubview(cell.view)
        
        let divider = UIView(frame: CGRect(x: rect.minX, y: rect.minY - 0.5, width: rect.width, height: 0.5))
        divider.backgroundColor = UIColor(white: 229/255, alpha: 1)
        addSubview(divider)
    }
}

/// 快捷栏图标
class ShortcutBoxCell : UIView {
    
    @IBOutlet var icon : UIImageView!
    
    @IBOutlet var title : UILabel!
    
    /// 当前图标代表的模块
    var _module : AppModule?
    
    var module : AppModule? {
        get {
            return _module
        }
        set {
            _module = newValue
            if let _module = _module {
                icon.image = UIImage(named: _module.invertIcon)
                title.text = _module.nameTip.split(" ")[0]
            }
        }
    }
    
    @IBAction func open() {
        _module?.open()
    }
}
