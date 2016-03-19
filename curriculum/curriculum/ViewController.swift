//
//  ViewController.swift
//  curriculum
//
//  Created by 于海通 on 16/2/24.
//  Copyright © 2016年 Herald Studio. All rights reserved.
//

import UIKit;
import Alamofire;
import SwiftyJSON;

let API_PREFIX : String = "http://115.28.27.150/";
let METHOD_AUTH : String = "uc/auth";
let METHOD_CURRICULUM : String = "api/curriculum";
let METHOD_TERM : String = "api/term";
let METHOD_SIDEBAR : String = "api/sidebar";

// 常量，我校一天的课时数
let PERIOD_COUNT = 13;

// 常量，今天所在列与其他列的宽度比值
let TODAY_WEIGHT : CGFloat = 1.5;

// 星期在JSON中的表示值
let WEEK_NUMS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

// 星期在屏幕上的显示值
let WEEK_NUMS_CN = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

// 每节课开始的时间，以(Hour * 60 + Minute)形式表示
// 本程序假定每节课都是45分钟
let CLASS_BEGIN_TIME = [
    8 * 60, 8 * 60 + 50, 9 * 60 + 50, 10 * 60 + 40, 11 * 60 + 30,
    14 * 60, 14 * 60 + 50, 15 * 60 + 50, 16 * 60 + 40, 17 * 60 + 30,
    18 * 60 + 30, 19 * 60 + 20, 20 * 60 + 10
];

let BLOCK_COLORS = [
    [245,98,154],[254,141,63],[236,173,7],[161,210,19],
    [18,202,152],[0,171,212],[109,159,244],[159,115,255]
];

