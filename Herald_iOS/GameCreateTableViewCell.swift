import UIKit

/**
 * GameCreateTableViewCell | 表示已选择的牌的视图
 **/
class GameCreateTableViewCell : NoSelectionTableViewCell {
    
    /// 已绑定：卡牌名称
    @IBOutlet var cardName : UILabel!
    
    /// 已绑定：增加按钮
    @IBOutlet var add : UIButton!
    
    /// 已绑定：减少按钮
    @IBOutlet var remove : UIButton!
    
    /// 已绑定：增加按钮点击事件
    @IBAction func addFunc() {
        addAction()
    }
    
    // 可自由设置的闭包，将被增加按钮点击事件调用
    var addAction = {() in }
    
    /// 已绑定：减少按钮点击事件
    @IBAction func removeFunc() {
        removeAction()
    }
    
    // 可自由设置的闭包，将被减少按钮点击事件调用
    var removeAction = {() in }
}
