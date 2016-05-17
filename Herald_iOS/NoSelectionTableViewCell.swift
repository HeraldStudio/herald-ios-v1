import UIKit

class NoSelectionTableViewCell : UITableViewCell {
    override func didMoveToSuperview() {
        selectedBackgroundView = UIImageView(image: UIImage())
    }
}
