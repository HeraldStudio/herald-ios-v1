import Foundation
import UIKit

class ModulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var moduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moduleTableView.estimatedRowHeight = 74;
        self.moduleTableView.rowHeight = UITableViewAutomaticDimension;
        
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        moduleTableView.tableFooterView = bottomPadding
    }
    
    override func viewDidAppear(animated: Bool) {
        setupModuleList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var enabledModules : [AppModule] = []
    var disabledModules : [AppModule] = []
    var sections : [[AppModule]] = []
    var sectionTitles : [String] = []
    
    func setupModuleList () {
        enabledModules.removeAll()
        disabledModules.removeAll()
        sections.removeAll()
        sectionTitles.removeAll()
        
        sectionTitles.append("")
        let manager = AppModule(id: -1, name: "", nameTip : "模块管理", desc : "管理各模块的显示/隐藏状态",
                                controller : "MODULE_MANAGER", icon : "ic_add", hasCard : true)
        manager.shortcutEnabled = true
        sections.append([manager])
        
        for k in SettingsHelper.getSeuModuleList() {
            if k.cardEnabled || k.shortcutEnabled {
                enabledModules.append(k)
                if enabledModules.count == 1 {
                    sectionTitles.append("显示在卡片或快捷栏的模块")
                }
            } else {
                disabledModules.append(k)
                if disabledModules.count == 1 {
                    sectionTitles.append("完全隐藏的模块")
                }
            }
        }
        
        if enabledModules.count > 0 {
            sections.append(enabledModules)
        }
        if disabledModules.count > 0 {
            sections.append(disabledModules)
        }
        moduleTableView.reloadData()
    }
    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moduleCell = moduleTableView.dequeueReusableCellWithIdentifier("ModuleTableViewCell", forIndexPath: indexPath) as! ModuleTableViewCell
        
        let module = sections[indexPath.section][indexPath.row]
        
        moduleCell.icon.image = UIImage(named: module.icon)
        moduleCell.label.text = module.nameTip
        moduleCell.detail.text = module.desc
        return moduleCell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        sections[indexPath.section][indexPath.row].open(navigationController!)
    }
}
