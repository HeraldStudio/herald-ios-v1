import UIKit

/**
 * AppDelegate | 应用程序主入口
 * 负责整个应用程序的全局属性设置和全局事件处理
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// 应用程序的主显示窗口
    var window: UIWindow?
    
    /// 用来显示主界面的导航控制器，在平板模式下是左侧视图
    var leftController: UINavigationController?
    
    /// 用来显示模块界面的导航控制器，在平板模式下是右侧视图
    var rightController: UINavigationController?
    
    /// 对获取AppDelegate单例的语句进行简化
    static var instance : AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    /// 无参数的启动结束事件，似乎不会触发
    func applicationDidFinishLaunching(application: UIApplication) {}
    
    /// 带参数的启动结束事件
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 启动次数递增
        SettingsHelper.launchTimes += 1
        
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
        
        /// 若没有登录，立即销毁主界面并切换到登录界面，并结束初始化
        if !ApiHelper.isLogin() {
            showLogin()
            return true
        }
        
        showMain()
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
        
        // 若已登录，注册新的通知
        if ApiHelper.isLogin() {
            
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
    }
    
    /// 清空图标徽标数字
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    /// 处理主屏幕图标 3D Touch 菜单点击事件
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        // 若没有登录，直接切换到登录界面
        if !ApiHelper.isLogin() {
            showLogin()
            return
        }
        
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
    
    /// 使主窗口立即跳转到登录界面
    func showLogin () -> UIViewController {
        
        // 关闭当前界面
        self.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        
        // 销毁当前界面
        /// TODO 貌似Swift不需要这句？
        self.window?.rootViewController = nil
        
        // 实例化新的界面
        let lvc = AppDelegate.instantiateLoginViewController()
        
        // 打开新的界面
        self.window?.rootViewController = lvc
        
        return lvc
    }
    
    /// 使主窗口立即跳转到主界面
    func showMain () -> UIViewController {
        
        // 关闭当前界面
        self.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        
        // 销毁当前界面
        /// TODO 貌似Swift不需要这句？
        self.window?.rootViewController = nil
        
        // 实例化新的界面
        let mvc = AppDelegate.instantiateMainViewController()
        
        // 打开新的界面
        self.window?.rootViewController = mvc
        
        return mvc
    }
    
    /// 检测当前环境是否iPad
    static var isPad : Bool {
        return UI_USER_INTERFACE_IDIOM() == .Pad
    }
    
    /// 切换到登录页
    static func instantiateLoginViewController() -> UIViewController {
        let id = "LoginViewController"
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(id)
    }
    
    /// 切换到主页
    static func instantiateMainViewController() -> UIViewController {
        let id = isPad ? "MainSplitController" : "MainNavigationController"
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(id)
    }
}

