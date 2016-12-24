import UIKit

class CurriculumFloatClassTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var className : UILabel!
    
    @IBOutlet var info : UILabel!
    
    func setData (sidebarModel model : SidebarClassModel) {
        className.text = model.className
        info.text = model.desc
    }
}

class CurriculumTermTableViewCell : UITableViewCell {
    
    @IBOutlet var termName : UILabel!
    
    @IBOutlet var termSummary : UILabel!
    
    func setData (term : TermModel) {
        termName.text = term.rawString
        termSummary.text = term.desc
    }
}

class CurriculumOptionTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var sw : UISwitch!
    
    @IBAction func switched () {
        onSwitch?()
    }
    
    var onSwitch : (() -> Void)?
}
