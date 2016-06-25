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
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // 若没打开过新版弹出菜单，提示用户弹出菜单更新了
        if SettingsHelper.get("popmenu_intro") != "0" {
            showPopupMenuIntro()
        }
    }
    
    /// 显示介绍新版弹出菜单的提示
    @IBAction func showPopupMenuIntro () {
        
        let menuArray = [
            KxMenuItem("不再需要摇一摇了，试试新版加号菜单吧", image: UIImage(), target: self, action: #selector(self.showPopupMenu))
        ]
        
        // 设置菜单箭头指向的区域
        let rect = CGRect(x: view.frame.width - 49, y: 0, width: 49, height: 0)
        
        // 设置菜单内容字体
        KxMenu.setTitleFont(UIFont(name: "HelveticaNeue", size: 14))
        
        KxMenu.showMenuInView(view, fromRect: rect, menuItems: menuArray, withOptions: OptionalConfiguration(
            arrowSize: 9,
            marginXSpacing: 7,
            marginYSpacing: 7,
            intervalSpacing: 15,
            menuCornerRadius: 4,
            maskToBackground: true,
            shadowOfMenu: false,
            hasSeperatorLine: true,
            seperatorLineHasInsets: false,
            textColor: Color(R: 0.2, G: 0.2, B: 0.2),
            menuBackgroundColor: Color(R: 1, G: 1, B: 1)
            ))
    }
    
    /// 显示右上角弹出菜单
    @IBAction func showPopupMenu () {
        
        // 用户已打开了弹出菜单，不再提示弹出菜单更新
        SettingsHelper.set("popmenu_intro", "0")
        
        // 要添加菜单项，直接在此列表添加元素，并指向所需的函数即可
        let menuArray = [
            KxMenuItem("登录校园网", image: UIImage(named: "action_wifi"), target: self, action: #selector(self.loginToWifi)),
            KxMenuItem("一卡通充值", image: UIImage(named: "action_charge"), target: self, action: #selector(self.cardCharge)),
            KxMenuItem("添加考试", image: UIImage(named: "action_add_exam"), target: self, action: #selector(self.customExam)),
            KxMenuItem("模块管理", image: UIImage(named: "action_module_manage"), target: self, action: #selector(self.moduleManage))
        ]
        
        // 设置菜单箭头指向的区域
        let rect = CGRect(x: view.frame.width - 49, y: (navigationController?.navigationBar.frame.maxY)!, width: 49, height: 0)
        
        // 设置菜单内容字体
        KxMenu.setTitleFont(UIFont(name: "HelveticaNeue", size: 14))
        
        // 这里要选择 navigationController 父视图作为宿主，否则将无法覆盖标题栏，导致再次点击加号按钮无法收起菜单
        KxMenu.showMenuInView(navigationController?.view, fromRect: rect, menuItems: menuArray, withOptions: OptionalConfiguration(
            arrowSize: 9,
            marginXSpacing: 7,
            marginYSpacing: 8,
            intervalSpacing: 20,
            menuCornerRadius: 4,
            maskToBackground: true,
            shadowOfMenu: false,
            hasSeperatorLine: true,
            seperatorLineHasInsets: false,
            textColor: Color(R: 0.2, G: 0.2, B: 0.2),
            menuBackgroundColor: Color(R: 1, G: 1, B: 1)
            ))
    }
    
    /// 弹出菜单操作：登录校园网
    func loginToWifi () {
        WifiLoginHelper(self).checkAndLogin()
    }
    
    /// 弹出菜单操作：一卡通充值
    func cardCharge () {
        
        // 此函数与 CardViewController 中 goToChargePage 操作一致，若要修改文案，请在两边同时修改
        // 此对话框也与上述函数中的对话框共用缓存键名，只要忽略其中任意一个，两个对话框都不会再显示
        showTipDialogIfUnknown("注意：充值之后需要在食堂刷卡机上刷卡，充值金额才能到账哦", cachePostfix: "card_charge") {
            () -> Void in
            AppModule(title: "一卡通充值", url: CardViewController.url).open(self.navigationController)
        }
    }
    
    /// 弹出菜单操作：添加考试
    func customExam () {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("MODULE_CUSTOM_EXAM") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 弹出菜单操作：模块管理
    func moduleManage () {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("MODULE_MANAGER") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}