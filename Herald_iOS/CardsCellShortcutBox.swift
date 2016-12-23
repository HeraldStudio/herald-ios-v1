import UIKit

class CardsCellShortcutBox : CardsTableViewCell {
    override func didMoveToSuperview() {
        selectionStyle = .none
    }
}
