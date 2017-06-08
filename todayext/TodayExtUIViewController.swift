import UIKit
import Toast_Swift

/**
 * UIViewController | 提示框功能
 * 实现基本VC中通过函数直接显示对话框、加载框、提示消息的功能
 *
 * 注意：加载框是全局单例的，因此如果调用多次 showProgressDialog()，再调用一次hideProgressDialog() 既可隐藏。
 */
extension UIViewController {
    /// 显示提示消息
    func showMessage(_ message : String) {
        var style = ToastStyle()
        style.messageFont = UIFont.systemFont(ofSize: 14)
        style.horizontalPadding = 20
        style.verticalPadding = 10
        style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        ToastManager.shared.style = style
        let toastPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        view.makeToast(message, duration: max(1, Double(message.characters.count) / 15), position: toastPoint)
    }
}
