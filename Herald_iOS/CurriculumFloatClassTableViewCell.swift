import UIKit

class CurriculumFloatClassTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var className : UILabel!
    
    @IBOutlet var info : UILabel!
    
    func setData (sidebarModel model : SidebarClassModel) {
        className.text = model.className
        info.text = model.desc
    }
}