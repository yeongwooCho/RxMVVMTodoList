//
//  Date.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/30.
//

import Foundation
import UIKit

extension Date {
    static func dateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

