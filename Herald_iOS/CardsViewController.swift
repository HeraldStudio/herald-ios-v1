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
        
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        cardsTableView.tableFooterView = bottomPadding
        cardsTableView.estimatedRowHeight = 120;
        cardsTableView.rowHeight = UITableViewAutomaticDimension;
        
        setupSliderAndSwiper()
        loadContent(true)
        ServiceHelper.refreshCache {() in self.refreshSlider()}
    }
    
    override func viewDidAppear(animated: Bool) {
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
            if self.links[index] != "" {
                if let link = NSURL(string: self.links[index]) {
                    UIApplication.sharedApplication().openURL(link)
                }
            }
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
        
        cardList = cardList.sort {$0.priority.rawValue < $1.priority.rawValue}
        
        cardsTableView.reloadData()
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
        
        if let icon = row.icon { cell.icon.image = UIImage(named: icon) }
        if let title = row.title { cell.title.text = title }
        if let subtitle = row.subtitle { cell.subtitle.text = subtitle }
        if let desc = row.desc { cell.desc.text = desc }
        if let count1 = row.count1 { cell.count1.text = count1 }
        if let count2 = row.count2 { cell.count2.text = count2 }
        if let count3 = row.count3 { cell.count3.text = count3 }
        
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

