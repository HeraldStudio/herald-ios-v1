import Foundation
import UIKit
import Reindeer
import Kingfisher
import SwiftyJSON

class CardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cardsTableView: UITableView!
    
    let slider = BannerPageViewController()
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !ApiHelper.isLogin() {
            return
        }
        
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        cardsTableView.tableFooterView = bottomPadding
        cardsTableView.estimatedRowHeight = 120;
        cardsTableView.rowHeight = UITableViewAutomaticDimension;
        
        setupSliderAndSwiper()
        loadContent(true)
        
        // 启动定时刷新，每当时间改变时触发本地重载
        let seconds = 60 - NSDate().timeIntervalSince1970 % 60
        performSelector(#selector(self.timeChanged), withObject: nil, afterDelay: seconds)
    }
    
    // 定时刷新
    func timeChanged() {
        loadContent(false)
        // 这里虽然seconds接近60，但是不写死，防止误差累积
        let seconds = 60 - NSDate().timeIntervalSince1970 % 60
        performSelector(#selector(self.timeChanged), withObject: nil, afterDelay: seconds)
    }
    
    override func viewDidAppear(animated: Bool) {
        if !ApiHelper.isLogin() {
            return
        }
        refreshSlider()
        loadContent(false)
    }
    
    func setupSliderAndSwiper () {
        slider.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width * CGFloat(0.4))
        slider.interval = 5
        slider.placeholderImage = UIImage(named: "default_herald")
        
        slider.setRemoteImageFetche { (imageView, url, placeHolderImage) in
            imageView.kf_setImageWithURL(NSURL(string: url)!, placeholderImage: placeHolderImage)
        }
        
        slider.setBannerTapHandler { (index) in
            AppModule(title: "小猴偷米", url: self.links[index]).open(self.navigationController)
        }
        
        // 刷新控件
        swiper.themeColor = navigationController?.navigationBar.backgroundColor
        swiper.contentView = slider.view
        swiper.refresher = {() in
            self.loadContent(true)
        }
        cardsTableView.tableHeaderView = swiper
    }
    
    var links : [String] = []
    
    func refreshSlider () {
        let cache = JSON.parse(ServiceHelper.get("versioncheck_cache"))
        let array = cache["content"]["sliderviews"]
        
        links.removeAll()
        var pics : [AnyObject?] = []
        for i in 0 ..< array.count {
            let pic = array[i]
            if let url = pic["imageurl"].string {
                pics.append(url)
                
                if let link = pic["url"].string {
                    links.append(link)
                } else {
                    links.append("")
                }
            }
        }
        
        if pics.count == 0 { return }
        slider.images = pics
        slider.startRolling()
    }
    
    /**
     * 卡片列表部分
     */
    
    var cardList : [CardsModel] = []
    
    func loadContent (refresh : Bool) {
        /// 本地重载
        
        // 单独刷新快捷栏，不刷新轮播图。轮播图在轮播图数据下载完成后单独刷新。
        refreshShortcutBox()
        
        // 清空卡片列表，等待载入
        cardList.removeAll()
        
        // 加载推送缓存
        if let item = ServiceHelper.getPushMessageItem() {
            cardList.append(item)
        }
        
        // 判断各模块是否开启并加载对应数据，暂时只有一个示例，为了给首页卡片的实现提供参考
        if SettingsHelper.getModuleCardEnabled(Module.Curriculum.rawValue) {
            // 加载并解析课表缓存
            cardList.append(CurriculumCard.getCard())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Experiment.rawValue) {
            // 加载并解析实验缓存
            cardList.append(ExperimentCard.getCard())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Exam.rawValue) {
            // 加载并解析考试缓存
            cardList.append(ExamCard.getCard())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Lecture.rawValue) {
            // 加载并解析人文讲座预告缓存
            cardList.append(LectureCard.getCard())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Pedetail.rawValue) {
            // 加载并解析跑操预报缓存
            cardList.append(PedetailCard.getCard())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Card.rawValue) {
            // 加载并解析一卡通缓存
            cardList.append(CardCard.getCard())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Jwc.rawValue) {
            // 加载并解析一卡通缓存
            cardList.append(JwcCard.getCard())
        }
        
        // 有消息的排在前面，没消息的排在后面
        cardList = cardList.sort {$0.priority.rawValue < $1.priority.rawValue}
        
        // 更新数据源，结束刷新
        cardsTableView.reloadData()
        
        /**
         * 联网部分
         *
         * 1、此处为懒惰刷新，即当某模块需要刷新时才刷新，不需要时不刷新，
         * 各个模块是否刷新的判断条件可以按不同模块的需求来写。
         *
         * 2、此处改为用 {@link ApiThreadManager} 方式管理线程。
         * 该管理器可以自定义在每个线程结束时、在所有线程结束时执行不同的操作。
         **/
        
        if !refresh { return }
        
        showProgressDialog()
        
        // 线程管理器
        let manager = ApiThreadManager().onResponse { success, _, _ in
            if success { self.loadContent(false) }
        }
        
        // 刷新版本信息和推送消息
        manager.addAll(ServiceHelper.getRefresher())
        
        if SettingsHelper.getModuleCardEnabled(Module.Curriculum.rawValue) {
            // 仅当课表数据不存在时刷新课表
            if CacheHelper.get("herald_curriculum") == "" || CacheHelper.get("herald_sidebar") == "" {
                manager.addAll(CurriculumCard.getRefresher())
            }
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Experiment.rawValue) {
            // 仅当实验数据不存在时刷新实验
            if CacheHelper.get("herald_experiment") == "" {
                manager.addAll(ExperimentCard.getRefresher())
            }
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Exam.rawValue) {
            // 仅当考试数据不存在时刷新考试
            if CacheHelper.get("herald_exam") == "" {
                manager.addAll(ExamCard.getRefresher())
            }
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Lecture.rawValue) {
            // 直接刷新人文讲座预告
            manager.addAll(LectureCard.getRefresher())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Pedetail.rawValue) {
            // 仅当已到开始时间时，允许刷新
            let _now = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
            let now = _now.hour * 60 + _now.minute
            let startTime = 6 * 60 + 20
            if now >= startTime {
                manager.addAll(PedetailCard.getRefresher())
            }
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Card.rawValue) {
            // 直接刷新一卡通数据
            manager.addAll(CardCard.getRefresher())
        }
        
        if SettingsHelper.getModuleCardEnabled(Module.Jwc.rawValue) {
            // 直接刷新教务处数据
            manager.addAll(JwcCard.getRefresher())
        }

        /**
         * 结束刷新部分
         * 当最后一个线程结束时调用这一部分，刷新结束
         **/
        manager.onFinish { success in
            self.hideProgressDialog()
            if !success {
                self.showMessage("部分数据刷新失败")
            }
        }.run()
    }
    
    func refreshShortcutBox() {
        // TODO
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cardList.count
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardList[section].rows.count
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = cardList[indexPath.section]
        let row = model.rows[indexPath.row]
        let id = indexPath.row == 0 ? "CardsCellHeader" : model.cellId
        let cell = cardsTableView.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath) as! CardsTableViewCell
        
        if let icon = row.icon { cell.icon?.image = UIImage(named: icon) }
        if let title = row.title { cell.title?.text = title }
        if let subtitle = row.subtitle { cell.subtitle?.text = subtitle }
        if let desc = row.desc { cell.desc?.text = desc }
        if let count1 = row.count1 { cell.count1?.text = count1 }
        if let count2 = row.count2 { cell.count2?.text = count2 }
        if let count3 = row.count3 { cell.count3?.text = count3 }
        cell.notifyDot?.alpha = row.notifyDot ? 1 : 0
        
        return cell
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let model = cardList[indexPath.section]
        AppModule(title: model.rows[0].title!, url: model.rows[indexPath.row].destination).open(navigationController)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance(scrollView.contentOffset)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
}

