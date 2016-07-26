import SwiftyJSON

class ServiceCard {
    
    static func getRefresher () -> ApiRequest {
        return ApiSimpleRequest(.Post).url("http://android.heraldstudio.com/checkversion").uuid()
            .post("schoolnum", ApiHelper.getSchoolnum())
            .post("versioncode", "\(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion")!)")
            .post("versionname", "V\(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)")
            .post("versiontype", "iOS")
            .toServiceCache("versioncheck_cache")
    }
    
    static func getPushMessageCard() -> CardsModel? {
        let cache = ServiceHelper.get("versioncheck_cache")
        let pushMessage = JSON.parse(cache)["content"]["message"]["content"].stringValue
        let pushMessageUrl = JSON.parse(cache)["content"]["message"]["url"].stringValue
        if pushMessage != "" {
            let card = CardsModel(cellId: "", icon : "ic_pushmsg", title : "小猴提示", desc : pushMessage, dest : pushMessageUrl, message: "", priority : .CONTENT_NOTIFY)
            return card
        }
        return nil
    }
    
    static func getCheckVersionCard() -> CardsModel? {
        let cache = JSON.parse(ServiceHelper.get("versioncheck_cache"))
        let newestVersionCode = cache["content"]["version"]["code"].intValue
        if let curVersionCode = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            if let curVersionCode = Int(curVersionCode) {
                if curVersionCode < newestVersionCode {
                    let newestVersionName = cache["content"]["version"]["name"].stringValue
                    let newestVersionDesc = cache["content"]["version"]["des"].stringValue.replaceAll("\\n", "\n")
                    let tip = "小猴偷米 iOS " + newestVersionName + " 更新啦，点击升级\n" +
                        newestVersionDesc
                    
                    let card = CardsModel(cellId: "", icon : "ic_update", title : "版本升级", desc : tip, dest : StringUpdateUrl, message: "", priority : .CONTENT_NOTIFY)
                    return card
                }
            }
        }
        return nil
    }
}