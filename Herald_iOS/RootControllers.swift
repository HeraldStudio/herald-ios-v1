import UIKit

/// 主页总框架
class MainGodViewController : UIViewController {
    
    var vc : UIViewController?
    
    override func viewDidAppear(animated: Bool) {
        let id = AppDelegate.isPad ? "MainSplitController" : "MainNavigationController"
        vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(id)
        super.presentViewController(vc!, animated: false) {}
    }
    
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        vc?.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
    }
}

/// 手机根布局导航框架
class MainNavigationController : UINavigationController {
    override func viewDidLoad() {
        AppDelegate.instance.leftController = self
        AppDelegate.instance.rightController = self
    }
}

/// 平板根布局分栏框架
class MainSplitController : UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        delegate = self
    }
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        if orientation == .Portrait || orientation == .PortraitUpsideDown {
            if vc == AppDelegate.instance.rightController {
                return true
            }
        }
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