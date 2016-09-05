import UIKit

class ExpressViewController : UITableViewController {
    
    var cell : ExpressMainTableViewCell?
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0xffba00)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        cell = (tableView.dequeueReusableCellWithIdentifier("ExpressMainTableViewCell") as! ExpressMainTableViewCell)
        return cell!
    }
    
    @IBAction func refreshTimeList() {
        cell?.refreshTimeList()
    }
}