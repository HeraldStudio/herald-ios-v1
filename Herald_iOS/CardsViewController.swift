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
        refreshSlider()
        ServiceHelper.refreshCache {() in self.loadContent(true)}
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
    
    var itemList : [CardsModel] = []
    
    func loadContent (refresh : Bool) {
        /// 本地重载部分
        
        // 单独刷新快捷栏，不刷新轮播图。轮播图在轮播图数据下载完成后单独刷新。
        refreshShortcutBox()
        
        // 清空卡片列表，等待载入
        itemList.removeAll()
        
        // 加载推送缓存
        if let item = ServiceHelper.getPushMessageItem() {
            itemList.append(item)
        }
        
        // 判断各模块是否开启并加载对应数据，暂时只有一个示例，为了给首页卡片的实现提供参考
        if SettingsHelper.getModuleCardEnabled(2) {
            //itemList.append(CurriculumCard())
        }
        
        // TODO 没写完
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
        return 0
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moduleCell = cardsTableView.dequeueReusableCellWithIdentifier("cardsCell", forIndexPath: indexPath) as! CardsTableViewCell
        moduleCell.content?.text = "Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! "
        return moduleCell
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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

