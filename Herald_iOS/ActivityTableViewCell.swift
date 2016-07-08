import UIKit

/**
 * ActivityTableViewCell | 活动版块列表项视图
 */
class ActivityTableViewCell : NoSelectionTableViewCell {
    
    /// 活动标题
    @IBOutlet var title : UILabel!
    
    /// 活动所属组织
    @IBOutlet var assoc : UILabel!
    
    /// 活动进行状态
    @IBOutlet var state : UILabel!
    
    /// 活动图片
    @IBOutlet var pic : UIImageView!
    
    /// 活动介绍，包括时间地点和简介
    @IBOutlet var intro : UILabel!
    
    // 修正iPad端背景白色不透明的问题
    override func didMoveToSuperview() {
        self.backgroundColor = UIColor.clearColor()
        self.selectedBackgroundView = UIImageView(image: UIImage())
    }
}