import UIKit

/// 手机根布局导航框架
class MainNavigationController : UINavigationController {
    
    /// 同时充当左右栏
    override func viewDidLoad() {
        AppDelegate.instance.leftController = self
        AppDelegate.instance.rightController = self
    }
    
    /// 覆盖默认设置，只支持竖屏
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

/// 平板根布局分栏框架
class MainSplitController : UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        delegate = self
        
        // 微调中间分割线颜色
        view.backgroundColor = UIColor(white: 192/255, alpha: 1)
        
        // 设置左栏宽度。为了防止横竖屏切换时布局错位，此宽度直接写死，不允许自适应
        minimumPrimaryColumnWidth = 360
        maximumPrimaryColumnWidth = 360
    }
    
    /// 覆盖默认设置，支持横屏和竖屏
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }
    
    /// 永不隐藏左栏
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}

/// 平板左侧导航框架
class LeftNavigationController : UINavigationController {
    override func viewDidLoad() {
        AppDelegate.instance.leftController = self
    }
}

/// 平板右侧导航框架
class RightNavigationController : UINavigationController {
    override func viewDidLoad() {
        AppDelegate.instance.rightController = self
        
        // 去除导航栏下的横线
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBar.shadowImage = UIImage()
    }
}

/// 平板右侧首页
class RightMainController : UIViewController {
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x00b4ff)
    }
}