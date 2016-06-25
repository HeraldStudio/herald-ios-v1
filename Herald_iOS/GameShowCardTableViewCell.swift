import UIKit

/**
 * GameShowCardTableViewCell | 表示已抽到的牌或要显示详情的牌的视图
 * 注意：此视图与 GameShowCardViewController 同样可两用。
 **/
class GameShowCardTableViewCell : NoSelectionTableViewCell {
    
    /// 已绑定：卡片图片
    @IBOutlet var cardPic : UIImageView!
    
    /// 已绑定：卡片名称
    @IBOutlet var cardName : UILabel!
    
    /// 已绑定：卡片说明文字
    @IBOutlet var desc : UILabel!
}
