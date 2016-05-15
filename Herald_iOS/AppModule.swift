import UIKit

/**
 * AppModule | 应用模块
 *
 * 注意：这里允许伪模块的存在，真的模块作为常量保存在 SettingsHelper 中，
 *      而伪模块可以使用构造函数动态创建，用于临时打开某个界面或转到某个 Web 页等。
 */
class AppModule {
    
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
    
    /// 打开模块
    func open (navigationController : UINavigationController?) {
        
        // 空模块不做任何事
        if controller == "" { return }
        
        // Web 页面，交给 WebModule 打开
        if controller.containsString("http") {
            
            CacheHelper.set("herald_webmodule_title", nameTip)
            CacheHelper.set("herald_webmodule_url", controller)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE")
            navigationController?.pushViewController(vc, animated: true)
            
        // 切换到指定的 Tab，只适用于首页的 Tab
        } else if controller.hasPrefix("TAB") {
            if let tab = Int(controller.replaceAll("TAB", "")) {
                (navigationController?.childViewControllers[0] as? UITabBarController)?.selectedIndex = tab
            }
            
        // 切换到指定的VC
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(controller)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}