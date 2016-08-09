import UIKit

class CurriculumPresetClassTableViewCell : UITableViewCell {
    
    @IBOutlet var className : UILabel!
    
    @IBOutlet var status : UILabel!
    
    @IBOutlet var info : UILabel!
    
    func setData (sidebarModel model : SidebarClassModel) {
        className.text = model.className
        status.text = model.strIsAdded
        info.text = model.desc
    }
}