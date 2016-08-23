import Foundation

class ShareHelper {
    
    static func share(content: String) {
        let items : [AnyObject] = [content]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]
        
        /// 各类分享对话框、ActionSheet等，展示前必须设置sourceView，否则在iPad上会导致崩溃
        vc.popoverPresentationController?.sourceView = AppDelegate.instance.wholeController.view
        
        AppDelegate.instance.wholeController.presentViewController(vc, animated: true, completion: nil)
    }
}