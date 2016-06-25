import UIKit

/**
 * GameAvailableCardTableViewCell | 表示可用牌集中的牌的视图
 **/
class GameAvailableCardTableViewCell : UITableViewCell {
    
    /// 已绑定：卡片图片
    @IBOutlet var cardPic : UIImageView!
    
    /// 已绑定：卡片名称
    @IBOutlet var cardName : UILabel!
    
    /// 已绑定：卡片说明文字
    @IBOutlet var desc : UILabel!
    
    /// 已绑定：添加按钮
    @IBOutlet var add : UIButton!
    
    /// 已绑定：添加按钮点击事件
    @IBAction func addFunc() {
        addAction()
    }
    
    // 可自由设置的闭包，将被添加按钮点击事件调用
    var addAction = {() in }
}
