import Foundation
import UIKit

class ModuleManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var moduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsHelper.getSeuModuleList().count + 1
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return moduleTableView.dequeueReusableCellWithIdentifier("ModuleManageTableHeaderCell", forIndexPath: indexPath)
        } else {
            let moduleCell = moduleTableView.dequeueReusableCellWithIdentifier("ModuleManageTableViewCell", forIndexPath: indexPath) as! ModuleManageTableViewCell
        
            let module = SettingsHelper.getSeuModuleList()[indexPath.row - 1]
        
            moduleCell.module = module.id
            moduleCell.icon.image = UIImage(named: module.icon)
            moduleCell.label.text = module.nameTip
            moduleCell.shortcutSwitch.setOn(module.shortcutEnabled, animated: false)
            moduleCell.cardSwitch.setOn(module.cardEnabled, animated: false)
            moduleCell.cardSwitch.enabled = module.hasCard
            moduleCell.cardSwitch.alpha = module.hasCard ? 1 : 0
        
            return moduleCell
        }
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
