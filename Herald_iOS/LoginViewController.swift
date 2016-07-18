import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var username : UITextField!
    
    @IBOutlet var password : UITextField!
    
    @IBOutlet var button : UIButton!
    
    @IBOutlet var background : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
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
        if username?.text! != "" && password?.text! != "" {
            doLogin()
        } else {
            showMessage("输入不完整，请重试")
        }
    }
    
    func doLogin () {
        let appid = ApiHelper.appid
        showProgressDialog()
        ApiSimpleRequest(.Post, checkJson200: false).url(ApiHelper.auth_url)
            .post("user", username!.text!, "password", password!.text!, "appid", appid)
            .onResponse { success, _, response in
                if response.containsString("Unauthorized") {
                    self.hideProgressDialog()
                    self.showMessage("密码错误，请重试")
                } else if !success {
                    self.hideProgressDialog()
                    self.showMessage("网络异常，请重试")
                } else {
                    ApiHelper.setAuthCache("uuid", response)
                    ApiHelper.setAuth(user: self.username!.text!, pwd: self.password!.text!)
                    self.checkUUID()
                }
            }.run()
    }
    
    func checkUUID () {
        ApiSimpleRequest(.Post, checkJson200: true).api("user").uuid()
            .toAuthCache("schoolnum") { json in json["content"]["schoolnum"] }
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
                if success && ApiHelper.authCache.get("schoolnum").characters.count == 8 {
                ((UIApplication.sharedApplication().delegate) as! AppDelegate).showMain()
            } else {
                self.hideProgressDialog()
                ApiHelper.doLogout("用户不存在或网络异常，请重试")
            }
        }.run()
    }
    
    @IBAction func endEdit () {
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
}

