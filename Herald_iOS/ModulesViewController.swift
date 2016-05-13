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
        
        //cell注册3D touch代理
        //因为cell的管理使用不是很完善，暂时删除内部cell按压预览
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: moduleTableView)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        setupModuleList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var enabledModules : [AppModule] = []
    var sections : [[AppModule]] = []
    
    func setupModuleList () {
        enabledModules.removeAll()
        sections.removeAll()
        let manager = AppModule(id: -1, name: "", nameTip : "模块管理", desc : "管理各模块的显示/隐藏状态",
                                controller : "MODULE_MANAGER", icon : "ic_add", hasCard : true)
        sections.append([manager])
        
        for k in SettingsHelper.MODULES {
            if SettingsHelper.getModuleShortcutEnabled(k.id) {
                enabledModules.append(k)
            }
        }
        
        if enabledModules.count > 0 {
            sections.append(enabledModules)
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
        
        //moduleCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return moduleCell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "我的模块"
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        sections[indexPath.section][indexPath.row].open(navigationController!)
    }
}


//3d touch遵守协议
extension ModulesViewController:UIViewControllerPreviewingDelegate {
    
    //peek
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        //通过触摸点的位置获取的是相对于moduleTableView的indexPath
        guard let indexPath = moduleTableView.indexPathForRowAtPoint(location) else {
                return nil
        }

        let cell = moduleTableView.cellForRowAtIndexPath(indexPath) as! ModuleTableViewCell
        
        previewingContext.sourceRect = cell.frame
        
        if cell.label!.text == "课表助手" || cell.label!.text == "模块管理" {
            return nil
        }
        
        if sections[indexPath.section][indexPath.row].controller.hasPrefix("http") {
            CacheHelper.set("herald_webmodule_title", sections[indexPath.section][indexPath.row].nameTip)
            CacheHelper.set("herald_webmodule_url", sections[indexPath.section][indexPath.row].controller)
            
            let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE")
            return detailVC
            //return nil
        }else {
            let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(sections[indexPath.section][indexPath.row].controller)
            detailVC.preferredContentSize = CGSizeMake(SCREEN_WIDTH, 600)
            return detailVC
        }
    }
    
    //pop
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
}

//屏幕宽度
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
