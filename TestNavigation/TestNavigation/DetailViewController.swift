//
//  DetailViewController.swift
//  Wea
//
//  Created by Howie on 16/3/15.
//  Copyright © 2016年 Howie. All rights reserved.
//

import UIKit


//第一个子页面
class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var horizonScrollView: UIView!
    //@IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    

    var timer:NSTimer!
    weak var delegate: ReloadViewControllerDelegate?
    
    //需要显示的卡片-详细信息，/名称、
    var tempModule = [dicCard]()
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.delegate = self
        self.view.backgroundColor = UIColor.clearColor()
        //detailTableView.bounces = false

        //addTimer()
        
        detailTableView.backgroundView?.backgroundColor = UIColor.clearColor()
        detailTableView.backgroundColor = UIColor.clearColor()
        detailTableView.separatorColor = UIColor.clearColor()
        
        detailTableView.showsHorizontalScrollIndicator = false
        detailTableView.showsVerticalScrollIndicator = false
        detailTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        getEachCardH()
        
        self.detailTableView.estimatedRowHeight=110;
        
        self.detailTableView.rowHeight=UITableViewAutomaticDimension;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextImage(sender:AnyObject!){//图片轮播；
        var page:Int = self.pageControl.currentPage;
        if(page == 1){   //循环；
            page = 0;
        }else{
            page += 1;
        }
        let x:CGFloat = CGFloat(page) * pageControl.frame.size.width;
        detailTableView.contentOffset = CGPointMake(x, 0);//注意：contentOffset就是设置detailTableView的偏移；
    }
    
    func addTimer(){   //图片轮播的定时器；
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(DetailViewController.nextImage(_:)), userInfo: nil, repeats: true);
    }
    
    func detailTableViewDidScroll(detailTableView: UIScrollView) {
        //这里的代码是在detailTableView滚动后执行的操作，并不是执行detailTableView的代码；
        //这里只是为了设置下面的页码提示器；该操作是在图片滚动之后操作的；
        let detailTableViewW:CGFloat = detailTableView.frame.size.width;
        let x:CGFloat = detailTableView.contentOffset.x;
        let page:Int = (Int)((x + detailTableViewW / 2) / detailTableViewW);
        pageControl.currentPage = page;
        
    }

    //指定UITableView中有多少个section的，section分区，一个section里会包含多个Cell
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    //每一个section里面有多少个Cell
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            var numOfCard = 0
            for index in userModuleDict {
                if (index[3] as! Bool && index[4] as! Bool) {
                    numOfCard += 1
                }
            }
            return numOfCard
        }
    }
    
    //初始化每一个Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            //空白的cell调整高度预留~
            let blankCell = detailTableView.dequeueReusableCellWithIdentifier("blankCell", forIndexPath: indexPath) as! ItemsTableViewCell
            blankCell.selectionStyle = UITableViewCellSelectionStyle.None
            return blankCell
        } else {
            let cardCell = detailTableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! CardTableViewCell
            //cardCell.backgroundColor = UIColor.clearColor()
            cardCell.selectionStyle = UITableViewCellSelectionStyle.None
            cardCell.icon.image = UIImage(named: "\(tempModule[indexPath.row].icon)")
            
            //cardCell.frame.size = CGSizeMake(cardCell.cardframeInit.width, cardCell.cardframeInit.height)
            cardCell.button.hidden = false
            //cardCell.scrollV.hidden = false
            cardCell.message.hidden = false
            
            
            cardCell.detail.text = "现在"
            
            switch tempModule[indexPath.row].name {
                case "跑操助手":
                    cardCell.button.hidden = true
                    if doOrNot {
                        cardCell.message.text = "你今天的跑操已到账，点我查看详情"
                    } else {
                        cardCell.detail.text = "今天没有跑操预告信息"
                        cardCell.message.hidden = true
                    }
                    break
                case "一卡通":
                    cardCell.button.hidden = false
                    cardCell.message.text = "你的一卡通余额还有\(cardLeft)元"
                    //cardCell.scrollV.hidden = true
                    //cardCell.frame.size = CGSizeMake(cardCell.frame.width, 106)
                    break
                case "课表助手":
                    cardCell.button.hidden = true
                    
                    if curriculum.isEmpty {
                        cardCell.detail.text = "oops，今天没有课哦"
                        cardCell.message.hidden = true
                    } else {
                        cardCell.message.text = "你今天有\(curriculum.count)节课，点我查看详情"
                        //判断scroll是否存在，移除，避免复用无限重叠.....
                        if cardCell.customView.subviews[cardCell.customView.subviews.count - 1].isKindOfClass(UIScrollView) {
                            cardCell.customView.subviews[cardCell.customView.subviews.count - 1].removeFromSuperview()
                        }

                        //cardCell.detail.text = "现在"
                        cardCell.addScrollView(tempModule[indexPath.row].height)
                    }
                    
                    break
                case "实验助手":
                    cardCell.button.hidden = true
                    
                    if experi.isEmpty {
                        cardCell.detail.text = "你没有未完成的实验，实验助手可以提醒你..."
                        cardCell.message.hidden = true
                    } else {
                        cardCell.message.text = "你有\(lecture.count)节课，点我查看详情"
                        //判断scroll是否存在，移除，避免复用无限重叠.....
                        if cardCell.customView.subviews[cardCell.customView.subviews.count - 1].isKindOfClass(UIScrollView) {
                            cardCell.customView.subviews[cardCell.customView.subviews.count - 1].removeFromSuperview()
                        }
                        
                        //cardCell.detail.text = "现在"
                        //cardCell.addScrollView(tempModule[indexPath.row].height)
                    }
                    
                    break
                case "人文讲座":
                    //cardCell.scrollV.hidden = true
                    cardCell.button.hidden = true
                    
                    if lecture.isEmpty {
                        cardCell.detail.text = "今天暂无人文讲座信息，点我查看以后的预告"
                        cardCell.message.hidden = true
                    } else {
                        cardCell.message.text = "你今天有\(curriculum.count)节课，点我查看详情"
                        //判断scroll是否存在，移除，避免复用无限重叠.....
                        if cardCell.customView.subviews[cardCell.customView.subviews.count - 1].isKindOfClass(UIScrollView) {
                            cardCell.customView.subviews[cardCell.customView.subviews.count - 1].removeFromSuperview()
                        }
                        
                        //cardCell.detail.text = "现在"
                        //cardCell.addScrollView(tempModule[indexPath.row].height)
                    }
                    break
                case "教务通知":
                    cardCell.button.hidden = true
                    if jwc.isEmpty {
                        cardCell.detail.text = "今天没有新的重要教务通知"
                        cardCell.message.hidden = true
                    } else {
                        cardCell.message.text = "今天有新的重要教务通知，请有关同学关注"
                        //判断scroll是否存在，移除，避免复用无限重叠.....
                        if cardCell.customView.subviews[cardCell.customView.subviews.count - 1].isKindOfClass(UIScrollView) {
                            cardCell.customView.subviews[cardCell.customView.subviews.count - 1].removeFromSuperview()
                        }
                        cardCell.addJwcScrollView()
                    }
                    break
                default:
                    break
            }
            
            cardCell.label.text = tempModule[indexPath.row].name
            return cardCell
        }
    }
    
    //card的高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            var num = 0
            for index in userModuleDict {
                if index[2] as! Bool {
                    num += 1
                }
            }
            return CGFloat((num / 5 + 1) * 76 + 10)
        } else {
            return tempModule[indexPath.row].height
        }
    }
    
    func getEachCardH() {
        
        for index in userModuleDict {
            if index[3] as! Bool && index[4] as! Bool {
                //默认高度和优先级
                let onecard = dicCard(icon: index[0] as! String, name: index[1] as! String, priority: 5, height: 85)
                tempModule.append(onecard)
            }
        }
        //tempModule加上card高度、/card优先级（==）
        
        for i in 0..<tempModule.count {
            switch tempModule[i].name {
            case "跑操助手":
                if doOrNot {
                    tempModule[i].height = 109
                    tempModule[i].priority = 1
                } else {
                    tempModule[i].priority = 5
                }
                break
            case "教务通知":
                if jwc.isEmpty {
                    tempModule[i].priority = 4
                } else {
                    tempModule[i].height = 175
                    tempModule[i].priority = 2
                }
                break
            case "课表助手":
                if curriculum.isEmpty {
                    tempModule[i].priority = 5
                } else {
                    tempModule[i].height = 200
                    tempModule[i].priority = 3
                }
                break
            case "实验助手":
                if experi.isEmpty {
                    tempModule[i].priority = 5
                } else {
                    tempModule[i].height = 200
                    tempModule[i].priority = 3
                }
                break
            case "人文讲座":
                if lecture.isEmpty {
                    tempModule[i].priority = 5
                } else {
                    tempModule[i].height = 200
                    tempModule[i].priority = 4
                }
                break
            case "一卡通":
                tempModule[i].height = 106
                tempModule[i].priority = 4
                break
            default:
                break
            }
        }
        
        //优先级排序
        tempModule = tempModule.sort({$0.priority < $1.priority})
    }
    
    //选中一个Cell后执行的方法
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
}

//适应视图。暂无用处，已抛弃
extension String {
    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if CGSizeEqualToSize(size, CGSizeZero) {
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            textSize = self.sizeWithAttributes(attributes as? [String : AnyObject])
        } else {
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            let stringRect = self.boundingRectWithSize(size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
}
