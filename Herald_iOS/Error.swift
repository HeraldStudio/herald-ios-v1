import Foundation

/// 一个全局的异常，需要抛异常时只要 throw E 即可
class GError: Error {}
let E = GError()
