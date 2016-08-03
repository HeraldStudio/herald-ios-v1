import SwiftyJSON

/// 表示登录用户的类
class User {
    var userName : String
    var password : String
    var uuid : String
    var schoolNum : String
    
    init(_ userName: String, _ password: String, _ uuid: String, _ schoolNum: String) {
        self.userName = userName
        self.password = password
        self.uuid = uuid
        self.schoolNum = schoolNum
    }
    
    convenience init(_ json : JSON) {
        self.init(json["userName"].stringValue,
                  json["password"].stringValue,
                  json["uuid"].stringValue,
                  json["schoolNum"].stringValue)
        
        /// 未登录状态
        if userName == "" || uuid == "" || schoolNum == "" {
            userName = trialUser.userName
            password = trialUser.password
            uuid = trialUser.uuid
            schoolNum = trialUser.schoolNum
        }
    }
    
    func toJson() -> JSON {
        return JSON([
            "userName" : userName,
            "password" : password,
            "uuid" : uuid,
            "schoolNum" : schoolNum
            ])
    }
}

func == (left: User, right: User) -> Bool {
    return left.toJson() == right.toJson()
}

func != (left: User, right: User) -> Bool {
    return left.toJson() != right.toJson()
}

let trialUser = User("000000000", "", "0000000000000000000000000000000000000000", "00000000")
