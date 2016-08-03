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
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    /// 无参数的启动结束事件，似乎不会触发
    func applicationDidFinishLaunching(application: UIApplication) {}
    
    /// 带参数的启动结束事件
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /// 设置主屏幕图标 3D Touch 菜单
        /// TODO 考虑去掉考试助手和课表助手入口，换成其它的
        if #available(iOS 9.0, *) {
            // 考试助手菜单
            let test1 = UIApplicationShortcutItem.init(type: "exam", localizedTitle: "考试助手", localizedSubtitle: "", icon: UIApplicationShortcutIcon.init(templateImageName: "pre_exam"), userInfo: nil)
            
            // 课表助手菜单
            let test2 = UIApplicationShortcutItem.init(type: "curriculum", localizedTitle: "课表助手", localizedSubtitle: "", icon: UIApplicationShortcutIcon.init(templateImageName: "pre_curriculum"), userInfo: nil)
            
            // 一卡通充值菜单
            let test3 = UIApplicationShortcutItem.init(type: "card", localizedTitle: "一卡通充值", localizedSubtitle: "", icon: UIApplicationShortcutIcon.init(templateImageName: "pre_card"), userInfo: nil)
            
            application.shortcutItems = [test1,test2,test3]
        }
        
        /// 设置应用通知选项
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        /// 初始化并显示主界面
        let id = AppDelegate.isPad ? "MainSplitController" : "MainNavigationController"
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(id)
        
        return true
    }
    
    /// 在应用结束或转到后台时安排通知
    func applicationWillTerminate(application: UIApplication) {
        reloadNotifications()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        reloadNotifications()
    }
    
    /// 加载并安排应用通知
    func reloadNotifications() {
        
        // 先清除旧的通知
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
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
    
    /// 清空图标徽标数字
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    /// 处理主屏幕图标 3D Touch 菜单点击事件
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        // 获取目标界面
        switch shortcutItem.type {
        case "exam":
            ModuleExam.open()
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
        instance.leftController.popToRootViewControllerAnimated(true)
        instance.rightController.popToRootViewControllerAnimated(true)
        
        // 打开登录页，如果是平板，优先在右侧打开
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        AppDelegate.instance.wholeController.presentViewController(vc, animated: true, completion: nil)
    }
    
    /// 检测当前环境是否iPad
    static var isPad : Bool {
        return UI_USER_INTERFACE_IDIOM() == .Pad
    }
}

