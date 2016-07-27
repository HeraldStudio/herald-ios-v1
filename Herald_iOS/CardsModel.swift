import UIKit

/**
 * CardsModel | 首页卡片模型
 * 首页卡片列表每一个分区（代表一个卡片）的模型，这里只需要用来存储每一行的数据、
 * 用来排序、以及用来存储点击卡片时打开的页面
 */
class CardsModel {
    
    /// 表示卡片消息是否重要，不重要的消息总在后面
    enum Priority : Int {
        
        /// 具有时效性的内容
        case CONTENT_NOTIFY
        
        /// 有内容，但不具有时效性
        case CONTENT_NO_NOTIFY
        
        /// 没有内容
        case NO_CONTENT
    }
    
    /// 除卡片头部外，其他行所用的资源复用id
    var cellId : String
    
    /// 每一行的模型（含头部）
    var rows : [CardsRowModel] = []
    
    /// 该卡片本身内容的优先级
    var contentPriority : Priority = .NO_CONTENT
    
    /// 该卡片实际显示的优先级
    var displayPriority : Priority {
        if contentPriority == .CONTENT_NOTIFY && isRead() {
            return .CONTENT_NO_NOTIFY
        }
        return contentPriority
    }
    
    /// 从已有的模块初始化一个卡片
    init (cellId: String, module : AppModule, desc : String, priority : Priority) {
        self.cellId = cellId
        let appModule = module
        let header = CardsRowModel()
        header.icon = appModule.icon
        header.title = appModule.nameTip
        header.desc = desc
        header.destination = appModule.destination
        header.needLogin = appModule.needLogin
        rows.append(header)
        self.contentPriority = priority
    }
    
    /// 用自定义的项目初始化一个卡片
    init (cellId: String, icon : String, title : String, desc : String, dest : String, message : String, priority : Priority) {
        self.cellId = cellId
        let header = CardsRowModel()
        header.icon = icon
        header.title = title
        header.desc = desc
        header.destination = dest
        header.message = message
        rows.append(header)
        self.contentPriority = priority
    }
    
    /// 用一个字符串表示所有内容，用来判断两个卡片是否相等，以便于计算卡片消息是否已读
    var stringValue : String {
        var ret = ""
        for row in rows {
            ret += row.stringValue
        }
        return String(ret.hashValue)
    }
    
    /// 标记为已读
    func markAsRead () {
        CacheHelper.set("herald_cards_read_\(cellId)", stringValue)
    }
    
    /// 判断是否已读
    func isRead () -> Bool {
        return CacheHelper.get("herald_cards_read_\(cellId)") == stringValue
    }
}