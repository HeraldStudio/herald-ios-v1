import UIKit

class GymReserveRecordTableViewCell : UITableViewCell {
    @IBOutlet var title : UILabel!
    @IBOutlet var desc : UILabel!
    @IBOutlet var state : UILabel!
}

class GymReserveTableViewHeader : NoSelectionTableViewCell {
    @IBOutlet var picker : UISegmentedControl!
}

class GymReserveTableViewCell : UITableViewCell {
    
    @IBOutlet var name : UILabel!
    
    @IBOutlet var action : UILabel!
    
    func setEnabled (enabled : Bool) {
        name.alpha = enabled ? 1 : 0.3
        action.hidden = !enabled
        userInteractionEnabled = enabled
    }
}

class GymNewStaticCellTime : NoSelectionTableViewCell {
    @IBOutlet var time : UILabel!
}

class GymNewStaticCellHalf : NoSelectionTableViewCell {
    @IBOutlet var half : UISwitch!
    
    @IBAction func switchHalf() {
        switchAction()
    }
    
    var switchAction = { () in }
}

class GymNewStaticCellPhone : NoSelectionTableViewCell {
    @IBOutlet var phone : UITextField!
}

class GymNewInvitedFriendCell : NoSelectionTableViewCell {
    
    @IBOutlet var name : UILabel!
    
    @IBAction func remove () {
        removeAction()
    }
    
    var removeAction = { () in }
}

class GymNewFriendCell : NoSelectionTableViewCell {
    
    @IBOutlet var name : UILabel!
    
    @IBOutlet var department : UILabel!
    
    @IBAction func add () {
        addAction()
    }
    
    var addAction = { () in }
    
    @IBAction func delete () {
        deleteAction()
    }
    
    var deleteAction = { () in }
}

class GymFriendResultCell : NoSelectionTableViewCell {
    
    @IBOutlet var name : UILabel!
    
    @IBOutlet var department : UILabel!
    
    @IBOutlet var button : UIButton!
    
    @IBAction func toggle () {
        toggleAction()
    }
    
    var toggleAction = { () in }
}