import Foundation
import UIKit

class ModulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var moduleTableView: UITableView!
    
    var parent : MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        moduleTableView.delegate = self
        self.view.backgroundColor = UIColor.whiteColor()
        moduleTableView.bounces = false
        
        setupModuleManager()
        self.moduleTableView.estimatedRowHeight=74;
        
        self.moduleTableView.rowHeight=UITableViewAutomaticDimension;
    }
    
    var tapGestureRecogniser:UITapGestureRecognizer!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupModuleManager() {
        let topManager = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 80))
        topManager.backgroundColor = UIColor.whiteColor()
        let img = UIImageView(image: UIImage(named: "ic_menu_manage"))
        img.frame = CGRectMake(26, 26, 25, 25)
        topManager.addSubview(img)
        
        let label = UILabel(frame: CGRect(x: 156, y: 26, width: 64, height: 22))
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor.blackColor()
        label.text = "模块管理"
        topManager.addSubview(label)
        
        moduleTableView.tableHeaderView = topManager
    }
    
    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsHelper.MODULES.count
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moduleCell = moduleTableView.dequeueReusableCellWithIdentifier("moduleCell", forIndexPath: indexPath) as! ModuleTableViewCell
        //moduleCell.selectionStyle = UITableViewCellSelectionStyle.None
        moduleCell.icon.image = UIImage(named: SettingsHelper.MODULES[indexPath.row].icon)
        moduleCell.label.text = SettingsHelper.MODULES[indexPath.row].nameTip
        moduleCell.detail.text = SettingsHelper.MODULES[indexPath.row].desc
        return moduleCell
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let vc = storyboard?.instantiateViewControllerWithIdentifier(SettingsHelper.MODULES[indexPath.row].controller) {
            parent?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
