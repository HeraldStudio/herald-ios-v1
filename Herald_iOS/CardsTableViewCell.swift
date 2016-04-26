//
//  CardsTableViewCell
//  TestNavigation
//
//  Created by Howie on 16/3/29.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit
import SWTableViewCell

/// 首页卡片中每一行（代表卡片头部或卡片中的一格）通用的视图
class CardsTableViewCell: UITableViewCell /*SWTableViewCell, SWTableViewCellDelegate*/ {
    
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
    
    /// 考试的倒计时天数、跑操的已跑次数
    @IBOutlet var count1 : UILabel?
    
    /// 跑操的剩余次数
    @IBOutlet var count2 : UILabel?
    
    /// 跑操的剩余天数
    @IBOutlet var count3 : UILabel?
    /*
    
    var onRead : (() -> Void)?
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        onRead?()
    }*/
}
