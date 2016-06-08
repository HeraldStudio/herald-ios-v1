import UIKit

class GameCreateTableViewCell : NoSelectionTableViewCell {
    @IBOutlet var cardName : UILabel!
    @IBOutlet var add : UIButton!
    @IBOutlet var remove : UIButton!
    
    @IBAction func addFunc() {
        addAction()
    }
    
    var addAction = {() in }
    
    @IBAction func removeFunc() {
        removeAction()
    }
    
    var removeAction = {() in }
}
