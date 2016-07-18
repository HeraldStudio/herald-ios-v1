import UIKit
import SwiftyJSON

class GymNewViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var useTime : String!
    
    var sport : GymSportModel!
    
    var timeCell : GymNewStaticCellTime!
    
    var halfCell : GymNewStaticCellHalf!
    
    var phoneCell : GymNewStaticCellPhone!
    
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableViewAutomaticDimension
        
        timeCell = tableView.dequeueReusableCellWithIdentifier("GymNewStaticCellTime") as! GymNewStaticCellTime
        halfCell = tableView.dequeueReusableCellWithIdentifier("GymNewStaticCellHalf") as! GymNewStaticCellHalf
        phoneCell = tableView.dequeueReusableCellWithIdentifier("GymNewStaticCellPhone") as! GymNewStaticCellPhone
        
        timeCell.time.text = useTime
        halfCell.half.enabled = sport.allowHalf
        halfCell.switchAction = { () in self.tableView.reloadData() }
        phoneCell.phone.text = CacheHelper.get("herald_gymreserve_phone")
    }
    
    override func viewWillAppear(animated: Bool) {
        allFriends.removeAll()
        for friend in GymFriendModel.friendCache {
            let model = GymFriendModel(json: friend)
            var isInvited = false
            
            for invited in invitedFriends {
                if invited == model {
                    isInvited = true
                }
            }
            
            if !isInvited {
                allFriends.append(model)
            }
        }
        tableView.reloadData()
    }
    
    var invitedFriends : [GymFriendModel] = []
    
    var allFriends : [GymFriendModel] = []
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["预约基本信息", "共同参加的好友（\(minUsers - 1)~\(maxUsers - 1)个，已添加\(invitedFriends.count)个）", "我的好友"][section]
    }
    
    var halfEnabled : Bool {
        return sport.allowHalf && halfCell.half.on
    }
    
    var minUsers : Int {
        return halfEnabled ? sport.halfMinUsers : sport.fullMinUsers
    }
    
    var maxUsers : Int {
        return halfEnabled ? sport.halfMaxUsers : sport.fullMaxUsers
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [3, max(1, invitedFriends.count), allFriends.count + 1][section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return [timeCell, halfCell, phoneCell][indexPath.row]
        } else if indexPath.section == 1 {
            if invitedFriends.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("GymReserveEmptyTableViewCell")!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("GymNewInvitedFriendCell")! as! GymNewInvitedFriendCell
                cell.name.text = invitedFriends[indexPath.row].name
                cell.removeAction = {() in
                    self.allFriends.append(self.invitedFriends.removeAtIndex(indexPath.row))
                    self.tableView.reloadData()
                }
                return cell
            }
        } else {
            if indexPath.row == allFriends.count {
                return tableView.dequeueReusableCellWithIdentifier("GymNewAddFriendCell")!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("GymNewFriendCell")! as! GymNewFriendCell
                cell.name.text = allFriends[indexPath.row].name
                cell.department.text = allFriends[indexPath.row].department
                cell.deleteAction = {() in
                    self.showQuestionDialog("确定要删除该好友吗？", runAfter: {
                        self.allFriends[indexPath.row].removeFriend()
                        self.allFriends.removeAtIndex(indexPath.row)
                        self.tableView.reloadData()
                    })
                }
                cell.addAction = {() in
                    self.invitedFriends.append(self.allFriends.removeAtIndex(indexPath.row))
                    self.tableView.reloadData()
                }
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    var working = false
    
    var finished = false
    
    @IBAction func submit () {
        if working { return }
        
        phoneCell.phone.resignFirstResponder()
        if finished {
            showQuestionDialog("你已经预约成功，确定要重复预约吗？", runAfter: { 
                self.finished = false
                self.submit()
            })
            return
        }
        
        if invitedFriends.count < minUsers - 1 {
            showMessage("你邀请的好友不足，无法完成预约~")
        } else if invitedFriends.count > maxUsers - 1 {
            showMessage("你邀请的好友超过限制，无法完成预约~")
        } else if phoneCell.phone.text == nil || phoneCell.phone.text! == "" {
            showMessage("请填写联系电话~")
        } else {
            showProgressDialog()
            working = true
            
            ApiSimpleRequest(checkJson200: true).api("yuyue").uuid()
                .post("method", "new")
                .post("orderVO.itemId", "\(self.sport.id)")
                .post("orderVO.useTime", self.useTime)
                .post("orderVO.useMode", self.halfEnabled ? "2" : "1")
                .post("orderVO.phone", self.phoneCell.phone.text!)
                .post("useUserIds", "[" + self.invitedFriends.map { s in "\"\(s.userId)\"" }.joinWithSeparator(",") + "]" )
                .post("orderVO.remark", self.useTime)
                .onResponse { success, _, response in
                    self.hideProgressDialog()
                    self.working = false
                    let code = JSON.parse(response)["content"]["code"].intValue
                    
                    if success && code == 0 {
                        self.showQuestionDialog("新增预约成功") { self.dismiss() }
                    } else {
                        self.showQuestionDialog("预约失败，请尝试重新选择时段") { self.dismiss() }
                    }
                }.run()
        }
    }
    
    func dismiss () {
        navigationController?.popViewControllerAnimated(true)
    }
}
