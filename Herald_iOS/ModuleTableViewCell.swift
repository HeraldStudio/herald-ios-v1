import UIKit

/**
 * ModuleTableViewCell | 模块列表项视图
 */
class ModuleTableViewCell: UITableViewCell {
    
    /// 模块图标
    @IBOutlet weak var icon: UIImageView!
    
    /// 模块标题
    @IBOutlet weak var label: UILabel!
    
    /// 模块介绍
    @IBOutlet weak var detail: UILabel!
}
