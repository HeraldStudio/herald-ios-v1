import UIKit
import SwiftyJSON

/**
 * GameCreateViewController | 选择卡片、创建房间界面；该界面列表视图数据源及事件代理
 **/
class GameCreateViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// 已绑定：卡片列表视图
    @IBOutlet var tableView : UITableView!
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        
        // 列表项高度自适应内容
        tableView.estimatedRowHeight = 32
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // 加载缓存并异步刷新
        loadCache()
        refreshCache()
        
        // 检测剪贴板内容是否包含抽牌口令
        if UIPasteboard.generalPasteboard().string != nil
            && UIPasteboard.generalPasteboard().string!.containsString("#小猴桌游助手#")
            && UIPasteboard.generalPasteboard().string!.split("[").count > 1
            && UIPasteboard.generalPasteboard().string!.split("[")[1].split("]").count > 0 {
            showQuestionDialog("检测到桌游助手口令，是否开始抽牌？") {
                
                // 实例化抽牌界面 GameShowCardViewController
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MODULE_DESKGAME_SHOWCARD") as! GameShowCardViewController
                
                // 传送 token 参数给抽牌界面
                vc.token = UIPasteboard.generalPasteboard().string!.split("[")[1].split("]")[0]
                
                // 打开抽牌界面
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    /// 首次显示或从其它界面返回时
    override func viewWillAppear(animated: Bool) {
        
        // 载入缓存
        loadCache()
        
        // 改变标题栏颜色为当前界面主题色
        setNavigationColor(nil, 0x3c1095)
    }
    
    /// 异步刷新缓存
    func refreshCache() {
        showProgressDialog()
        ApiSimpleRequest(.Post)
            .url("http://app.heraldstudio.com/api/deskgame/card_list")
            .toCache("herald_deskgame_cards")
            .onResponse { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.loadCache()
                }
            }.run()
    }
    
    /// 本地加载缓存
    func loadCache() {
        let cache = CacheHelper.get("herald_deskgame_cards")
        
        if cache == "" {
            return
        }
        
        // 清空列表，准备载入新数据
        availableGames.removeAll()
        availableGameNames.removeAll()
        
        // 遍历每一种游戏
        for game in JSON.parse(cache).arrayValue {
            
            // 将该种游戏的名称放入 availableGameNames 列表
            availableGameNames.append(game["name"].stringValue)
            
            // 将该种游戏的牌集中的牌转换成 GameCardModel 数据模型，并将转换后的列表放入 availableGames 列表
            // 注意 availableGames 是由包含 GameCardModel 的列表组成的二维表
            availableGames.append(game["collection"].arrayValue.map {
                json -> GameCardModel in GameCardModel(json: json)
            })
        }
        
        // 通知列表视图数据变化
        tableView.reloadData()
    }
    
    /// 开始发牌
    /// 已绑定：发牌按钮点击事件
    @IBAction func beginCreate() {
        
        // 构造 json 列表
        var array : [JSON] = []
        
        // 计算总牌数
        var count = 0
        
        // 遍历用户选择的牌
        for card in myGame {
            
            // 某些牌可能设置了不止一张，遍历某种牌中的每一张，加入列表
            for _ in 0 ..< card.count {
                count += 1
                array.append(card.eachCardToJSON())
            }
        }
        
        // 将 json 列表转换成 json 字符串
        let request = JSON(array).rawStringValue
        
        // 缓解服务器压力，不足5张不予受理
        if count < 5 {
            showMessage("你选择的卡牌过少，不能发牌~")
            return
        }
        
        // 防止数据库长度溢出，超过20480字节不予受理
        if request.characters.count > 20480 {
            showMessage("你选择的卡牌过多，服务器无法处理，请减少牌数并重试")
            return
        }
        
        // 请求发牌
        showProgressDialog()
        ApiSimpleRequest(.Post).url("http://app.heraldstudio.com/api/deskgame/create_room")
            .post("json", request)
            .onResponse { success, _, response in
                self.hideProgressDialog()
                if success {
                    let token = JSON.parse(response)["content"].stringValue
                    let clipboardStr = "复制这条消息，打开小猴偷米桌游助手即可查看：#小猴桌游助手# 抽取一张卡牌：[" + token + "]"
                    
                    // 放进剪贴板
                    UIPasteboard.generalPasteboard().string = clipboardStr
                    self.showQuestionDialog("抽牌代码已复制到剪贴板，发给好友即可抽牌~"){}
                } else {
                    self.showMessage("连接失败，请重试")
                }
            }.run()
    }
    
    /// 可用卡牌的二维表
    var availableGames : [[GameCardModel]] = []
    
    /// 可用牌集名称列表
    var availableGameNames : [String] = []
    
    /// 用户已选卡牌的二维表
    var myGame : [GameCardModel] = []
    
    /// 列表视图数据源接口：获取列表分组数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // 第0分组为用户选择的牌，第1分组开始每个分组代表一种游戏的牌集
        return 1 + availableGames.count
    }
    
    /// 列表视图数据源接口：获取列表分组标题
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 第0分组为用户选择的牌，显示“牌堆中的卡牌”；
        // 第1分组开始每个分组代表一种游戏的牌集，显示“可用牌集 | 游戏名”
        return (["牌堆中的卡牌"] + availableGameNames.map { name in "可用牌集 | " + name })[section]
    }
    
    /// 列表视图数据源接口：获取列表分组脚注
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        // 第0分组有脚注，其余没有
        if section == 0 { return "以上卡牌将随机发给抽牌的人。" }
        else { return nil }
    }
    
    /// 列表视图数据源接口：获取列表某分组的条目数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 第0分组为用户选择的牌，条目数为选择的牌数（若为零，加一行提示）再加一行“添加备用牌”按钮；
        // 第1分组开始每个分组代表一种游戏的牌集，条目数为对应游戏的可用牌数
        return ([max(1, myGame.count) + 1] + availableGames.map { game -> Int in game.count })[section]
    }
    
    /// 列表视图数据源接口：实例化列表某分组某条目的视图
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 第0分组：用户选择的卡牌
        if indexPath.section == 0 {
            
            // 若为最后一条目，请求复用/构造“添加备用牌”按钮并返回
            if indexPath.row == max(1, myGame.count) {
                return tableView.dequeueReusableCellWithIdentifier("GameCreateNewCardTableViewCell")!
            }
            
            // 否则若用户没有选择牌，请求复用/构造“还没有选择要发的牌”提示行并返回
            if myGame.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("GameCreateEmptyTableViewCell")!
            }
            
            // 否则，请求复用/构造代表对应位置的牌的视图
            let cell = tableView.dequeueReusableCellWithIdentifier("GameCreateTableViewCell") as! GameCreateTableViewCell
            
            // 取对应的卡牌数据模型
            let model = myGame[indexPath.row]
            
            // 设置视图中的卡牌名称
            cell.cardName.text = model.name + "（\(model.count) 张）"
            
            // 设置视图中的“增加”按钮事件
            cell.addAction = {() in
                model.count += 1
                
                // 通知列表视图数据变化
                self.tableView.reloadData()
            }
            
            // 设置视图中的“减少”按钮事件
            cell.removeAction = {() in
                model.count -= 1
                if model.count == 0 {
                    
                    // 此卡牌已减少为零张，对该项视图使用“删除”动画效果，同时删除对应的数据模型
                    var pos = self.myGame.count
                    for i in 0 ..< self.myGame.count {
                        let card = self.myGame[i]
                        if card == model {
                            pos = i
                        }
                    }
                    let path = NSIndexPath(forRow: pos, inSection: 0)
                
                    self.tableView.beginUpdates()
                    self.myGame.removeAtIndex(pos)
                    self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: pos == 0 ? .Middle : .Top)
                    if self.myGame.count == 0 {
                        let emptyPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([emptyPath], withRowAnimation: .Middle)
                    }
                    self.tableView.endUpdates()
                } else {
                    
                    // 通知列表视图数据变化
                    self.tableView.reloadData()
                }
            }
            return cell
        } else { // 第 n(n > 0) 分组：表示第 (n - 1) 个游戏的可用牌集列表
            
            // 请求复用/构造可用卡片视图
            let cell = tableView.dequeueReusableCellWithIdentifier("GameAvailableCardTableViewCell") as! GameAvailableCardTableViewCell
            
            // 取对应数据模型
            let model = availableGames[indexPath.section - 1][indexPath.row]
            
            // 设置视图的卡片名称和卡片描述文字
            cell.cardName.text = model.name
            cell.desc.text = model.desc
            
            // 异步设置视图的图片内容；若图片 URL 无效或加载失败，显示占位符图片
            if let url = NSURL(string: model.pic) {
                cell.cardPic.kf_setImageWithURL(url, placeholderImage: UIImage(named: "default_herald"))
            } else {
                cell.cardPic.image = UIImage(named: "default_herald")
            }
            
            // 设置视图的添加按钮事件
            cell.addAction = {() in
                
                // 遍历查找相同卡牌，若找到，直接对其数量增加1并刷新列表显示
                for card in self.myGame {
                    if card == model {
                        card.count += 1
                        self.tableView.reloadData()
                        return
                    }
                }
                
                // 若找不到相同卡牌，构造新卡牌并刷新列表显示
                let offset = self.tableView.contentOffset
                self.myGame.insert(model, atIndex: self.myGame.count)
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(offset, animated: false)
            }
            
            return cell
        }
    }
    
    /// 列表视图事件代理接口：列表项点击事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 取消选中该项
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            // 第0分区
            if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
                
                // 点击了添加备用牌按钮；实例化一个对话框
                let dialog = UIAlertController(title: "添加备用牌", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                
                // 为对话框添加输入框
                dialog.addTextFieldWithConfigurationHandler { field in
                    field.placeholder = "备用牌名称"
                }
                
                // 为对话框添加按钮，指定其点击事件
                dialog.addAction(UIAlertAction(title: "保存", style: UIAlertActionStyle.Default, handler: { _ in
                    
                    // 获取用户输入的备用牌名称
                    let name = dialog.textFields![0].text
                    
                    // 添加该备用牌
                    if name != nil && name! != "" {
                        self.myGame.append(GameCardModel(name: name!))
                        self.tableView.reloadData()
                    } else {
                        self.showMessage("备用牌名称不能为空")
                    }
                }))
                
                // 为对话框添加取消按钮，指定空的点击事件
                dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){_ in})
                
                // 显示该对话框
                presentViewController(dialog, animated: true, completion: nil)
            }
        } else {
            
            // 非第0分区，点击了可用牌集中的牌
            
            // 取该牌的数据模型
            let model = availableGames[indexPath.section - 1][indexPath.row]
            
            // 实例化查看卡牌界面 GameShowCardViewController
            let vc = storyboard?.instantiateViewControllerWithIdentifier("MODULE_DESKGAME_SHOWCARD") as! GameShowCardViewController
            
            // 传递 cards 参数给该界面
            vc.cards.append(model)
            
            // 显示该界面
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
