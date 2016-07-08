import UIKit

/**
 * AppModule | 应用模块
 *
 * 注意：这里允许伪模块的存在，真的模块作为常量保存在 SettingsHelper 中，
 *      而伪模块可以使用构造函数动态创建，用于临时打开某个界面或转到某个 Web 页等。
 */
class AppModule : Hashable {
    
    /// 模块 ID，如果是真模块，注意要与 Module 枚举类中的顺序一致；伪模块用 -1 即可
    var id : Int
    
    /// 模块名称，这里用英文，以便作为存储数据等的键值
    var name : String
    
    /// 模块显示名称
    var nameTip : String
    
    /// 模块描述
    var desc : String
    
    /// 模块VC名称（Identifier），也可以是网址或TABn（n表示要跳转到的Tab index）
    var controller : String
    
    /// 在 Assets 中的图标名称
    var icon : String
    var hasCard : Bool
    
    /// 构造函数
    init (_ id : Int, _ name : String, _ nameTip : String, _ desc : String,
          _ controller : String, _ icon : String, _ hasCard : Bool) {
        self.id = id
        self.name = name
        self.nameTip = nameTip
        self.desc = desc
        self.controller = controller
        self.icon = icon
        self.hasCard = hasCard
    }
    
    /// 创建一个基于webview的页面，注意这里url中必须含有http
    convenience init (title: String, url : String) {
        self.init (-1, "", title, "", url, "", false)
    }
    
    var hashValue : Int {
        return controller.hashValue
    }
    
    /// 卡片是否开启
    var cardEnabled : Bool {
        get {
            return hasCard && SettingsHelper.get("herald_settings_module_cardenabled_" + name) != "0"
        } set {
            if !hasCard { return }
            // flag为true则设置为选中，否则设置为不选中
            if (newValue) {
                SettingsHelper.set("herald_settings_module_cardenabled_" + name, "1")
            } else {
                SettingsHelper.set("herald_settings_module_cardenabled_" + name, "0")
            }
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
            if (newValue) {
                SettingsHelper.set("herald_settings_module_shortcutenabled_" + name, "1")
            } else {
                SettingsHelper.set("herald_settings_module_shortcutenabled_" + name, "0")
            }
            SettingsHelper.notifyModuleSettingsChanged()
        }
    }
    
    /// 用来标识一个不带卡片的模块数据是否有更新
    var hasUpdates : Bool {
        get {
            return !hasCard && SettingsHelper.get("herald_settings_module_hasupdates_" + name) == "1"
        } set {
            SettingsHelper.set("herald_settings_module_hasupdates_" + name, newValue ? "1" : "0")
            SettingsHelper.notifyModuleSettingsChanged()
        }
    }
    
    /// 打开模块
    func open (){
        // 空模块不做任何事
        if controller == "" { return }
        
        // Web 页面，交给 WebModule 打开
        if controller.hasPrefix("http") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE") as! WebModuleViewController
            vc.title = nameTip
            vc.url = controller
            
            AppDelegate.instance.rightController.pushViewController(vc, animated: true)
            
            // 切换到指定的 Tab，只适用于首页的 Tab
        } else if controller.hasPrefix("TAB") {
            if let tab = Int(controller.replaceAll("TAB", "")) {
                if let tabVC = AppDelegate.instance.leftController.childViewControllers[0] as? UITabBarController {
                    tabVC.selectedIndex = tab
                }
            }
            
            // 切换到指定的VC
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(controller)
            AppDelegate.instance.rightController.pushViewController(vc, animated: true)
        }
    }
}

func == (lhs : AppModule, rhs : AppModule) -> Bool {
    return lhs.hashValue == rhs.hashValue
}