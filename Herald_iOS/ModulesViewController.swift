import UIKit

/**
 * ModulesViewController | 模块列表界面，模块列表视图代理和数据源
 * 负责模块列表视图以及模块管理按钮的处理
 */
class ModulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 整体部分：初始化、模块管理按钮
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 绑定的列表视图
    @IBOutlet weak var moduleTableView: UITableView!
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 为列表视图设置自适应高度
        self.moduleTableView.estimatedRowHeight = 74;
        self.moduleTableView.rowHeight = UITableViewAutomaticDimension;
        
        // 为列表视图添加底部 padding，防止滚动到底部时部分内容被 TabBar 覆盖
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        moduleTableView.tableFooterView = bottomPadding
        
        // 载入模块列表
        setupModuleList()
        
        //cell注册3D touch代理
        //因为cell的管理使用不是很完善，暂时删除内部cell按压预览
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: moduleTableView)
            }
        }
        
        // 当模块设置改变时刷新
        SettingsHelper.addModuleSettingsChangeListener {
            
            // 若未登录，不作操作
            if !ApiHelper.isLogin() {
                return
            }
            
            self.setupModuleList()
        }
    }
    
    /// 当准备从其它界面返回时，设置导航栏颜色
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0x00b4ff)
    }
    
    /// 加载模块列表
    func setupModuleList () {
        
        // 清空列表原有数据
        sections.removeAll()
        
        // 第二个分区的模块列表
        var enabledModules : [AppModule] = []
        
        // 将模块管理伪装成一个模块加入到第一个分区中，并将这个分区加入到列表中
        sections.append([ModuleManager])
        
        // 将各个模块加入到第二个分区中
        for k in Modules {
            if k.shortcutEnabled || k.cardEnabled {
                enabledModules.append(k)
            }
        }
        
        // 如果非空，将第二个分区加入到列表中
        if enabledModules.count > 0 {
            sections.append(enabledModules)
        }
        
        // 显式调用表格重载数据
        moduleTableView.reloadData()
    }
    
    /// 模块列表部分：模块列表数据源
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 模块列表
    var sections : [[AppModule]] = []
    
    /// 列表分区数目
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    /// 列表某分区中条目数目
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    /// 实例化列表条目
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 实例化
        let moduleCell = moduleTableView.dequeueReusableCellWithIdentifier("ModuleTableViewCell", forIndexPath: indexPath) as! ModuleTableViewCell
        
        let module = sections[indexPath.section][indexPath.row]
        
        // 数据绑定
        moduleCell.icon.image = UIImage(named: module.icon)
        moduleCell.label.text = module.nameTip
        moduleCell.detail.text = module.desc
        
        return moduleCell
    }
    
    /// 列表分区标题
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "已启用的模块"
    }
    
    /// 模块列表部分：模块列表代理
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 自定义列表条目点击事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 打开对应的模块
        sections[indexPath.section][indexPath.row].open()
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
            let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WEBMODULE") as! WebModuleViewController
            
            detailVC.title = sections[indexPath.section][indexPath.row].nameTip
            detailVC.url = sections[indexPath.section][indexPath.row].controller
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
