import Foundation

class ShortcutCard {
    static func getCard () -> CardsModel {
        let model = CardsModel(cellId: "CardsCellShortcutBox", module: AppModule("", "常用模块", "", "MODULE_MANAGER", "ic_fav", true), desc: "点我管理常用模块，让小猴更懂你", priority: .CONTENT_NO_NOTIFY)
        
        // 添加一个空行，根据上面的cellId设定，将自动初始化成一个快捷栏
        model.rows.append(CardsRowModel())
        return model
    }
}