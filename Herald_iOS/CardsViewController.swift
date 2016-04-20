import Foundation
import UIKit
import Reindeer
import Kingfisher
import SwiftyJSON

class CardsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var cardsTableView: UITableView!
    
    let slider = BannerPageViewController()
    
    var themeColor : UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardsTableView.delegate = self
        themeColor = navigationController?.navigationBar.backgroundColor
        
        let tw = (tabBarController?.tabBar.frame.width)!
        let th = (tabBarController?.tabBar.frame.height)!
        let bottomPadding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tw, height: th))
        cardsTableView.tableFooterView = bottomPadding
        
        setupSlider()
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
    
    func setupSlider () {
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
        slider.view.backgroundColor = themeColor
        slider.startRolling()
        
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: slider.view.frame.height + 8)
        container.addSubview(slider.view)
        
        cardsTableView.tableHeaderView = container
        slider.didMoveToParentViewController(self)
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
        return 5
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moduleCell = cardsTableView.dequeueReusableCellWithIdentifier("cardsCell", forIndexPath: indexPath) as! CardsTableViewCell
        moduleCell.content?.text = "Hello, World"
        for _ in 0 ..< indexPath.row {
            moduleCell.content?.text = (moduleCell.content?.text)! + "Hello, World"
        }
        return moduleCell
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let y = abs(scrollView.contentOffset.y)
        guard let h = cardsTableView.tableHeaderView?.frame.height else {return}
        let alpha : CGFloat = y < h ? (1 - y / h) * (1 - y / h) : 0;
        
        slider.view.subviews[0].alpha = alpha
    }
}

