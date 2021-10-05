//
//  Date.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/30.
//

import Foundation
import UIKit

extension Date {
    static func dateToString(date: Date, isTime: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        if isTime {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        return dateFormatter.string(from: date)
    }
}

