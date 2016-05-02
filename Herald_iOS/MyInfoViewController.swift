import Foundation
import UIKit

class MyInfoViewController: UITableViewController {
    
    var parent : MainViewController?
    
    @IBOutlet var version : UILabel!
    
    func checkVersion () {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/xiao-hou-tou-mi/id1107998946")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        version.text = "喜欢小猴就给个好评吧~ 当前版本：\(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                showQuestionDialog("确定要退出登录吗？") { ApiHelper.doLogout(self) }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 2:
                checkVersion()
            default:
                break
            }
        default:
            break
        }
    }
}
