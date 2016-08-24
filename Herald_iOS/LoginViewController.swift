import UIKit
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var username : UITextField!

    @IBOutlet var password : UITextField!

    @IBOutlet var button : UIButton!

    @IBOutlet var background : UIImageView!

    var user = User("", "", "", "")

    override func viewDidLoad() {
        super.viewDidLoad()

        // 将超出部分截掉，防止滑动返回时看到超出部分的图片
        background.layer.masksToBounds = true
    }

    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x000000)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 手机只支持竖屏，平板支持横屏和竖屏
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return AppDelegate.isPad ? .AllButUpsideDown : .Portrait
    }

    @IBAction func buttonClicked() {
        endEdit()
        if username.text! != "" && password.text! != "" {
            doLogin()
        } else {
            showMessage("输入不完整，请重试")
        }
    }

    @IBAction func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func doLogin () {
        let appid = ApiHelper.appid
        showProgressDialog()
        ApiSimpleRequest(.Post).url(ApiHelper.auth_url)
            .post("user", username!.text!, "password", password!.text!, "appid", appid)
            .onResponse { success, _, response in
                if response.containsString("Unauthorized") {
                    self.hideProgressDialog()
                    self.showMessage("密码错误，请重试")
                } else if response.containsString("Bad Request") {
                    self.hideProgressDialog()
                    self.showMessage("当前客户端版本已过期，请下载最新版本")
                    UIApplication.sharedApplication().openURL(NSURL(string: StringUpdateUrl)!)
                } else if !success {
                    self.hideProgressDialog()
                    self.showMessage("网络异常，请重试")
                } else {
                    self.user.uuid = response
                    self.user.userName = self.username!.text!
                    self.user.password = self.password!.text!
                    self.checkUUID()
                }
            }.run()
    }

    func checkUUID () {
        ApiSimpleRequest(.Post).api("user").post("uuid", self.user.uuid)
            .onResponse { (success, code, response) in

                /**
                 * 注意: 学号的获取关系到统计功能和 srtp api 的正常调用, 千万要保证学号正确!
                 *
                 * 若学号没有正确获取, 由于服务端的缓存机制, 已绑定微信的用户仍然可能看到正确的结果,
                 * 所以开发者在日常使用中几乎不可能发现这种错误, 需要经过专门测试才能确定客户端是否正确获取学号!
                 *
                 * 测试方法如下: (注意 postman 使用时应当保证填写的 uuid 与客户端 uuid 相同)
                 *
                 * 1) 使用 postman, 调用 srtp 接口, schoolnum 参数中填写自己的学号, 应当返回自己的 srtp 信息;
                 * 2) 使用 postman, 调用 srtp 接口, schoolnum 参数中填写同学A的学号, 应当返回同学A的 srtp 信息;
                 * 3) 使用 postman, 调用 srtp 接口, 不带 schoolnum 参数, 应当返回同学A的 srtp 信息;
                 * 4) 使用客户端刷新 srtp 模块, 应当返回正确的 srtp 信息;
                 * 5) 使用 postman, 调用 srtp 接口, 不带 schoolnum 参数, 应当返回自己的 srtp 信息;
                 **/
                self.user.schoolNum = JSON.parse(response)["content"]["schoolnum"].stringValue
                if success && self.user.schoolNum.characters.count == 8 {
                    ApiHelper.currentUser = self.user
                    self.dismiss()
                    AppModule(title: "跳转到首页", url: "TAB0").open()
                } else {
                    self.hideProgressDialog()
                    self.showMessage("用户不存在或网络异常，请重试")
                }
        }.run()
    }

    @IBAction func endEdit () {
        username.resignFirstResponder()
        password.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == username {
            password.becomeFirstResponder()
        } else if textField == password {
            buttonClicked()
        }
        return true
    }
}
