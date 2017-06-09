import UIKit

/**
 * SettingsViewController | 设置界面
 * 设置界面主要是静态列表，这个类主要负责管理其中的动态内容、以及一些无法用 Segue 表示的点击事件
 */
class SettingsViewController: UITableViewController {
    
    @IBOutlet var loginOrLogoutText : UILabel!
    
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
        UIApplication.shared.openURL(URL(string: StringUpdateUrl)!)
    }
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        /// 当用户改变时重新加载
        ApiHelper.addUserChangedListener { 
            self.loadData()
        }
    }
    
    func loadData() {
        /// 初始化登录按钮文字
        loginOrLogoutText.text = ApiHelper.isLogin() ? "退出登录" : "登录"
        
        /// 初始化开关状态
        wifiSwitch.setOn(SettingsHelper.wifiAutoLogin, animated: false)
        curriculumSwitch.setOn(SettingsHelper.curriculumNotificationEnabled, animated: false)
        experimentSwitch.setOn(SettingsHelper.experimentNotificationEnabled, animated: false)
        examSwitch.setOn(SettingsHelper.examNotificationEnabled, animated: false)
        
        /// 初始化版本信息的显示
        version.text = "当前版本：v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
    }
    
    /// 当准备从其它界面返回时，设置导航栏颜色
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x12b0ec)
    }
    
    /// 一些自定义的点击事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if ApiHelper.isLogin(){
                /// 退出登录
                showQuestionDialog("确定要退出登录吗？") { ApiHelper.doLogout(nil) }
            } else {
                /// 登录
                AppDelegate.showLogin()
            }
        case (0, 1):
            /// 自定义校园网登录账号
            displayWifiSetDialog()
        case (3, 0):
            /// 关于我们
            AppModule(title: "关于小猴", url: "https://app.heraldstudio.com/about.htm?type=ios").open()
        case (3, 1):
            /// 分享小猴
            ShareHelper.share("我在使用小猴偷米App，它是东南大学本科生必备的校园生活助手，你也来试试吧：https://app.heraldstudio.com/")
        case (3, 2):
            /// 给我们评分（App Store不允许有版本更新按钮，因此更名）
            checkVersion()
        case (3, 3):
            /// 反馈建议
            UIApplication.shared.openURL(URL(string: "mailto:vhyme@live.cn")!)
        default:
            break
        }
    }
    
    /// 同步开关状态到设置
    @IBAction func wifiStateChanged () {
        SettingsHelper.wifiAutoLogin = wifiSwitch.isOn
    }
    
    @IBAction func curriculumStateChanged () {
        SettingsHelper.curriculumNotificationEnabled = curriculumSwitch.isOn
    }
    
    @IBAction func experimentStateChanged () {
        SettingsHelper.experimentNotificationEnabled = experimentSwitch.isOn
    }
    
    @IBAction func examStateChanged () {
        SettingsHelper.examNotificationEnabled = examSwitch.isOn
    }
    
    /// 显示摇一摇账号设置对话框
    func displayWifiSetDialog () {
        let dialog = UIAlertController(title: "自定义校园网登录账号", message: "你可以在这里设置用独立账号登陆校园网；校园网查询模块不受此设置影响", preferredStyle: .alert)
        
        dialog.addTextField { field in
            field.placeholder = "一卡通号"
        }
        
        dialog.addTextField { field in
            field.placeholder = "统一身份认证密码"
            field.isSecureTextEntry = true
        }
        
        dialog.addAction(UIAlertAction(title: "保存", style: UIAlertActionStyle.default, handler: { _ in
            let username = dialog.textFields![0].text
            let password = dialog.textFields![1].text
            
            if username != nil && password != nil && username! != "" && password! != "" {
                ApiHelper.setWifiAuth(user: username!, pwd: password!)
                self.showMessage("已保存为校园网独立账号，请手动测试账号是否有效~")
            } else {
                self.showMessage("你没有更改设置")
            }
        }))
        
        dialog.addAction(UIAlertAction(title: "恢复默认", style: UIAlertActionStyle.default, handler: { _ in
            ApiHelper.clearWifiAuth()
        }))
        
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: {
            _ in
        }))
        
        present(dialog, animated: true, completion: nil)
    }
}
