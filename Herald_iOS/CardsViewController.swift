import UIKit
import SDWebImage
import SwiftyJSON
import ZYBannerView

/**
 * CardsViewController | 首页卡片界面，首页卡片列表视图代理和数据源
 * 负责首页卡片列表视图、轮播图、集成下拉刷新的处理
 */
class CardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ZYBannerViewDataSource, ZYBannerViewDelegate {
    
    /// 整体部分：初始化、轮播图、集成下拉刷新
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 绑定的列表视图
    @IBOutlet var cardsTableView: UITableView!
    
    /// 轮播图视图
    let slider = ZYBannerView()
    
    /// 下拉刷新视图
    let swiper = SwipeRefreshHeader()
    
    /// 轮播图的数据，用于比较当前数据与新数据是否一致，不一致则重载轮播图
    /// 避免轮播图在刷新过程中出现不必要的闪烁，起到缓冲的作用
    var sliderData = JSON.parse("[]")
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 为列表视图添加底部 padding，防止滚动到底部时部分内容被 TabBar 覆盖
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        cardsTableView.tableFooterView = bottomPadding
        
        // 为列表视图设置自适应高度
        cardsTableView.estimatedRowHeight = 120;
        cardsTableView.rowHeight = UITableViewAutomaticDimension;
        
        // 初始化轮播图和下拉刷新
        setupHeaders()
        
        // 解析本地缓存，重载卡片内容
        loadContent(false)
        
        // 联网刷新列表内容
        loadContent(true)
        
