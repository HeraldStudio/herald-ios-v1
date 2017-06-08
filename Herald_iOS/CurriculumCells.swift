import UIKit

class CurriculumFloatClassTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var className : UILabel!
    
    @IBOutlet var info : UILabel!
    
    static func instance (for tableView: UITableView, sidebarModel model : SidebarClassModel) -> CurriculumFloatClassTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumFloatClassTableViewCell") as! CurriculumFloatClassTableViewCell
        cell.className.text = model.className
        cell.info.text = model.desc
        return cell
    }
}

class CurriculumTermTableViewCell : UITableViewCell {
    
    @IBOutlet var termName : UILabel!
    
    @IBOutlet var termSummary : UILabel!
    
    static func instance (for tableView: UITableView, termModel : TermModel) -> CurriculumTermTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTermTableViewCell") as! CurriculumTermTableViewCell
        cell.termName.text = termModel.rawString
        cell.termSummary.text = termModel.desc
        return cell
    }
}

class CurriculumOptionTableViewCell : NoSelectionTableViewCell {
    
    @IBOutlet var sw : UISwitch!
    @IBAction func switched () {
        onSwitch?()
    }
    
    var onSwitch : (() -> Void)?
    
    static func instance (for tableView: UITableView, state: Bool, onSwitch : (() -> Void)?) -> CurriculumOptionTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumOptionTableViewCell") as! CurriculumOptionTableViewCell
        cell.onSwitch = onSwitch
        cell.sw.isOn = state
        return cell
    }
}
