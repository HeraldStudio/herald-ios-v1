import Foundation
import UIKit
import Reindeer
import Kingfisher
import SwiftyJSON

class CardsViewController: BaseViewController, UITableViewDelegate {
    
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
        
        ApiRequest().url("http://android.heraldstudio.com/checkversion").uuid()
            .post("schoolnum", "0", "versioncode", "0")
            .toServiceCache("versioncheck_cache") { (json) -> String in json.rawString()!}
            .onFinish { (_, _, _) -> Void in
                self.refreshSlider()
            }
            .run()
        
        // Do any additional setup after loading the view, typically from a nib.
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
        swiper.refresher = {() in self.showMessage("刷新测试")} // TODO
        cardsTableView.tableHeaderView = swiper
    }
    
    var links : [String] = []
    
    func refreshSlider () {
        let cache = JSON.parse(CacheHelper.getServiceCache("versioncheck_cache"))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moduleCell = cardsTableView.dequeueReusableCellWithIdentifier("cardsCell", forIndexPath: indexPath) as! CardsTableViewCell
        moduleCell.content?.text = "Hello, World! "
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

