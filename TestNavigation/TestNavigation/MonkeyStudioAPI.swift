//
//  MonkeyStudioAPI.swift
//  TestNavigation
//
//  Created by Howie on 16/3/29.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit

typealias MonkeyCompletionHandler = (Dictionary<String,String>?, NSError?) -> Void

protocol WeatherServiceProtocol {
    func monkeyAPI(para: jsonPara, completionHandler: MonkeyCompletionHandler)
}

struct MonkeyGet:WeatherServiceProtocol {
    private let url = "http://115.28.27.150"
    private let uuid = "7993dee690677de934f8b1ca9a55cb555d5f0a0d"
    
    func monkeyAPI(para: jsonPara, completionHandler:MonkeyCompletionHandler) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://115.28.27.150/api/\(para)")!)
        request.HTTPMethod = "POST"
        var postString = "uuid=\(uuid)"
        var jsonDicName = [String]()
        var jsonKey = String()
        switch para {
            case .card:
                jsonDicName = cardJsonDicName
                jsonKey = "detial"
                postString += "&timedelta=7"
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    if error != nil {
                        print("error=\(error)")
                        return
                    }
                    let json = JSON(data: data!)
                    guard let getDict = json["content"]["\(jsonKey)"].array else {
                        return
                    }
                    cardLeft = Double(json["content"]["left"].string!)!
                    for index in 0..<getDict.count {
                        var one = Dictionary<String,String>()
                        for i in jsonDicName {
                            one[i] = "\(getDict[index][i])"
                        }
                        cardInfo.append(one)
                    }
                }
                task.resume()
                break
            case .jwc:
                //jsonDic = ["date","href","title"]
                jsonKey = "教务信息"
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    if error != nil {
                        print("error=\(error)")
                        return
                    }
                    let json = JSON(data: data!)
                    guard let getDict = json["content"]["\(jsonKey)"].array else {
                        return
                    }
                    
                    for index in 0..<getDict.count {
                        var one = Dictionary<String,String>()
                        for i in jsonDicName {
                            one[i] = "\(getDict[index][i])"
                        }
                        cardInfo.append(one)
                    }
                    //print(cardInfo)
                }
                task.resume()
                break
            case .sideBar:
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    if error != nil {
                        print("error=\(error)")
                        return
                    }
                    let side = JSON(data: data!)["content"]
                    
                    var sidebar = [SideBar]()
                    
                    // 解析
                    for i in 0..<side.count {
                        let get = SideBar(lecturer: side[i]["lecturer"].string!,
                                             course: side[i]["course"].string!,
                                             week: side[i]["week"].string!,
                                             credit: side[i]["credit"].string!)
                        sidebar.append(get)
                    }
                    
                    //保存课表
                    let savedData = NSKeyedArchiver.archivedDataWithRootObject(sidebar)
                    defaults.setObject(savedData, forKey: "people")
                    defaults.synchronize();
                }
                task.resume()
                break
            default:
                break
        }
        
    }
    
    func getWeekStamp() -> String {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-w";
        return dateFormatter.stringFromDate(NSDate());
    }
}