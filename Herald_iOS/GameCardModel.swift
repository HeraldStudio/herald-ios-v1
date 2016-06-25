import SwiftyJSON

/**
 * GameCardModel | 桌游助手卡片数据模型
 **/
class GameCardModel {
    
    /// 卡牌名称
    var name : String
    
    /// 卡牌详细信息
    var desc : String
    
    /// 卡牌图片地址
    var pic : String
    
    /// 卡牌数量
    var count : Int
    
    /// 通过 JSON 构造
    /// 兼容数据：http://app.heraldstudio.com/api/deskgame/cardlist
    init (json : JSON) {
        name = json["name"].stringValue
        desc = json["desc"].stringValue
        pic = json["pic"].stringValue
        count = 1
    }
    
    /// 通过自定义卡牌名称构造备用牌
    init (name : String) {
        self.name = name
        desc = ""
        pic = ""
        count = 1
    }
    
    /// 不考虑张数，返回单张卡牌的 JSON 数据
    func eachCardToJSON () -> JSON {
        return JSON(["name": name, "desc": desc, "pic": pic])
    }
}

/// 比较运算符，用于判断两张卡片是否相同
//- 在选择卡牌的列表中点击添加，将会逐一判断已有的卡牌中是否有相同卡牌，如果有，只需增加其张数，而不必构造新的数据
func == (left: GameCardModel, right: GameCardModel) -> Bool {
    return left.name == right.name && left.desc == right.desc && left.pic == right.pic
}