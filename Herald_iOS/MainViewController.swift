import UIKit
import DHCShakeNotifier

/**
 * MainViewController | 应用程序主界面
 * 负责处理全局UI初始化等处理
 *
 * 注意：此 ViewController 不是程序主入口要直接打开的，直接打开的是它的父 ViewController 
 *      即 UINavigationController。之所以重写这个 UITabBarController 而不重写
 *      UINavigationController 是为了便于控制 TabBar。
 */
class MainViewController: UITabBarController {
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 去除界面切换时导航栏的黑影
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        
        // 去除导航栏下的横线
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 去除 TabBar 上的横线
        tabBar.clipsToBounds = true
        
        // 修改 TabBar 高亮图标的颜色
        tabBar.tintColor = UIColor(red: 0, green: 180/255, blue: 255/255, alpha: 1)
        
        if ApiHelper.isLogin() {
            // 注册摇一摇事件
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onShake), name: DHCSHakeNotificationName, object: nil)
        }
    }
    
    /// 当准备从其它界面返回时，设置导航栏颜色
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x00b4ff)
    }
    
    /// 响应摇一摇事件
    func onShake () {
        if SettingsHelper.getWifiAutoLogin() {
            WifiLoginHelper(self).checkAndLogin()
        }
    }
    
    /// 反注册摇一摇事件
    override func finalize() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DHCSHakeNotificationName, object: nil)
    }
}