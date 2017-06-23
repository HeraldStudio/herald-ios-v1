//
//  CardsCellVote.swift
//  Herald_iOS
//
//  Created by Vhyme on 2017/1/29.
//  Copyright © 2017年 HeraldStudio. All rights reserved.
//

import UIKit
import SwiftyJSON

class CardsCellVote : CardsTableViewCell {
    @IBOutlet weak var buttonPositive : UIButton!
    @IBOutlet weak var buttonNegative : UIButton!

    override func didMoveToSuperview() {
        selectionStyle = .none
        reloadData()
    }

    func reloadData() {
        buttonPositive.setTitle(
            " " + json["positive_verb"].stringValue
                + (json["voted"].boolValue ? " " + json["positive_count"].stringValue : ""),
            for: .normal)
        buttonNegative.setTitle(
            " " + json["negative_verb"].stringValue
                + (json["voted"].boolValue ? " " + json["negative_count"].stringValue : ""),
            for: .normal)
    }

    var json : JSON {
        get {
            return JSON.parse(ServiceHelper.get("versioncheck_cache"))["content"]["vote"]
        } set {
            var oldCache = JSON.parse(ServiceHelper.get("versioncheck_cache"))
            oldCache["content"]["vote"] = newValue
            ServiceHelper.set("versioncheck_cache", oldCache.rawStringValue)
        }
    }

    @IBAction func votePositive() {
        vote("positive")
    }

    @IBAction func voteNegative() {
        vote("negative")
    }

    func vote(_ attitude : String) { // 参数只能为"positive"或"negative"
        if json["voted"].boolValue {
            UIViewController.top?.showMessage("你已投票，不能重复投票")
        } else {
            ApiSimpleRequest(.post).url("http://myseu.cn/vote").uuid()
                .post("vote_id", json["id"].stringValue)
                .post("attitude", attitude).onResponse { success, code, response in
                    if success {
                        // 投票成功，将投票数据更新到缓存，并更新显示结果
                        self.json = JSON.parse(response)["content"]["vote"]
                        self.reloadData()
                    } else if let message = JSON.parse(response)["content"].string {
                        // 投票失败，显示服务器消息
                        UIViewController.top?.showMessage(message)
                    }
                }.run()
        }
    }
}
