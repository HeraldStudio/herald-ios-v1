import UIKit
import SwiftyJSON

class GameShowCardViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    var token : String = ""
    
    var cards : [GameCardModel] = []
    
    var swiper : SwipeRefreshHeader?
    
    override func viewDidLoad() {
        
        if token != "" {
            swiper = SwipeRefreshHeader()
            swiper?.refresher = {() in self.askPickCard()}
            swiper?.tipText = "PICK"
            tableView?.tableHeaderView = swiper
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "抽牌",
                style: .Plain, target: self, action: #selector(self.askPickCard))]
        }
            
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        
        showTipDialogIfUnknown("点击右上角抽一张牌，可以重复抽多张。\n抽牌前建议将手机亮度调低，防止被脸上反射的颜色出卖喔~", cachePostfix: "deskgame_pickcard_brightness"){}
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        setNavigationColor(swiper, 0x333333)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper?.syncApperance()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper?.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper?.endDrag()
    }
    
    @objc func askPickCard() {
        if cards.count == 0 {
            pickCard()
        } else {
            showQuestionDialog("你现在已有\(cards.count)张牌，确定再抽一张牌？") {
                self.pickCard()
            }
        }
    }
    
    func pickCard() {
        if token != "" {
            showProgressDialog()
            ApiRequest().noCheck200()
                .url("http://app.heraldstudio.com/api/deskgame")
                .post("method", "get", "token", token)
                .onFinish { success, _, response in
                    self.hideProgressDialog()
                    if success {
                        let json = JSON.parse(response)["content"]
                        let model = GameCardModel(json: json)
                        if model.name == "" {
                            self.showMessage("卡牌已抽尽或房间代码无效，请重试")
                        } else {
                            self.tableView.beginUpdates()
                            let ip = NSIndexPath(forRow:0, inSection: 0)
                            if self.cards.count == 0 {
                                self.tableView.deleteRowsAtIndexPaths([ip], withRowAnimation: .Fade)
                            }
                            self.cards.insert(model, atIndex: 0)
                            self.tableView.insertRowsAtIndexPaths([ip], withRowAnimation: .Top)
                            self.tableView.endUpdates()
                        }
                    } else {
                        self.showMessage("抽牌失败，请重试")
                    }
                }.run()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, cards.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if cards.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("GameShowCardEmptyTableViewCell")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GameShowCardTableViewCell") as! GameShowCardTableViewCell
        let model = cards[indexPath.row]
        
        cell.cardName.text = model.name
        cell.desc.text = model.desc
        
        if let url = NSURL(string: model.pic) {
            cell.cardPic.kf_setImageWithURL(url)
        } else {
            cell.cardPic.hidden = true
        }
        return cell
    }
}
