import UIKit

/**
 * SettingsViewController | 设置界面
 * 设置界面主要是静态列表，这个类主要负责管理其中的动态内容、以及一些无法用 Segue 表示的点击事件
 */
class SettingsViewController: UITableViewController {
    
    @IBOutlet var loginOrLogoutText : UILabel!
    
    /// 上课提醒、实验提醒、考试提醒的开关
    @IBOutlet var curriculumSwitch : UISwitch!
    @IBOutlet var experimentSwitch : UISwitch!
    @IBOutlet var examSwitch : UISwitch!
    
    /// 版本信息显示
    @IBOutlet var version : UILabel!
    
    /// 跳转到 App Store 发布页面，用于检查更新或发布评论
    func checkVersion () {
        UIApplication.sharedApplication().openURL(NSURL(string: StringUpdateUrl)!)
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
            if ApiHelper.isLogin(){
                /// 退出登录
                showQuestionDialog("确定要退出登录吗？") { ApiHelper.doLogout(nil) }
            } else {
                /// 登录
                AppDelegate.showLogin()
            }
        case (2, 1):
            /// 分享小猴
            ShareHelper.share("我在使用小猴偷米App，它是东南大学本科生必备的校园生活助手，你也来试试吧：http://app.heraldstudio.com/")
        case (2, 2):
            /// 给我们评分（App Store不允许有版本更新按钮，因此更名）
            checkVersion()
        default:
            break
        }
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
}
