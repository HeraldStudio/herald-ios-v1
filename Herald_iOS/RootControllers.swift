import UIKit

/**
 * RootControllers | 各种根布局框架的库
 * 此处为了同时适应手机和平板，根布局比较多，具体从属关系请见 Main.storyboard 中的各个 scene 名称
 */
/// 手机根布局导航框架
class MainNavigationController : UINavigationController {
    
    /// UINavigationController 生命周期 viewDidLoad
    override func viewDidLoad() {
        
        // 注册为应用左侧vc
        AppDelegate.instance.leftController = self
        
        // 注册为应用右侧vc
        AppDelegate.instance.rightController = self
        
        // 注册为应用整体vc
        AppDelegate.instance.wholeController = self
    }
    
    /// UINavigationController 覆盖默认设置，只支持竖屏
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

/// 平板根布局分栏框架
class MainSplitController : UISplitViewController, UISplitViewControllerDelegate {
    
    /// UISplitViewController 生命周期
    override func viewDidLoad() {
        
        // 注册分栏布局代理
        delegate = self
        
        // 注册为应用整体vc
        AppDelegate.instance.wholeController = self
        
        // 微调中间分割线颜色
        view.backgroundColor = UIColor(white: 192/255, alpha: 1)
        
        // 设置左栏宽度。为了防止横竖屏切换时布局错位，此宽度直接写死，不允许自适应
        minimumPrimaryColumnWidth = 360
        maximumPrimaryColumnWidth = 360
    }
    
    /// UISplitViewController 覆盖默认设置，支持横屏和竖屏
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }
    
    /// UISplitViewControllerDelegate 永不隐藏左栏
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}

/// 平板左侧导航框架
class LeftNavigationController : UINavigationController {
    
    /// UINavigationController 生命周期
    override func viewDidLoad() {
        
        // 注册为应用左侧vc
        AppDelegate.instance.leftController = self
    }
}

/// 平板右侧导航框架
class RightNavigationController : UINavigationController {
    
    /// UINavigationController 生命周期
    override func viewDidLoad() {
        
        // 注册为应用右侧vc
        AppDelegate.instance.rightController = self
        
        // 去除导航栏下的横线
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBar.shadowImage = UIImage()
    }
}

/// 平板右侧首页
class RightMainController : UIViewController {
    
    /// UIViewController 生命周期
    override func viewWillAppear(animated: Bool) {
        
        // 设置导航栏颜色
        setNavigationColor(nil, 0x12b0ec)
    }
}