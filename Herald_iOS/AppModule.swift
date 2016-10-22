import UIKit

/**
 * AppModule | 应用模块
 *
 * 注意：这里允许伪模块的存在，真的模块作为常量保存在 R 中，
 *      而伪模块可以使用构造函数动态创建，用于临时打开某个界面或转到某个 Web 页等。
 */
class AppModule : Hashable {
    
    /// 模块名称，这里用英文，以便作为存储数据等的键值
    var name : String
    
    /// 模块显示名称
    var nameTip : String
    
    /// 模块描述
    var desc : String
    
    /// 模块VC名称（Identifier），也可以是网址或TABn（n表示要跳转到的Tab index）
    var mDestination : String
    
    var destination : String {
        get {
            return mDestination.replaceAll("[uuid]", ApiHelper.currentUser.uuid)
        } set {
            mDestination = newValue
        }
    }
    
    /// 在 Assets 中的图标名称
    var icon : String
    
    var invertIcon : String {
        return icon + "_invert"
    }
    
    /// 是否有卡片
    var hasCard : Bool
    
    /// 构造函数
    init (_ name : String, _ nameTip : String, _ desc : String,
            _ controller : String, _ icon : String, _ hasCard : Bool) {
        self.name = name
        self.nameTip = nameTip
        self.desc = desc
        self.mDestination = controller
        self.icon = icon
        self.hasCard = hasCard
    }
    
    /// 创建一个基于webview的页面，注意这里url中必须以http开头
    convenience init (title: String, url : String) {
        self.init ("", title, "", url, "", false)
    }
    
    /// 用于比较两个模块是否相等
    var hashValue : Int {
        return destination.hashValue
    }
    
    /// 卡片是否开启
    var cardEnabled : Bool {
        get {
            return hasCard && SettingsHelper.get("herald_settings_module_cardenabled_" + name) != "0"
        } set {
            if !hasCard { return }
            // flag为true则设置为选中，否则设置为不选中
            SettingsHelper.set("herald_settings_module_cardenabled_" + name, newValue ? "1" : "0")
            SettingsHelper.notifyModuleSettingsChanged()
        }
    }
    
    /// 快捷方式是否开启
    var shortcutEnabled : Bool {
        get {
            let cache = SettingsHelper.get("herald_settings_module_shortcutenabled_" + name)
            if cache == "" {
                return !hasCard
            }
            return cache != "0"
        } set {
            // flag为true则设置为选中，否则设置为不选中
            SettingsHelper.set("herald_settings_module_shortcutenabled_" + name, newValue ? "1" : "0")
            SettingsHelper.notifyModuleSettingsChanged()
        }
    }
    
    /// 打开模块
    func open (){
        
        // 空模块不做任何事
        if destination == "" { return }
        
        // Web 页面，交给 WebModule 打开
        if destination.hasPrefix("http") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE") as! WebModuleViewController
            vc.title = nameTip
            vc.url = destination
            
            if let rightController = AppDelegate.instance.rightController {
                rightController.pushViewController(vc, animated: true)
            }
            
            // 切换到指定的 Tab，只适用于首页的 Tab
        } else if destination.hasPrefix("TAB") {
            if let tab = Int(destination.replaceAll("TAB", "")) {
                if let tabVC = AppDelegate.instance.leftController?.childViewControllers[0] as? UITabBarController {
                    tabVC.selectedIndex = tab
                }
            }
            
            // 切换到指定的VC
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(destination)
            if vc is LoginUserNeeded && !ApiHelper.isLogin() {
                ApiHelper.showTrialFunctionLimitDialog(nameTip)
            } else if let rightController = AppDelegate.instance.rightController {
                rightController.pushViewController(vc, animated: true)
            }
        }
    }
    
    /// 获取 3D Touch 预览的vc
    func getPreviewViewController () -> UIViewController? {
        
        if destination == "" { return nil }
        
        if destination.hasPrefix("http") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE") as! WebModuleViewController
            vc.title = nameTip
            vc.url = destination
            vc.preferredContentSize = CGSizeMake(SCREEN_WIDTH, 600)
            return vc
        } else if destination.hasPrefix("TAB") {
            return nil
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(destination)
            if vc is LoginUserNeeded && !ApiHelper.isLogin() {
                return nil
            }
            if vc is ForceTouchPreviewable {
                vc.preferredContentSize = CGSizeMake(SCREEN_WIDTH, 600)
                return vc
            }
            return nil
        }
    }
}

func == (lhs : AppModule, rhs : AppModule) -> Bool {
    return lhs.hashValue == rhs.hashValue
}