import Foundation

class ShareHelper {
    
    static func share(_ content: String) {
        let items : [Any] = [content]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll]
        
        /// 各类分享对话框、ActionSheet等，展示前必须设置sourceView，否则在iPad上会导致崩溃
        vc.popoverPresentationController?.sourceView = AppDelegate.instance.wholeController.view
        
        AppDelegate.instance.wholeController.present(vc, animated: true, completion: nil)
    }
}
