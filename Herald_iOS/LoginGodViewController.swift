import UIKit

class LoginGodViewController: UIViewController {

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
        ApiRequest().url(ApiHelper.auth_url).noCheck200()
            .post("user", username!.text!, "password", password!.text!, "appid", appid)
            .onFinish { success, _, response in
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
        ApiRequest().api("user").uuid()
            .toAuthCache("schoolnum") { json in json["content"]["schoolnum"] }
            .onFinish { (success, code, response) in
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

