import UIKit
import SwiftyJSON

class CustomExamViewController : UIViewController {
    
    @IBOutlet var examName : UITextField!
    
    @IBOutlet var examPlace : UITextField!
    
    @IBOutlet var examMinutes : UITextField!
    
    @IBOutlet var examTime : UIDatePicker!
    
    var index = -1
    
    override func viewDidLoad() {
        var cache = CacheHelper.get("herald_exam_custom_\(ApiHelper.getUserName())")
        if cache == "" {cache = "[]"}
        
        var array = JSON.parse(cache).arrayValue
        if self.index >= 0 && self.index < array.count {
            do {
                let exam = try ExamModel(json: array[index])
                examName.text = exam.course
                examPlace.text = exam.location
                examMinutes.text = exam.hour
                examTime.date = GCalendar(exam.time).getDate()
            } catch {}
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(nil, 0xf5176c)
    }
    
    @IBAction func save () {
        endEdit()
        
        guard let name = examName.text else {
            showMessage("考试名称填写不正确，请重试")
            return
        }
        
        if name == "" {
            showMessage("考试名称不能为空，请重试")
            return
        }
        
        let place = examPlace.text == nil ? "" : examPlace.text!
        let minutes = examMinutes.text == nil ? "" : examMinutes.text!
        
        if minutes != "" && Int(minutes) == nil {
            showMessage("考试时长格式有误，请重试")
            return
        }
        
        let time = GCalendar(examTime.date)
        
        let json = JSON([
            "course":name,
            "time":String(format: "%d-%02d-%02d %02d:%02d", time.year, time.month, time.day, time.hour, time.minute, time.second),
            "location":place,
            "hour":minutes
        ])
        
        var cache = CacheHelper.get("herald_exam_custom_\(ApiHelper.getUserName())")
        if cache == "" {cache = "[]"}
        
        var array = JSON.parse(cache).arrayValue
        if index < 0 || index >= array.count {
            array.append(json)
        } else {
            array[index] = json
        }
        
        guard let newJson = JSON(array).rawString() else {
            showMessage("数据保存失败，请重试")
            return
        }
        CacheHelper.set("herald_exam_custom_\(ApiHelper.getUserName())", newJson)
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func delete () {
        if index == -1 {
            navigationController?.popViewControllerAnimated(true)
        } else {
            showQuestionDialog("确认删除该考试吗？", runAfter: {
                var cache = CacheHelper.get("herald_exam_custom_\(ApiHelper.getUserName())")
                if cache == "" {cache = "[]"}
                
                var array = JSON.parse(cache).arrayValue
                if self.index >= 0 && self.index < array.count {
                    array.removeAtIndex(self.index)
                }
                
                guard let newJson = JSON(array).rawString() else {
                    self.showMessage("删除失败，请重试")
                    return
                }
                CacheHelper.set("herald_exam_custom_\(ApiHelper.getUserName())", newJson)
                
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    func endEdit() {
        examName.resignFirstResponder()
        examPlace.resignFirstResponder()
        examMinutes.resignFirstResponder()
    }
}