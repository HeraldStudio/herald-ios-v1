import UIKit
import SwiftyJSON

class ExpressMainTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var smsText : UITextField!
    
    @IBOutlet var userName : UITextField!
    
    @IBOutlet var userPhone : UITextField!
    
    @IBOutlet var expressLocation : UISegmentedControl!
    
    @IBOutlet var expressWeight : UISegmentedControl!
    
    @IBOutlet var expressDest : UISegmentedControl!
    
    @IBOutlet var expressTime : UISegmentedControl!
    
    @IBOutlet var iAgree : UISwitch!
    
    @IBOutlet var expressSubmit : UIButton!
    
    var controller : UIViewController?
    
    override func didMoveToSuperview() {
        
        // 调用父类 NoSelectionTableViewCell 的同一方法，去掉选择背景
        super.didMoveToSuperview()
        controller = AppDelegate.instance.rightController
        userName.text = Cache.expressUserName.value
        userPhone.text = Cache.expressUserPhone.value
        onAgreeChanged()
    }
    
    @IBAction func onShowTerms() {
        AppModule(title: "快递代取", url: "http://app.heraldstudio.com/kuaidi_terms.htm").open()
    }
    
    @IBAction func onAgreeChanged() {
        if iAgree.on {
            expressSubmit.backgroundColor = UIColor(red: 1, green: 186/255, blue: 0, alpha: 1)
            expressSubmit.enabled = true
        } else {
            expressSubmit.backgroundColor = UIColor(white: 0.5, alpha: 1)
            expressSubmit.enabled = false
        }
    }
    
    @IBAction func onSubmit() {
        guard let smsTextText = smsText.text where !smsTextText.isEmpty else {
            controller?.showMessage("请填写短信内容")
            return
        }
        
        guard let userNameText = userName.text, userPhoneText = userPhone.text
            where !userNameText.isEmpty && !userPhoneText.isEmpty else {
            AppDelegate.instance.rightController.showMessage("请将信息填写完整")
            return
        }
        
        Cache.expressUserName.value = userNameText
        Cache.expressUserPhone.value = userPhoneText
        guard let
            expressDestText = expressDest.titleForSegmentAtIndex(expressDest.selectedSegmentIndex),
            expressTimeText = expressTime.titleForSegmentAtIndex(expressTime.selectedSegmentIndex),
            expressLocationText = expressLocation.titleForSegmentAtIndex(expressLocation.selectedSegmentIndex),
            expressWeightText = expressWeight.titleForSegmentAtIndex(expressWeight.selectedSegmentIndex)
            else {
            AppDelegate.instance.rightController.showMessage("UI错误，请联系管理员")
            return
        }
        
        controller?.showProgressDialog()
        ApiSimpleRequest(.Post).url("http://app.heraldstudio.com/kuaidi/submit").uuid()
            .post("user_name", userNameText)
            .post("user_phone", userPhoneText)
            .post("sms_txt", smsTextText)
            .post("dest", expressDestText)
            .post("arrival", expressTimeText)
            .post("locate", expressLocationText)
            .post("weight", expressWeightText)
            .onResponse { success, _, response in
                self.controller?.hideProgressDialog()
                if success {
                    let res = JSON.parse(response)
                    if res["code"].intValue == 200 {
                        self.controller?.showQuestionDialog("尊敬的客户您好，已收到您的订单。请您于\(expressTimeText)内到\(expressDestText)取回您的快件，现场付款，支持支付宝和微信转账。如有疑问，请按照“价格、条款和条件”中的联系方式进行咨询。"){}
                    } else {
                        self.controller?.showMessage(res["content"].string ?? "提交失败，未知错误")
                    }
                } else {
                    self.controller?.showMessage("提交失败，请重试")
                }
            }.run()
    }
}