        // 启动定时刷新，每当时间改变时触发本地重载
        let seconds = 60 - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60)
        perform(#selector(self.timeChanged), with: nil, afterDelay: seconds)
        
        // 注册 3D Touch Peak 事件代理
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                self.registerForPreviewing(with: self, sourceView: cardsTableView)
            }
        }
        
        // 当模块设置改变时重载数据
        SettingsHelper.addModuleSettingsChangeListener {
            self.loadContent(false)
        }
        
        // 当用户改变时联网刷新
        ApiHelper.addUserChangedListener { 
            self.loadContent(true)
        }
    }
    
    /// 当准备从其它界面返回时，设置导航栏颜色
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x12b0ec)
    }
    
    /// 当从其他界面返回时，重载数据
    override func viewDidAppear(_ animated: Bool) {
        loadContent(false)
    }
    
    /// 定时刷新，即每当时间改变时重新解析本地缓存，并加载卡片内容
    func timeChanged() {
        
        // 解析本地缓存，重载卡片内容
        loadContent(false)
        
        // 到下一分钟的剩余秒数，这里虽然接近 60，但是不写死，防止误差累积
        let seconds = 60 - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60)
        perform(#selector(self.timeChanged), with: nil, afterDelay: seconds)
    }
    
    /// 初始化轮播图、下拉刷新控件和快捷栏
    func setupHeaders () {
        
        /// 初始化轮播图
        
        // 轮播图宽高比 5:2
        slider.frame = CGRect(x: 0, y: 0,
                                   width: AppDelegate.instance.leftController!.view.frame.width,
                                   height: AppDelegate.instance.leftController!.view.frame.width * CGFloat(0.4))
        
        slider.dataSource = self
        
        slider.delegate = self
        
        slider.shouldLoop = true
        
        // 轮播图自动切换间隔 5秒
        slider.scrollInterval = 5
        
        /// 初始化下拉刷新控件
        
        // 设置轮播图为下拉刷新控件内嵌视图
        swiper.contentView = slider
        
        // 设置下拉刷新控件刷新事件
        swiper.refresher = {() in
            
            // 此处为了防止列表立即刷新导致列表在下拉后突然弹回，延迟1秒刷新，加载框提前显示
            self.showProgressDialog()
            self.perform(#selector(self.refresh), with: nil, afterDelay: 1)
        }
        
        // 设置下拉刷新控件为列表页头视图
        cardsTableView.tableHeaderView = swiper
    }
    
    func numberOfItems(inBanner banner: ZYBannerView!) -> Int {
        return max(1, pics.count)
    }
    
    func banner(_ banner: ZYBannerView!, didSelectItemAt index: Int) {
        if pics.count == 0 {
            return
        }
        AppModule(title: self.titles[index], url: self.links[index]).open()
    }
    
    func banner(_ banner: ZYBannerView!, viewForItemAt index: Int) -> UIView! {
        if pics.count == 0 {
            return UIImageView(image: UIImage(named: "default_herald"))
        }
        let view = UIImageView()
        if let url = URL(string: pics[index]) {
            view.sd_setImage(with: url, placeholderImage: UIImage(named: "default_herald"))
        }
        return view
    }
    
    /// 下拉刷新控件用到的刷新函数
    func refresh () {
        loadContent(true)
    }
    
    /// 下拉刷新控件用到的三个 hook
    // 滚动时刷新显示
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        swiper.syncApperance()
    }
    
    // 开始拖动，以下两个函数用于让下拉刷新控件判断是否已经松手，保证不会在松手后出现“[REFRESH]”
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    // 结束拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    /// 各个轮播图点击时打开的链接
    var links : [String] = []
    
    /// 各个轮播图点击时打开的页面标题
    var titles : [String] = []
    
    /// 各个轮播图的图片地址
    var pics : [String] = []
    
    /// 判断轮播图数据是否变化，若变化，重载轮播图
    func refreshSliderIfNeeded () {
        let cache = JSON.parse(ServiceHelper.get("versioncheck_cache"))
        let array = cache["content"]["sliderviews"]
        if sliderData != array {
            refreshSlider()
        }
    }
    
    /// 直接重载轮播图
    func refreshSlider () {
        let cache = JSON.parse(ServiceHelper.get("versioncheck_cache"))
        let array = cache["content"]["sliderviews"]
        
        // 同步缓冲数据，以便下一次判断
        sliderData = array
        
        // 清空链接列表
        links.removeAll()
        
        // 清空标题列表
        titles.removeAll()
        
        // 清空图片列表
        pics.removeAll()
        
        // 逐个添加图片和对应链接
        for i in 0 ..< array.count {
            let pic = array[i]
            if let url = pic["imageurl"].string {
                pics.append(url)
                
                links.append(pic["url"].stringValue)
                
                var title = pic["title"].stringValue
                if title == "" {
                    title = "小猴偷米"
                }
                titles.append(title)
            }
        }
        
        // 若无图片，新增一个空图片
        if pics.count == 0 {
            pics.append("")
            links.append("")
            titles.append("")
        }
        // 设置为轮播图的图片列表
        slider.reloadData()
        // 若轮播图只有1张图，停止滚动
        slider.autoScroll = pics.count > 1
    }
    
    /// 卡片列表部分：卡片刷新
    /////////////////////////////////////////////////////////////////////////////////////
    
    func loadContent (_ refresh : Bool) {
        /// 本地重载
        // 若需要，重载轮播图
        refreshSliderIfNeeded()
        
        // 清空卡片列表，等待载入
        cardList.removeAll()
        
        // 添加快捷栏
        cardList.append(ShortcutCard.getCard())
        
        // 加载版本更新缓存
        if let item = ServiceCard.getCheckVersionCard() {
            cardList.append(item)
        }
        
        // 加载推送缓存
        if let item = ServiceCard.getPushMessageCard() {
            cardList.append(item)
        }
        
        // 加载投票缓存
        if let item = ServiceCard.getVoteCard() {
            cardList.append(item)
        }
        
        if ModuleCard.cardEnabled {
            // 加载并解析一卡通缓存
            cardList.append(CardCard.getCard())
        }
        
        if ModulePedetail.cardEnabled {
            // 加载并解析跑操预报缓存
            cardList.append(PedetailCard.getCard())
        }
        
        // 判断各模块是否开启并加载对应数据
        if ModuleCurriculum.cardEnabled {
            // 加载并解析课表缓存
            cardList.append(CurriculumCard.getCard())
        }
        
        if ModuleExperiment.cardEnabled {
            // 加载并解析实验缓存
            cardList.append(ExperimentCard.getCard())
        }
        
        if ModuleExam.cardEnabled {
            // 加载并解析考试缓存
            cardList.append(ExamCard.getCard())
        }
        
        // 加载校园活动缓存
        cardList.append(ActivityCard.getCard())
        
        if ModuleLecture.cardEnabled {
            // 加载并解析人文讲座预告缓存
            cardList.append(LectureCard.getCard())
        }
        
        if ModuleJwc.cardEnabled {
            // 加载并解析教务通知缓存
            cardList.append(JwcCard.getCard())
        }
        
        // 有消息且未读的排在前面，没消息或已读的排在后面
        cardList = cardList.sorted {$0.displayPriority.rawValue < $1.displayPriority.rawValue}
        
        // 更新数据源，结束刷新
        cardsTableView.reloadData()
        
        /**
         * 联网部分
         *
         * 此处为懒惰刷新，即当某模块需要刷新时才刷新，不需要时不刷新，
         * 各个模块是否刷新的判断条件可以按不同模块的需求来写。
         **/
        
        if !refresh { return }
        
        showProgressDialog()
        
        // 暂时关闭列表的下拉刷新
        swiper.enabled = false
        
        // 线程管理器
        var parallelRequest : ApiRequest = ApiEmptyRequest()
        
        // 刷新版本信息和推送消息
        parallelRequest |= ServiceCard.getRefresher()
        
        if ModuleCurriculum.cardEnabled && ApiHelper.isLogin() {
            // 仅当课表数据不存在时刷新课表
            if Cache.curriculum.isEmpty || !Cache.curriculum.value.contains("content") {
                parallelRequest |= CurriculumCard.getRefresher()
            }
        }
        
        if ModuleExperiment.cardEnabled && ApiHelper.isLogin() {
            // 仅当实验数据不存在时刷新实验
            if Cache.experiment.isEmpty {
                parallelRequest |= ExperimentCard.getRefresher()
            }
        }
        
        if ModuleExam.cardEnabled && ApiHelper.isLogin() {
            // 仅当考试数据不存在时刷新考试
            if Cache.exam.isEmpty {
                parallelRequest |= ExamCard.getRefresher()
            }
        }
        
        // 直接刷新校园活动
        parallelRequest |= ActivityCard.getRefresher()
        
        if ModuleLecture.cardEnabled {
            // 直接刷新人文讲座预告
            parallelRequest |= LectureCard.getRefresher()
        }
        
        if ModulePedetail.cardEnabled && ApiHelper.isLogin() {
            // 直接刷新跑操数据
            parallelRequest |= PedetailCard.getRefresher()
        }
        
        if ModuleCard.cardEnabled && ApiHelper.isLogin() {
            // 直接刷新一卡通数据
            parallelRequest |= CardCard.getRefresher()
        }
        
        if ModuleJwc.cardEnabled {
            // 直接刷新教务处数据
            parallelRequest |= JwcCard.getRefresher()
        }

        /**
         * 结束刷新部分
         * 当最后一个线程结束时调用这一部分，刷新结束
         **/
        parallelRequest.onResponse { _, _, _ in
            self.loadContent(false)
        }.onFinish { success, _ in
            self.hideProgressDialog()
            
            // 恢复列表的下拉刷新功能
            self.swiper.enabled = true
            
            if !success {
                self.showMessage("部分数据刷新失败")
            }
        }.run()
    }
    
    /// 卡片列表部分：卡片列表数据源
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 卡片列表
    var cardList : [CardsModel] = []
    
    
    /// 列表分区数目
    func numberOfSections(in tableView: UITableView) -> Int {
        return cardList.count
    }
    
    /// 列表某分区中条目数目
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardList[section].rows.count
    }
    
    /// 实例化列表条目
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        /// 实例化
        
        // 该卡片的卡片模型对象
        let model = cardList[indexPath.section]
        
        // 该卡片的卡片模型对象中对应的行模型对象
        let row = model.rows[indexPath.row]
        
        // 要实例化的布局标识符，若为卡片头部，使用头部布局；否则，使用该卡片指定的内容布局
        let id = indexPath.row == 0 ? "CardsCellHeader" : model.cellId
        
        // 实例化或重用对应的布局
        let cell = cardsTableView.dequeueReusableCell(withIdentifier: id) as! CardsTableViewCell
        
        /// 数据绑定
        
        // 若模型有图标、视图有图标，将模型指定的图标显示在视图上
        if let icon = row.icon { cell.icon?.image = UIImage(named: icon) }
        
        // 若模型有标题、视图有标题，将模型指定的标题显示在视图上
        if let title = row.title { cell.title?.text = title }
        
        // 若模型有副标题、视图有副标题，将模型指定的副标题显示在视图上
        if let subtitle = row.subtitle { cell.subtitle?.text = subtitle }
        
        // 若模型有描述、视图有描述，将模型指定的描述显示在视图上
        if let desc = row.desc { cell.desc?.text = desc }
        
        // 若模型有数字、视图有数字，将模型指定的描述显示在视图上
        if let count0 = row.count0 { cell.count0?.text = count0 }
        if let count1 = row.count1 { cell.count1?.text = count1 }
        if let count2 = row.count2 { cell.count2?.text = count2 }
        if let count3 = row.count3 { cell.count3?.text = count3 }
        
        /// 布局调整
        
        // 若视图有小红点，按照卡片的显示优先级改变小红点状态
        cell.notifyDot?.alpha = indexPath.row == 0 && model.displayPriority == .CONTENT_NOTIFY ? 1 : 0
        
        // 若该行不是卡片头，且既没有目标界面，也没有消息，则关闭其点击效果
        cell.isUserInteractionEnabled = cell is CardsCellShortcutBox || cell is CardsCellVote || row.destination != "" || row.message != "" || indexPath.row == 0
        
        // 若该行是卡片头，且没有目标界面，则隐藏其箭头
        if indexPath.row == 0 {
            cell.arrow?.isHidden = row.destination == ""
        }

        return cell
    }
    
    /// 卡片列表部分：卡片列表代理
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 卡片列表项的点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = cardList[indexPath.section]
        let destination = model.rows[indexPath.row].destination
        let message = model.rows[indexPath.row].message
        
        // 若有目标界面，打开目标界面；否则若有消息，显示消息
        if destination != "" {
            let module = AppModule(title: model.rows[0].title!, url: destination)
            module.open()
        } else if message != "" {
            showMessage(message)
        }
        
        // 标记为已读
        if indexPath.row == 0 {
            model.markAsRead()
        }
            
        // 根据新的已读状态重载卡片列表顺序
        loadContent(false)
    }
}

//3d touch遵守协议
extension CardsViewController:UIViewControllerPreviewingDelegate {
    
    //peek
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = cardsTableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let cell = cardsTableView.cellForRow(at: indexPath) as! CardsTableViewCell
        previewingContext.sourceRect = cell.frame
        
        let destination = cardList[indexPath.section].rows[indexPath.row].destination
        return AppModule(title: "", url: destination).getPreviewViewController()
    }
    
    //pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        AppDelegate.instance.rightController.pushViewController(viewControllerToCommit, animated: true)
    }
}
