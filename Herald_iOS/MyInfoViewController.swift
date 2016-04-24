import Foundation
import UIKit

class MyInfoViewController: UITableViewController {
    
    var parent : MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                showQuestionDialog("确定清空所有个人模块缓存吗？") { CacheHelper.clearAllModuleCache() }
            case 1:
                showQuestionDialog("确定要退出登录吗？") { ApiHelper.doLogout(self) }
            default:
                break
            }
        default:
            break
        }
    }
}
