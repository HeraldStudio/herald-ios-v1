import UIKit

class NoSelectionTableViewCell : UITableViewCell {
    override func didMoveToSuperview() {
        selectionStyle = .None
    }
}
