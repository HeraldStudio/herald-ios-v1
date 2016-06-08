import UIKit

class GameAvailableCardTableViewCell : UITableViewCell {
    @IBOutlet var cardPic : UIImageView!
    @IBOutlet var cardName : UILabel!
    @IBOutlet var desc : UILabel!
    @IBOutlet var add : UIButton!
    
    @IBAction func addFunc() {
        addAction()
    }
    
    var addAction = {() in }
}
