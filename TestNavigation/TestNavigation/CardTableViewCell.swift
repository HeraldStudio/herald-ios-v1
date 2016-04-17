//
//  CardTableViewCell.swift
//  TestNavigation
//
//  Created by Howie on 16/3/30.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    //@IBOutlet weak var scrollV: UIScrollView!

    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var button: UIButton!

    //三个成员变量保存cell初始化的约束高度值、确保cell复用时、不被销毁
    var messageHeightInit: CGFloat!
    var messageToContainerHInit:CGFloat!
    var containerViewHeightInit:CGFloat!
    var cardframeInit:CGRect!
    //var hasChildView = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customView.layer.cornerRadius = 5
        
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        cardframeInit = frame
    }
    @IBAction func toppedUP(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://58.192.115.47:8088/wechat-web/login/initlogin.html")!)
    }
    
    //增加子scrollview
    func addScrollView(height: CGFloat){
        
        let scrollV = UIScrollView(frame: CGRectMake(10,101,344,height - 111))
        //下一个view的x、初始为4
        var xw: CGFloat = 4
        
        //生成子页面
        for i in 0..<curriculum.count {
            let nib = NSBundle.mainBundle().loadNibNamed("LectureScrollView", owner: self, options: nil)
            let view = nib[0] as! LectureScrollView
            view.lectureTime.text = curriculum[i][0]
            view.lectureName.text = curriculum[i][1]
            view.lectureLocal.text = curriculum[i][2]
            view.lecturer.text = curriculum[i][3]
            
            //计算label宽度最大的,一般来说教师的label都是比较小的，不进行比较了
            let a = (curriculum[i][0] as NSString).sizeWithAttributes([NSFontAttributeName:view.lectureTime.font]).width
            let b = (curriculum[i][1] as NSString).sizeWithAttributes([NSFontAttributeName:view.lectureName.font]).width
            let c = (curriculum[i][2] as NSString).sizeWithAttributes([NSFontAttributeName:view.lectureLocal.font]).width
            let viewW = max(a, b, c)
            
            view.frame = CGRectMake(xw, 0, viewW + 16, view.frame.height)
            xw += viewW+20
            
            //views.append(view)
            scrollV.addSubview(view)
        }
        
        scrollV.contentSize = CGSizeMake(xw + 4, scrollV.frame.height)
        customView.addSubview(scrollV)
    }
    
    
    //增加jwc的子scrollview
    func addJwcScrollView() {
        //下一个view的x
        var xw: CGFloat = 4
        
        let scrollV = UIScrollView(frame: CGRectMake(10,95,344,64))
        //生成子页面
        for i in 0..<jwc.count {
            let nib = NSBundle.mainBundle().loadNibNamed("JwcScrollView", owner: self, options: nil)
            let view = nib[0] as! JwcScrollView
            view.jwcTitle.text = jwc[i][0]
            view.jwcTime.text = jwc[i][1]
            
            view.frame = CGRectMake(xw, 0, view.frame.width, view.frame.height)
            xw += view.frame.width + 16
            //views.append(view)
            scrollV.addSubview(view)
        }
        
        scrollV.contentSize = CGSizeMake(xw + 4, scrollV.frame.height)
        customView.addSubview(scrollV)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*func recoverConstant() {
        messageHeight.constant = messageHeightInit
        messgaeToContainerH.constant = messageToContainerHInit
        containerViewHeight.constant = containerViewHeightInit
    }*/

}
