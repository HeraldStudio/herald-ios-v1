import Foundation
import UIKit

class MyInfoViewController: UITableViewController {
    
    var parent : MainViewController?
    
    @IBOutlet var wifiSwitch : UISwitch!
    
    @IBOutlet var version : UILabel!
    
    func checkVersion () {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/xiao-hou-tou-mi/id1107998946")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wifiSwitch.setOn(SettingsHelper.getWifiAutoLogin(), animated: false)
        version.text = "喜欢小猴就给个好评吧~ 当前版本：v\(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)"
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
            case 0:
                wifiSwitch.setOn(!wifiSwitch.on, animated: true)
                wifiStateChanged()
            case 1:
                displayWifiSetDialog()
            default:
                break
            }
        case 2:
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
    
    @IBAction func wifiStateChanged () {
        SettingsHelper.setWifiAutoLogin(wifiSwitch.on)
    }
    
    func displayWifiSetDialog () {
        let dialog = UIAlertController(title: "自定义校园网登录账号", message: "你可以在这里设置用独立账号登陆校园网；校园网查询模块不受此设置影响", preferredStyle: UIAlertControllerStyle.Alert)
        
        dialog.addTextFieldWithConfigurationHandler { field in
            field.placeholder = "一卡通号"
        }
        
        dialog.addTextFieldWithConfigurationHandler { field in
            field.placeholder = "统一身份认证密码"
            field.secureTextEntry = true
        }
        
        dialog.addAction(UIAlertAction(title: "保存", style: UIAlertActionStyle.Default, handler: { _ in
            let username = dialog.textFields![0].text
            let password = dialog.textFields![1].text
            
            if username != nil && password != nil && username! != "" && password! != "" {
                ApiHelper.setWifiAuth(user: username!, pwd: password!)
                self.showMessage("已保存为校园网独立账号，建议手动摇一摇测试账号是否有效~")
            } else {
                self.showMessage("你没有更改设置")
            }
        }))
        
        dialog.addAction(UIAlertAction(title: "恢复默认", style: UIAlertActionStyle.Default, handler: { _ in
            ApiHelper.clearWifiAuth()
        }))
        
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: {
            _ in
        }))
        
        presentViewController(dialog, animated: true, completion: nil)
    }
}
