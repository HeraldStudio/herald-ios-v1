import UIKit

/**
 * MyInfoViewController | 设置界面
 * 设置界面主要是静态列表，这个类主要负责管理其中的动态内容、以及一些无法用 Segue 表示的点击事件
 */
class MyInfoViewController: UITableViewController {
    
    /// 摇一摇登录校园网的开关
    @IBOutlet var wifiSwitch : UISwitch!
    
    /// 上课提醒、实验提醒、考试提醒的开关
    @IBOutlet var curriculumSwitch : UISwitch!
    @IBOutlet var experimentSwitch : UISwitch!
    @IBOutlet var examSwitch : UISwitch!
    
    /// 版本信息显示
    @IBOutlet var version : UILabel!
    
    /// 跳转到 App Store 发布页面，用于检查更新或发布评论
    func checkVersion () {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/xiao-hou-tou-mi/id1107998946")!)
    }
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 初始化开关状态
        wifiSwitch.setOn(SettingsHelper.wifiAutoLogin, animated: false)
        curriculumSwitch.setOn(SettingsHelper.curriculumNotificationEnabled, animated: false)
        experimentSwitch.setOn(SettingsHelper.experimentNotificationEnabled, animated: false)
        examSwitch.setOn(SettingsHelper.examNotificationEnabled, animated: false)
        
        /// 初始化版本信息的显示
        version.text = "当前版本：v\(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)"
    }
    
    /// 当准备从其它界面返回时，设置导航栏颜色
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x00b4ff)
    }
    
    /// 一些自定义的点击事件
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            /// 退出登录
            showQuestionDialog("确定要退出登录吗？") { ApiHelper.doLogout(nil) }
        case (1, 1):
            /// 自定义校园网登录账号
            displayWifiSetDialog()
        case (3, 2):
            /// 给我们评分（App Store不允许有版本更新按钮，因此更名）
            checkVersion()
        default:
            break
        }
    }
    
    /// 同步开关状态到设置
    @IBAction func wifiStateChanged () {
        SettingsHelper.wifiAutoLogin = wifiSwitch.on
    }
    
    @IBAction func curriculumStateChanged () {
        SettingsHelper.curriculumNotificationEnabled = curriculumSwitch.on
    }
    
    @IBAction func experimentStateChanged () {
        SettingsHelper.experimentNotificationEnabled = experimentSwitch.on
    }
    
    @IBAction func examStateChanged () {
        SettingsHelper.examNotificationEnabled = examSwitch.on
    }
    
    /// 显示摇一摇账号设置对话框
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
