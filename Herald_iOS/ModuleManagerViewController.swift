import Foundation
import UIKit

class ModuleManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable {
    
    @IBOutlet weak var moduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x12b0ec)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //每一个section里面有多少个Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Modules.count + 1
    }
    
    //初始化每一个Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return moduleTableView.dequeueReusableCell(withIdentifier: "ModuleManageTableHeaderCell", for: indexPath)
        } else {
            let moduleCell = moduleTableView.dequeueReusableCell(withIdentifier: "ModuleManageTableViewCell", for: indexPath) as! ModuleManageTableViewCell
        
            let module = Modules[indexPath.row - 1]
        
            moduleCell.module = module
            moduleCell.icon.image = UIImage(named: module.icon)
            moduleCell.label.text = module.nameTip
            moduleCell.shortcutSwitch.setOn(module.shortcutEnabled, animated: false)
            moduleCell.cardSwitch.setOn(module.cardEnabled, animated: false)
            moduleCell.cardSwitch.isEnabled = module.hasCard
            moduleCell.cardSwitch.alpha = module.hasCard ? 1 : 0
        
            return moduleCell
        }
    }
    
    //选中一个Cell后执行的方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
