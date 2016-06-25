import Foundation

/**
 * String | Java 风格的基本字符串处理
 * 简直受不了 componentsSeparatedByString 和 stringByReplacingOccurrencesOfString 
 * 这两个函数的命名，所以在这里改成了 Java 风格，顺便加了个 recursiveReplaceAll，会循环替换
 * 直到不存在，以便解决类似"AABB".replaceAll("AB", "")这种替换一次还可以再替换的问题
 */
extension String {
    
    /// 分割字符串
    func split (separator : String) -> [String] {
        return componentsSeparatedByString(separator)
    }
    
    /// 全部替换
    func replaceAll (src : String, _ dst : String) -> String {
        return stringByReplacingOccurrencesOfString(src, withString: dst)
    }
    
    /// 重复替换直到不存在
    func recursiveReplaceAll (src : String, _ dst : String) -> String {
        var a = self
        while a.containsString(src) {
            a = a.replaceAll(src, dst)
        }
        return a
    }
}