import UIKit
import SwiftyJSON

class GameCreateViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 32
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadCache()
        refreshCache()
        
        if UIPasteboard.generalPasteboard().string != nil
            && UIPasteboard.generalPasteboard().string!.containsString("#小猴桌游助手#")
            && UIPasteboard.generalPasteboard().string!.split("[").count > 1
            && UIPasteboard.generalPasteboard().string!.split("[")[1].split("]").count > 0 {
            showQuestionDialog("检测到桌游助手口令，是否开始抽牌？") {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MODULE_DESKGAME_SHOWCARD") as! GameShowCardViewController
                vc.token = UIPasteboard.generalPasteboard().string!.split("[")[1].split("]")[0]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCache()
        setNavigationColor(nil, 0x3c1095)
    }
    
    @IBAction func refreshCache() {
        showProgressDialog()
        ApiRequest().noCheck200()
            .url("http://app.heraldstudio.com/api/deskgame")
            .post("method", "getcards")
            .toCache("herald_deskgame_cards")
            .onFinish { success, _, _ in
                self.hideProgressDialog()
                if success {
                    self.loadCache()
                }
            }.run()
    }
    
    func loadCache() {
        let cache = CacheHelper.get("herald_deskgame_cards")
        
        if cache == "" {
            return
        }
        
        availableGames.removeAll()
        availableGameNames.removeAll()
        for game in JSON.parse(cache).arrayValue {
            availableGameNames.append(game["name"].stringValue)
            availableGames.append(game["collection"].arrayValue.map {
                json -> GameCardModel in GameCardModel(json: json)
            })
        }
        
        tableView.reloadData()
    }
    
    /// 开始发牌
    @IBAction func beginCreate() {
        var array : [JSON] = []
        var count = 0
        for card in myGame {
            for _ in 0 ..< card.count {
                count += 1
                array.append(card.eachCardToJSON())
            }
        }
        let request = JSON(array).rawStringValue
        if count <= 5 {
            showMessage("你选择的卡牌过少，不能发牌~")
            return
        }
        if request.characters.count > 20480 {
            showMessage("你选择的卡牌过多，服务器无法处理，请减少牌数并重试")
            return
        }
        showProgressDialog()
        ApiRequest().url("http://app.heraldstudio.com/api/deskgame")
            .post("method", "create", "json", request)
            .onFinish { success, _, response in
                self.hideProgressDialog()
                if success {
                    let token = JSON.parse(response)["content"].stringValue
                    let clipboardStr = "复制这条消息，打开小猴偷米桌游助手即可查看：#小猴桌游助手# 抽取一张卡牌：[" + token + "]"
                    UIPasteboard.generalPasteboard().string = clipboardStr
                    self.showQuestionDialog("抽牌代码已复制到剪贴板，发给好友即可抽牌~"){}
                } else {
                    self.showMessage("连接失败，请重试")
                }
            }.run()
    }
    
    var availableGames : [[GameCardModel]] = []
    
    var availableGameNames : [String] = []
    
    var myGame : [GameCardModel] = []
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 + availableGames.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (["牌堆中的卡牌"] + availableGameNames.map { name in "可用牌集 | " + name })[section]
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 { return "以上卡牌将随机发给抽牌的人。" }
        else { return nil }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ([max(1, myGame.count) + 1] + availableGames.map { game -> Int in game.count })[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == max(1, myGame.count) {
                return tableView.dequeueReusableCellWithIdentifier("GameCreateNewCardTableViewCell")!
            }
            if myGame.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("GameCreateEmptyTableViewCell")!
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("GameCreateTableViewCell") as! GameCreateTableViewCell
            let model = myGame[indexPath.row]
            
            cell.cardName.text = model.name + "（\(model.count) 张）"
            
            cell.addAction = {() in
                model.count += 1
                self.tableView.reloadData()
            }
            
            cell.removeAction = {() in
                model.count -= 1
                if model.count == 0 {
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
                    self.tableView.reloadData()
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("GameAvailableCardTableViewCell") as! GameAvailableCardTableViewCell
            let model = availableGames[indexPath.section - 1][indexPath.row]
            cell.cardName.text = model.name
            cell.desc.text = model.desc
            
            if let url = NSURL(string: model.pic) {
                cell.cardPic.kf_setImageWithURL(url, placeholderImage: UIImage(named: "default_herald"))
            } else {
                cell.cardPic.image = UIImage(named: "default_herald")
            }
            
            cell.addAction = {() in
                
                for card in self.myGame {
                    if card == model {
                        card.count += 1
                        self.tableView.reloadData()
                        return
                    }
                }
                
                let offset = self.tableView.contentOffset
                self.myGame.insert(model, atIndex: self.myGame.count)
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(offset, animated: false)
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
                let dialog = UIAlertController(title: "添加备用牌", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                
                dialog.addTextFieldWithConfigurationHandler { field in
                    field.placeholder = "备用牌名称"
                }
                
                dialog.addAction(UIAlertAction(title: "保存", style: UIAlertActionStyle.Default, handler: { _ in
                    
                    let name = dialog.textFields![0].text
                    
                    if name != nil && name! != "" {
                        self.myGame.append(GameCardModel(name: name!))
                        self.tableView.reloadData()
                    } else {
                        self.showMessage("备用牌名称不能为空")
                    }
                }))
                
                dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: {
                    _ in
                }))
                
                presentViewController(dialog, animated: true, completion: nil)
            }
        } else {
            let model = availableGames[indexPath.section - 1][indexPath.row]
            let vc = storyboard?.instantiateViewControllerWithIdentifier("MODULE_DESKGAME_SHOWCARD") as! GameShowCardViewController
            vc.cards.append(model)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
