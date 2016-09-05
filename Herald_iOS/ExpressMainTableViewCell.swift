import UIKit
import SwiftyJSON
import IQDropDownTextField

class ExpressMainTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var smsText : UITextField!
    
    @IBOutlet var userName : UITextField!
    
    @IBOutlet var userPhone : UITextField!
    
    @IBOutlet var expressLocation : IQDropDownTextField!
    
    @IBOutlet var expressWeight : IQDropDownTextField!
    
    @IBOutlet var expressDest : IQDropDownTextField!
    
    @IBOutlet var expressTime : IQDropDownTextField!
    
    @IBOutlet var iAgree : UISwitch!
    
    @IBOutlet var expressSubmit : UIButton!
    
    var controller : UIViewController?
    
    override func didMoveToSuperview() {
        
        // 调用父类 NoSelectionTableViewCell 的同一方法，去掉选择背景
        super.didMoveToSuperview()
        controller = AppDelegate.instance.rightController
        userName.text = Cache.expressUserName.value
        userPhone.text = Cache.expressUserPhone.value
        initSpinner()
        refreshTimeList()
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
    
    func refreshTimeList() {
        AppDelegate.instance.rightController.showProgressDialog()
        ApiSimpleRequest(.Post).url("http://app.heraldstudio.com/kuaidi/getTimeList")
            .onResponse { success, _, response in
                AppDelegate.instance.rightController.hideProgressDialog()
                if success {
                    let arr = JSON.parse(response)["content"].arrayValue.map { $0.stringValue }
                    if arr.count > 0 {
                        self.expressTime.isOptionalDropDown = false
                        self.expressTime.itemList = arr
                    } else {
                        self.controller?.showMessage("获取可用取货时间失败，请刷新")
                    }
                } else {
                    self.controller?.showMessage("获取可用取货时间失败，请刷新")
                }
            }.run()
    }
    
    func initSpinner () {
        expressDest.isOptionalDropDown = false
        expressDest.itemList = ["梅九大厅", "桃三四大厅"]
        expressLocation.isOptionalDropDown = false
        expressLocation.itemList = ["东门", "南门"]
        expressWeight.isOptionalDropDown = false
        expressWeight.itemList = ["小于2kg", "2~4kg", "4kg以上"]
    }
    
    @IBAction func onSubmit() {
        guard let smsTextText = smsText.text where !smsTextText.isEmpty else {
            controller?.showMessage("请填写短信内容")
            return
        }
        
        if smsTextText.characters.count < 10 {
            controller?.showMessage("短信内容不得少于10字符")
            return
        }
        
        guard let userNameText = userName.text, userPhoneText = userPhone.text
            where !userNameText.isEmpty && !userPhoneText.isEmpty else {
                controller?.showMessage("请将信息填写完整")
                return
        }
        
        Cache.expressUserName.value = userNameText
        Cache.expressUserPhone.value = userPhoneText
        guard let
            expressDestText = expressDest.selectedItem,
            expressTimeText = expressTime.selectedItem,
            expressLocationText = expressLocation.selectedItem,
            expressWeightText = expressWeight.selectedItem
            else {
                controller?.showMessage("取货时间为空，请刷新并选择取货时间")
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
                        self.smsText.text = ""
                        self.controller?.showSimpleDialog("尊敬的客户您好，已收到您的订单。请您于\(expressTimeText)内到\(expressDestText)取回您的快件，现场付款，支持支付宝和微信转账。如有疑问，请按照“价格、条款和条件”中的联系方式进行咨询。")
                    } else {
                        self.controller?.showMessage(res["content"].string ?? "提交失败，未知错误")
                    }
                } else {
                    self.controller?.showMessage("提交失败，请重试")
                }
            }.run()
    }
}