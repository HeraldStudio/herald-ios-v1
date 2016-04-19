import Foundation
import UIKit

class ModulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var moduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        moduleTableView.delegate = self
        self.view.backgroundColor = UIColor.whiteColor()
        //moduleTableView.bounces = false
        
        setupModuleManager()
        setupModuleList()
        
        self.moduleTableView.estimatedRowHeight=74;
        
        self.moduleTableView.rowHeight=UITableViewAutomaticDimension;
    }
    
    var tapGestureRecogniser:UITapGestureRecognizer!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupModuleManager() {
        let topManager = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 65))
        topManager.backgroundColor = UIColor.whiteColor()
        let img = UIImageView(image: UIImage(named: "ic_menu_manage"))
        img.frame = CGRectMake(21, 21, 25, 25)
        topManager.addSubview(img)
        
        let label = UILabel(frame: CGRect(x: 156, y: 21, width: 64, height: 22))
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor.darkTextColor()
        label.text = "模块管理"
        topManager.addSubview(label)
        
        moduleTableView.tableHeaderView = topManager
        
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        moduleTableView.tableFooterView = bottomPadding
    }
    
    var enabledModules : [AppModule] = []
    var disabledModules : [AppModule] = []
    var sections : [[AppModule]] = []
    var sectionEnabled : [Bool] = []
    
    func setupModuleList () {
        enabledModules.removeAll()
        disabledModules.removeAll()
        
        for k in SettingsHelper.getSeuModuleList() {
            if k.cardEnabled || k.shortcutEnabled {
                enabledModules.append(k)
                if enabledModules.count == 1 {
                    sectionEnabled.append(true)
                }
            } else {
                disabledModules.append(k)
                if disabledModules.count == 1 {
                    sectionEnabled.append(false)
                }
            }
        }
        for z in sectionEnabled {
            if z {
                sections.append(enabledModules)
            } else {
                sections.append(disabledModules)
            }
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
        let moduleCell = moduleTableView.dequeueReusableCellWithIdentifier("moduleCell", forIndexPath: indexPath) as! ModuleTableViewCell
        
        let module = sections[indexPath.section][indexPath.row]
        
        moduleCell.icon.image = UIImage(named: module.icon)
        moduleCell.label.text = module.nameTip
        moduleCell.detail.text = module.desc
        return moduleCell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionEnabled[section] ? "显示在卡片或快捷栏的模块" : "完全隐藏的模块"
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let controller = SettingsHelper.MODULES[indexPath.row].controller
        
        if controller.containsString("http") {
            UIApplication.sharedApplication().openURL(NSURL(string: controller)!)
        } else if let vc = storyboard?.instantiateViewControllerWithIdentifier(controller) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