var sp : NSUserDefaults = NSUserDefaults.standardUserDefaults();

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var topPadding : CGFloat = 0.0;
    var width : CGFloat = 0.0;
    var height : CGFloat = 0.0;
    var columnsCount = 7;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "课表助手";
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "刷新", style: UIBarButtonItemStyle.Plain, target: self, action: "loadData");
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", style: UIBarButtonItemStyle.Plain, target: self, action: "settings");

        if(getUuid() != nil){
            loadPage();
            if(isRefreshNeeded()){
                loadData();
            }
        } else {
            return;
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /*************************
     * 实现::联网环节::登录认证
     *************************/

    func showSettingsDialog(titleStr: String, message: String, cancelable: Bool){
        
        // 初始化对话框
        var dialog :UIAlertController;
        dialog = UIAlertController(title: titleStr, message: message,
            preferredStyle: UIAlertControllerStyle.Alert);
        
        // 用户名输入框
        dialog.addTextFieldWithConfigurationHandler{
            (textField: UITextField!) -> Void in
            textField.placeholder = "一卡通号";
            let savedUserName = sp.valueForKey("user") as! String?;
            if(savedUserName != nil){
                textField.text = savedUserName!;
            }
            // TODO 设置输入格式为数字
        }
        
        // 密码输入框
        dialog.addTextFieldWithConfigurationHandler{
            (textField: UITextField!) -> Void in
            textField.placeholder = "统一身份认证密码";
            textField.secureTextEntry = true;
        }
        
        // 对话框按钮
        let loginAction = UIAlertAction(title: "登录", style: UIAlertActionStyle.Default){
            (action: UIAlertAction) -> Void in
            
            let userName = (dialog.textFields!.first as UITextField!).text;
            let password = (dialog.textFields!.last as UITextField!).text;
            
            // 用户名或密码为空
            if(userName == nil || userName == "" || password == nil || password == ""){
                self.showSettingsDialog(titleStr, message: "登录信息不完整，请重试", cancelable: cancelable);
                return;
            }
        
            // 保存用户名，开始刷新
            sp.setObject(userName, forKey: "user");
            sp.synchronize();
            
            Alamofire.request(.POST, "\(API_PREFIX)\(METHOD_AUTH)", parameters: [
                "appid" : "34cc6df78cfa7cd457284e4fc377559e",
                "user" : userName!,
                "password" : password!
                ]).responseString{ response in
                    // 登陆成功，保存uuid
                    let uuid = response.result.value!;
                    // UIAlertView(title: "debug", message:response.result.value!, delegate: self, cancelButtonTitle:"get").show();// TODO Handle exceptions
                    sp.setObject(uuid, forKey: "uuid");
                    sp.synchronize();
                    
                    // 开始请求课表信息
                    self.loadData();
            };
        }
        
        // 显示对话框
        dialog.addAction(loginAction);
        
        if(cancelable){
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
                (action: UIAlertAction) -> Void in
                
            }
            dialog.addAction(cancelAction);
        }
        
        presentViewController(dialog, animated: true, completion: nil);
    }
    
    /*************************
     * 实现::联网环节::获取课表
     *************************/

    func loadData(){
        
        // TODO 实现刷新控件
        self.title = "正在刷新";
        
        // 读取uuid
        let uuid = getUuid();
        if(uuid == nil) {
            return;
        }
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        let date = dateFormatter.stringFromDate(NSDate());
        
        // 联网请求
        Alamofire.request(.POST, "\(API_PREFIX)\(METHOD_CURRICULUM)", parameters: [
            "uuid" : uuid!,
            "date" : date
        ]).responseString{ response in
            sp.setObject(response.result.value!, forKey: "curTerm");
            sp.synchronize();
            
            // 获取侧栏
            Alamofire.request(.POST, "\(API_PREFIX)\(METHOD_SIDEBAR)", parameters: [
                "uuid" : uuid!
                ]).responseString{ response in
                    sp.setObject(response.result.value!, forKey: "sidebar");
                    sp.synchronize();
                    
                    // 下一环节
                    self.loadPage();
            };
        };
    }
    
    /*************************
     * 实现::联网环节::显示课表
     *************************/
    
    func loadPage(){
        for v in self.view.subviews{
            v.removeFromSuperview();
        }
        
        let image = UIImage(named: "idev.png");
        let imageView = UIImageView(frame: self.view.bounds);
        imageView.image = image;
        imageView.contentMode = .ScaleAspectFill;
        self.view.addSubview(imageView);
        
        width = self.view.bounds.width;
        height = self.view.bounds.height - topPadding;
        let dataOpt = sp.valueForKey("curTerm") as! String?;
        if(dataOpt == nil) {
            showErrorMessage(exception: "JSONException");
            return;
        }
        let data = dataOpt!;
        let sidebarOpt = sp.valueForKey("sidebar") as! String?;
        if(sidebarOpt == nil) {
            showErrorMessage(exception: "JSONException");
            return;
        }
        let sidebar = sidebarOpt!;
        
        // 检查数据完整性
        let obj = JSON.parse(data)["content"];
        let weekOpt = JSON.parse(data)["week"]["week"];
        let side = JSON.parse(sidebar)["content"];
        if (obj == nil || weekOpt == nil || side == nil){
            if(data.containsString("Timeout")){
                showErrorMessage(exception: "SocketTimeoutException");
            } else {
                showErrorMessage(exception: "JSONException");
            }
            return;
        }
        let weekOpt2 = weekOpt.int;
        if (weekOpt2 == nil){
            showErrorMessage(exception: "NumberFormatException");
            return;
        }
        let week = weekOpt2!;
        self.title = "第 \(week) 周";
        
        // 解析侧栏
        let sidebarDict : NSMutableDictionary = [:];
        for (var i = 0; i < side.count; i++){
            let k = side[i]["course"].string;
            let m = side[i]["lecturer"].string;
            let n = side[i]["credit"].string;
            
            if(k != nil && m != nil && n != nil){
                sidebarDict.setValue("授课教师：\(m!)\n课程学分：\(n!)", forKey: k!);
            }
        }
        
        // 没什么问题，保存当前的系统年份和周数，供下次启动时查阅
        sp.setObject(getWeekStamp(), forKey: "lastStart");
        sp.synchronize();
        
        // 绘制表示各课时的水平分割线
        for (var i = 0; i < PERIOD_COUNT; i++){
            let v = UIView(frame: CGRect(x: 0, y: topPadding + (CGFloat)(i + 1) * height / (CGFloat)(PERIOD_COUNT + 1), width: width, height: 1));
            v.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1);
            self.view.addSubview(v);
        }
        
        // 首先假设7天都有课
        columnsCount = 7;
        
        // 当天的星期
        let dayOfWeek = NSDate().dayOfWeek();
        
        // 双重列表，用每个子列表表示一天的课程
        let listOfList : NSMutableArray = [];
        
        // 放两个循环是为了先把列数确定下来
        for (var i = 0; i < 7; i++) {
            // 用JSON中对应的String表示的该日星期
            var array = obj[WEEK_NUMS[i]];
            
            // 剔除不属于本周的课程，并将对应的课程添加到对应星期的列表中
            let list = NSMutableArray();
            for (var j = 0; j < array.count; j++) {
                let info = ClassInfo(json: array[j]);
                info.weekNum = WEEK_NUMS_CN[i];
                let startWeek = info.startWeek;
                let endWeek = info.endWeek;
                if(endWeek >= week && startWeek <= week && info.isFitEvenOrOdd(week)){
                    list.addObject(info);
                }
            }
            
            // 根据周六或周日无课的天数对列数进行删减
            if ((i == 0 || i == 6) && list.count == 0) {
                columnsCount--;
            }
            
            // 将子列表添加到父列表
            listOfList.addObject(list);
        }
        
        // 确定好实际要显示的列数后，将每列数据交给子函数处理
        for (var i = 0, j = 0; i < 7; i++) {
            let list = listOfList[i] as! NSArray;
            if (list.count != 0 || i > 0 && i < 6) {
                setColumnData(list, // 这一列的数据
                    sidebar : sidebarDict,
                    columnIndex : j, // 该列在所有实际要显示的列中的序号
                    dayIndex : i, // 该列在所有列中的序号
                    dayDelta : i - dayOfWeek, // 该列的星期数与今天星期数之差
                    // 是否突出显示与今天同星期的列
                    widenToday : (dayOfWeek != 0 && dayOfWeek != 6 ||// TODO 当前周
                        listOfList[dayOfWeek].count != 0));
                j++;
            }
            
            // TODO 时间指示条
        }
    }
    
    // 绘制某一列的课表
    func setColumnData(list : NSArray, sidebar : NSDictionary,
        columnIndex : Int, dayIndex : Int, dayDelta : Int, widenToday : Bool) {
            let N = list.count;
            var addition : CGFloat = 0;
            if widenToday { addition = TODAY_WEIGHT - 1; }
            
            var x = CGFloat(columnIndex) * width / (CGFloat(columnsCount) + addition);
            if dayDelta > 0 { x += addition; }
            
            var w : CGFloat = 1 * width / (CGFloat(columnsCount) + addition);
            if(dayDelta == 0 && widenToday) {w = TODAY_WEIGHT;}
            
            // 绘制星期标题
            let v = UILabel(frame: CGRect(
                x : x ,
                y : topPadding,
                width : w ,
                height : height / CGFloat(PERIOD_COUNT + 1)
            ));
            v.text = WEEK_NUMS_CN[dayIndex];
            v.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8);
            v.textAlignment = .Center;
            v.font = UIFont(name: "HelveticaNeue", size: 14);
            v.backgroundColor = UIColor.whiteColor();
            self.view.addSubview(v);
            
            // 显示当天星期标题下面的高亮条
            if (widenToday && dayDelta == 0) {
                let v = UIView(frame: CGRect(x: x, y: topPadding + height / (CGFloat)(PERIOD_COUNT + 1) - 2, width: w, height: 3));
                v.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 1.0, alpha: 1);
                self.view.addSubview(v);
            }
            
            // 绘制每列的竖直分割线
            let v1 = UIView(frame: CGRect(x: x, y: topPadding, width: 1, height: height));
            v1.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1);
            self.view.addSubview(v1);
            
            // 绘制每节课的方块
            for (var i = 0; i < N; i++) {
                let info = list[i] as! ClassInfo;
                let block = MyUILabel(frame: CGRect(
                    x: x + 0.5,
                    y: topPadding + CGFloat(info.startTime) * height / CGFloat(PERIOD_COUNT + 1) + 0.5,
                    width: w - 1,
                    height: CGFloat(info.getPeriodCount()) * height / CGFloat(PERIOD_COUNT + 1) - 1
                ));
                
                block.text = info.className + "\n" + info.place;
                block.textColor = UIColor.whiteColor();
                block.textAlignment = .Center;
                block.font = UIFont(name: "HelveticaNeue", size: 13);
                block.lineBreakMode = .ByWordWrapping;
                block.numberOfLines = 0;
                var a = BLOCK_COLORS[(info.className.utf16.count + info.className.utf8.count * 2) % BLOCK_COLORS.count];
                block.layer.backgroundColor = UIColor(
                    red: CGFloat(a[0])/255.0,
                    green: CGFloat(a[1])/255.0,
                    blue: CGFloat(a[2])/255.0,
                    alpha: 1.0).CGColor;
                block.layer.cornerRadius = 3;
                
                block.root = self;
                let place = info.place
                    .stringByReplacingOccurrencesOfString("(单)", withString: "")
                    .stringByReplacingOccurrencesOfString("(双)", withString: "");
                block.info = "课程名称：\(info.className)\n上课地点：\(place)\n上课周次：\(info.startWeek)~\(info.endWeek)周";
                if(info.place.containsString("(单)")){block.info += "单周";}
                if(info.place.containsString("(双)")){block.info += "双周";}
                block.info += "\(info.weekNum)\n上课时间：\(info.startTime)~\(info.endTime)节 (\(info.getTimePeriod()))\n";
                if let additional = sidebar[info.className] as! String? {
                    block.info += additional;
                } else {
                    block.info += "获取教师及学分信息失败，请刷新";
                }
                
                block.userInteractionEnabled = true;
                let tapStepGestureRecognizer = UITapGestureRecognizer(target: block, action: Selector("showInfo"));
                block.addGestureRecognizer(tapStepGestureRecognizer);
                self.view.addSubview(block);
            }
    }
    
    /*************************
     * 实现::联网环节::工具函数
     *************************/

    func getWeekStamp() -> String {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-w";
        return dateFormatter.stringFromDate(NSDate());
    }
    
    func isRefreshNeeded() -> Bool {
        if let k = (sp.valueForKey("lastStart") as! String?) {
            return k != self.getWeekStamp() || self.view.subviews.count < 5;
        }
        return true;
    }
    
    func getUuid() -> String? {
        // 读取保存的uuid，若不存在，视为首次使用
        // 这里再写一遍是为了防止本函数在其他某些场合调用时，出现uuid不存在的情况而导致闪退
        let uuid = sp.valueForKey("uuid") as! String?;
        if(uuid == nil){
            showSettingsDialog("登录", message: "", cancelable: false);
        }
        return uuid;
    }
    
    func settings(){
        showSettingsDialog("更改用户", message: "", cancelable: true);
    }
    
    /*****************************
     * 实现::错误处理
     *****************************/

    func handleException(s : String) {
        showErrorMessage(exception : s);
    }
    
    func showErrorMessage(exception s : String){
        var message : String = "";
        if(s == "NumberFormatException" || s == "JSONException"){
            message = "获取到的数据不太对劲，莫非被飞贼掉包了？";
        } else if (s == "RunTimeException"){
            message = "密码好像错了，陛下再好好想想？";
        } else if (s == "ConnectException"){
            message = "连不上网了，陛下不妨重新试试？";
        } else if (s == "SocketTimeoutException"){
            // 服务器端出错
            message = "学校网络设施出现故障，暂时无法刷新";
        } else {
            message = "出现未知错误，陛下不妨重新试试？";
        }
        showErrorMessage(message : message);
    }
    
    func showErrorMessage(message s : String){
        showSettingsDialog("登录", message : s, cancelable : false);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}