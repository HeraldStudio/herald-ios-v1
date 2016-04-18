import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet var username : UITextField?
    
    @IBOutlet var password : UITextField?
    
    @IBOutlet var button : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClicked() {
        if username?.text! != "" {
            doLogin()
        }
    }
    
    func doLogin () {
        let appid = ApiHelper.appid
        showProgressDialog()
        ApiRequest().url(ApiHelper.auth_url).plain()
            .post("user", username!.text!, "password", password!.text!, "appid", appid)
            .onFinish { success, _, response in
                self.hideProgressDialog()
                if response.containsString("Unauthorized") {
                    print("Unauthorized")
                    self.showMessage("密码错误，请重试")
                } else if !success {
                    self.showMessage("网络异常，请重试")
                } else {
                    ApiHelper.setAuthCache("uuid", withValue: response)
                    ApiHelper.setAuth(user: self.username!.text!, pwd: self.password!.text!)
                    self.checkUUID()
                }
            }.run()
    }
    
    func checkUUID () {
        ApiRequest().api("user").uuid().onFinish { (success, code, response) in
            if success {
                self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("main"), animated: true) {}
            } else {
                self.showMessage("网络异常，请重试")
                ApiHelper.doLogout(nil)
            }
        }.run()
    }
}

