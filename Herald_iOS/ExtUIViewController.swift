import UIKit
import SVProgressHUD
import Toast_Swift

/**
 * UIViewController | 提示框功能
 * 实现基本VC中通过函数直接显示对话框、加载框、提示消息的功能
 * 
 * 注意：加载框是全局单例的，因此如果调用多次 showProgressDialog()，再调用一次hideProgressDialog() 既可隐藏。
 */
extension UIViewController {
    
    /// 显示加载框（全局单例）
    static func showProgressDialog() {
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.show()
    }
    
    func showProgressDialog() {
        UIViewController.showProgressDialog()
    }
    
    /// 隐藏加载框（全局单例）
    static func hideProgressDialog() {
        SVProgressHUD.dismiss()
    }
    
    func hideProgressDialog() {
        UIViewController.hideProgressDialog()
    }
    
    /// 显示提示消息
    func showMessage(message : String) {
        if let vc = getTopViewController() {
            var style = ToastStyle()
            style.messageFont = UIFont.systemFontOfSize(14)
            style.horizontalPadding = 20
            style.verticalPadding = 10
            style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            ToastManager.shared.style = style
            let toastPoint = CGPoint(x: vc.view.bounds.width / 2, y: vc.view.bounds.maxY - 100)
            vc.view.makeToast(message, duration: max(1, Double(message.characters.count) / 15), position: toastPoint)
        }
    }
    
    /// 显示有确认和取消按钮的对话框
    func showQuestionDialog (message: String, runAfter: () -> Void) {
        
        // 若已有窗口，不作处理
        if getTopViewController()?.presentedViewController != nil {
            return
        }
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
            (action: UIAlertAction) -> Void in runAfter()})
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
            (action: UIAlertAction) -> Void in })
        getTopViewController()?.presentViewController(dialog, animated: true, completion: nil)
    }
    
    /// 显示只有确认按钮的对话框
    func showSimpleDialog (message: String) {
        
        // 若已有窗口，不作处理
        if getTopViewController()?.presentedViewController != nil {
            return
        }
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){ action in })
        getTopViewController()?.presentViewController(dialog, animated: true, completion: nil)
    }
    
    /// 显示带有“不再提示”按钮的对话框
    func showTipDialogIfUnknown (message: String, cachePostfix: String, runAfter: () -> Void) {
        
        // 若已有窗口，不作处理
        if getTopViewController()?.presentedViewController != nil {
            return
        }
        let shown = CacheHelper.get("tip_ignored_" + cachePostfix) == "1"
        if !shown {
            let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){
                (action: UIAlertAction) -> Void in runAfter()})
            dialog.addAction(UIAlertAction(title: "不再提示", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in
                CacheHelper.set("tip_ignored_" + cachePostfix, "1")
                runAfter()
                })
            getTopViewController()?.presentViewController(dialog, animated: true, completion: nil)
        } else {
            runAfter()
        }
    }
    
    /// 设置导航栏颜色，参数是 Java 风格的不透明颜色值，例如 0x2bbfff
    func setNavigationColor (swiper: SwipeRefreshHeader?, _ color: Int) {
        var color = color
        let blue = CGFloat(color % 0x100) / 0xFF
        color /= 0x100
        let green = CGFloat(color % 0x100) / 0xFF
        color /= 0x100
        let red = CGFloat(color % 0x100) / 0xFF
        let _color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        setNavigationColor(swiper, uiColor: _color)
    }
    
    /// 设置导航栏颜色
    func setNavigationColor (swiper: SwipeRefreshHeader?, uiColor color: UIColor) {
        if let bar = self.navigationController?.navigationBar {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationCurve(.Linear)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.3)
            bar.barTintColor = color
            UIView.commitAnimations()
        }
        
        swiper?.themeColor = color
    }
    
    /// 获取当前最顶层的VC，以防止提示消息显示不出来
    // 参考了 SVProgressHUD 中获取最顶层窗口的实现
    func getTopViewController() -> UIViewController? {
        let frontToBackWindows = UIApplication.sharedApplication().windows.reverse()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.mainScreen()
            let windowIsVisible = !window.hidden && window.alpha > 0
            let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
            
            if windowOnMainScreen && windowIsVisible && windowLevelNormal {
                if let vc = window.rootViewController {
                    if vc.isViewLoaded() {
                        if let child = vc.presentedViewController {
                            return child
                        }
                        return vc
                    }
                }
            }
        }
        return nil
    }
}