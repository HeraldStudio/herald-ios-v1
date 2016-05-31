import UIKit

/**
 * AppDelegate | 应用程序主入口
 * 负责整个应用程序的全局属性设置和全局事件处理
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// 应用程序的主显示窗口
    var window: UIWindow?
    
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
            if R.module.curriculum.cardEnabled {
                CurriculumNotifier.scheduleNotifications()
            }
            
            // 加载实验通知
            if R.module.experiment.cardEnabled {
                ExperimentNotifier.scheduleNotifications()
            }
            
            // 加载考试通知
            if R.module.exam.cardEnabled {
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
        let rootVC = self.window?.rootViewController as! UINavigationController
        switch shortcutItem.type {
        case "exam":
            R.module.exam.open(rootVC)
        case "curriculum":
            R.module.curriculum.open(rootVC)
        case "card":
            AppModule(title: "一卡通充值", url: "http://58.192.115.47:8088/wechat-web/login/initlogin.html").open(rootVC)
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
        let lvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("login")
        
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
        let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("main")
        
        // 打开新的界面
        self.window?.rootViewController = mvc
        
        return mvc
    }
}

