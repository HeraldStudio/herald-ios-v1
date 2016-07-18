import UIKit
import SwiftyJSON

/**
 * GameShowCardViewController | 显示卡片详情或抽取卡片的界面；该界面列表视图数据源及事件代理
 * 注意：此界面可两用，若 token 为空则用于展示卡牌详情；不为空则用于抽牌。
 **/
class GameShowCardViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// 已绑定：列表视图
    @IBOutlet var tableView : UITableView!
    
    /// 表示抽牌房间的 token，若需要抽牌则不为空，不需要抽牌则必为空
    var token : String = ""
    
    /// 表示要显示的卡片列表，若显示卡片详情则始终非空，否则初始值为空
    var cards : [GameCardModel] = []
    
    /// 下拉刷新控件，若需要抽牌则不为空，不需要抽牌则必为空
    var swiper : SwipeRefreshHeader?
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        
        // 若要用于抽牌而非显示卡片详情
        if token != "" {
            
            // 实例化下拉刷新控件，自定义其刷新事件及提示文字，并设为列表头视图
            swiper = SwipeRefreshHeader(.Right)
            swiper?.refresher = {() in self.askPickCard()}
            swiper?.tipText = "PICK"
            tableView?.tableHeaderView = swiper
            
            // 标题栏右侧添加“抽牌”按钮，指向 askPickCard 函数
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "抽牌",
                style: .Plain, target: self, action: #selector(self.askPickCard))]
        
            // 显示提示框
            showTipDialogIfUnknown("点击右上角抽一张牌，可以重复抽多张。\n抽牌前建议将手机亮度调低，防止被脸上反射的颜色出卖喔~", cachePostfix: "deskgame_pickcard_brightness"){}
        }
        
        // 设置列表项高度自适应内容
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }
    
    /// 首次显示或将要从其它界面返回时
    override func viewWillAppear(animated: Bool) {
        
        // 重载列表显示
        tableView.reloadData()
        
        // 将标题栏和刷新控件颜色改为当前界面主题色
        setNavigationColor(swiper, 0x333333)
    }
    
    /// 下拉刷新控件要用到的三个 hook
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper?.syncApperance()
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper?.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper?.endDrag()
    }
    
    /// 询问是否要抽牌的函数
    /// 已绑定：下拉刷新控件的刷新事件，标题栏右侧按钮点击事件
    @objc func askPickCard() {
        
        // 若无卡牌，直接抽取；否则询问是否抽取
        if cards.count == 0 {
            pickCard()
        } else {
            showQuestionDialog("你现在已有\(cards.count)张牌，确定再抽一张牌？") {
                self.pickCard()
            }
        }
    }
    
    /// 直接抽牌的函数
    func pickCard() {
        
        // 前置条件：token 非空
        if token != "" {
            showProgressDialog()
            ApiSimpleRequest(checkJson200: false)
                .url("http://app.heraldstudio.com/api/deskgame/draw_card")
                .post("token", token)
                .onResponse { success, _, response in
                    self.hideProgressDialog()
                    if success {
                        
                        // 解析返回的 json 卡片对象
                        let json = JSON.parse(response)["content"]
                        let model = GameCardModel(json: json)
                        
                        // 若解析失败，将得到一个字符串全为空的对象
                        if model.name == "" {
                            self.showMessage("卡牌已抽尽或房间代码无效，请重试")
                        } else {
                            
                            // 解析成功，在列表顶部动画加入新卡牌
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
    
    /// 列表视图数据源接口：获取列表某分组的条目数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 若卡牌列表为空，显示一行“还没有抽到卡牌”的提示
        return max(1, cards.count)
    }
    
    /// 列表视图数据源接口：实例化列表某分组某条目的视图
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 若卡牌列表为空，显示一行“还没有抽到卡牌”的提示
        if cards.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("GameShowCardEmptyTableViewCell")!
        }
        
        // 请求复用/构造表示卡片的列表项视图 GameShowCardTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("GameShowCardTableViewCell") as! GameShowCardTableViewCell
        
        // 取该卡片的数据模型
        let model = cards[indexPath.row]
        
        // 设置视图的卡片名称和说明文字
        cell.cardName.text = model.name
        cell.desc.text = model.desc
        
        // 若图片有效，异步显示图片；否则隐藏图片
        if let url = NSURL(string: model.pic) {
            cell.cardPic.kf_setImageWithURL(url)
        } else {
            cell.cardPic.hidden = true
        }
        return cell
    }
}
