import UIKit

/**
 * CardsTableViewCell | 首页卡片列表项视图
 * 首页卡片中每一行（代表卡片头部或卡片中的一格）通用的视图
 */
class CardsTableViewCell: UITableViewCell {
    
    /// 卡片头部的模块图标
    @IBOutlet var icon : UIImageView?
    
    /// 卡片头部的提示圆点
    @IBOutlet var notifyDot : UIImageView?
    
    /// 卡片头部的模块名称，以及课表、实验、考试、讲座、通知的大标题
    @IBOutlet var title : UILabel?
    
    /// 课表、实验的授课教师，考试的时长，讲座的主讲人
    @IBOutlet var subtitle : UILabel?
    
    /// 卡片头部的内容，课表、实验、考试、讲座的时间地点，通知的发布日期
    @IBOutlet var desc : UILabel?
    
    /// 考试的倒计时天数
    @IBOutlet var count0 : UILabel?
    
    /// 跑操的已跑次数
    @IBOutlet var count1 : UILabel?
    
    /// 跑操的剩余次数
    @IBOutlet var count2 : UILabel?
    
    /// 跑操的剩余天数
    @IBOutlet var count3 : UILabel?
    
    /// 向右的箭头，如果没有destination，应当隐藏这个箭头
    @IBOutlet var arrow : UIView?
}
