import UIKit

/**
 * AppDelegate | 应用程序主入口
 * 负责整个应用程序的全局属性设置和全局事件处理
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// 应用程序的主显示窗口
    var window: UIWindow?
    
    /// 一个 NavigationController 的引用，
    /// 手机模式下是指 MainNavigationController，平板模式下是指 LeftNavigationController
    /// 当需要推入一个适合放在平板左侧的界面时，使用此引用
    var leftController: UINavigationController!
    
    /// 一个 NavigationController 的引用，
    /// 手机模式下是 MainNavigationController，平板模式下是 RightNavigationController
    /// 当需要推入一个适合放在平板右侧的界面时，使用此引用
    var rightController: UINavigationController!
    
    /// 一个 ViewController 的引用，
    /// 手机模式下是 MainNavigationController，平板模式下是 MainSplitController
    /// 当需要在整个窗口的根视图上展示物件时，使用此引用
    var wholeController: UIViewController!
    
    /// 对获取AppDelegate单例的语句进行简化
    static var instance : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    /// UIApplicationDelegate 无参数的启动结束事件，似乎不会触发
    func applicationDidFinishLaunching(_ application: UIApplication) {}
    
    /// UIApplicationDelegate 带参数的启动结束事件
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 设置主屏幕图标 3D Touch 菜单
        if #available(iOS 9.0, *) {
            
            // 考试助手菜单
            let test1 = UIApplicationShortcutItem.init(type: "wifi", localizedTitle: "登录校园网", localizedSubtitle: "一键登录，快人一步！", icon: UIApplicationShortcutIcon.init(templateImageName: "ic_seunet_invert"), userInfo: nil)
            
            // 课表助手菜单
            let test2 = UIApplicationShortcutItem.init(type: "curriculum", localizedTitle: "课表助手", localizedSubtitle: "快速查看课程安排", icon: UIApplicationShortcutIcon.init(templateImageName: "ic_curriculum_invert"), userInfo: nil)
            
            // 一卡通充值菜单
            let test3 = UIApplicationShortcutItem.init(type: "card", localizedTitle: "一卡通充值", localizedSubtitle: "一卡通没钱了？点我充值", icon: UIApplicationShortcutIcon.init(templateImageName: "ic_card_invert"), userInfo: nil)
            
            application.shortcutItems = [test1,test2,test3]
        }
        
        // 设置应用通知选项
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        // 初始化并显示主界面
        let id = AppDelegate.isPad ? "MainSplitController" : "MainNavigationController"
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id)
        
        return true
    }
    
    /// UIApplicationDelegate 在应用结束时安排通知
    func applicationWillTerminate(_ application: UIApplication) {
        reloadNotifications()
    }
    
    /// UIApplicationDelegate 在转到后台时安排通知
    func applicationDidEnterBackground(_ application: UIApplication) {
        reloadNotifications()
    }
    
    /// 加载并安排应用通知
    func reloadNotifications() {
        
        // 先清除旧的通知
        UIApplication.shared.cancelAllLocalNotifications()
        
        // 加载课表通知
        if SettingsHelper.curriculumNotificationEnabled {
            CurriculumNotifier.scheduleNotifications()
        }
        
        // 加载实验通知
        if SettingsHelper.experimentNotificationEnabled {
            ExperimentNotifier.scheduleNotifications()
        }
        
        // 加载考试通知
        if SettingsHelper.examNotificationEnabled {
            ExamNotifier.scheduleNotifications()
        }
    }
    
    /// UIApplicationDelegate 清空图标徽标数字
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// UIApplicationDelegate 处理主屏幕图标 3D Touch 菜单点击事件
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        // 获取目标界面
        switch shortcutItem.type {
        case "wifi":
            WifiLoginHelper(wholeController).checkAndLogin()
        case "curriculum":
            ModuleCurriculum.open()
        case "card":
            AppModule(title: "一卡通充值", url: "http://58.192.115.47:8088/wechat-web/login/initlogin.html").open()
        default:
            return
        }
    }
    
    /// 显示登录界面
    static func showLogin () {
        // 首先关闭所有上层界面，回到主界面
        instance.leftController.popToRootViewController(animated: true)
        instance.rightController.popToRootViewController(animated: true)
        
        // 打开登录页，如果是平板，优先在右侧打开
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        AppDelegate.instance.wholeController.present(vc, animated: true, completion: nil)
    }
    
    /// 检测当前环境是否iPad
    static var isPad : Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
}

