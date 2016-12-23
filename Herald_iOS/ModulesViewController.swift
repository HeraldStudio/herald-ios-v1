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
            if traitCollection.forceTouchCapability == .available {
                self.registerForPreviewing(with: self, sourceView: moduleTableView)
            }
        }
        
        // 当模块设置改变时刷新
        SettingsHelper.addModuleSettingsChangeListener {
            self.setupModuleList()
        }
        
        ApiHelper.addUserChangedListener { 
            self.setupModuleList()
        }
    }
    
    /// 当准备从其它界面返回时，设置导航栏颜色
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x12b0ec)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /// 列表某分区中条目数目
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    /// 实例化列表条目
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        // 实例化
        let moduleCell = moduleTableView.dequeueReusableCell(withIdentifier: "ModuleTableViewCell", for: indexPath) as! ModuleTableViewCell
        
        let module = sections[indexPath.section][indexPath.row]
        
        // 数据绑定
        moduleCell.icon.image = UIImage(named: module.icon)
        moduleCell.label.text = module.nameTip
        moduleCell.detail.text = module.desc
        
        return moduleCell
    }
    
    /// 列表分区标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "已启用的模块"
    }
    
    /// 模块列表部分：模块列表代理
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 自定义列表条目点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 打开对应的模块
        sections[indexPath.section][indexPath.row].open()
    }
}


//3d touch遵守协议
extension ModulesViewController:UIViewControllerPreviewingDelegate {
    
    //peek
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        //通过触摸点的位置获取的是相对于moduleTableView的indexPath
        guard let indexPath = moduleTableView.indexPathForRow(at: location) else {
                return nil
        }

        let cell = moduleTableView.cellForRow(at: indexPath) as! ModuleTableViewCell
        
        previewingContext.sourceRect = cell.frame
        
        return sections[indexPath.section][indexPath.row].getPreviewViewController()
    }
    
    //pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

//屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
