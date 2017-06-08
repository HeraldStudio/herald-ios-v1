import UIKit

/**
 * 无点击效果的列表项类
 **/
class NoSelectionTableViewCell : UITableViewCell {
    override func didMoveToSuperview() {
        selectionStyle = .none
    }
}
