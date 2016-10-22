//
//  PedetailUtil.swift
//  Herald_iOS
//
//  Created by Vhyme on 2016/09/27.
//  Copyright © 2016年 HeraldStudio. All rights reserved.
//

import Foundation

class ExerciseUtil {
    enum ExerciseStatus {
        case BeforeExercise
        case DuringExercise
        case AfterExercise
    }
    
    static func getCurrentExerciseStatus () -> ExerciseStatus {
        let _now = GCalendar()
        let now = _now.hour * 60 + _now.minute
        let startTime = 6 * 60 + 20
        let endTime = 7 * 60 + 20
        
        if now < startTime {
            return .BeforeExercise
        } else if now < endTime {
            return .DuringExercise
        } else {
            return .AfterExercise
        }
    }
}