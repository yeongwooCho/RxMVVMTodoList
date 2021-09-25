//
//  Todo.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import UIKit

struct Todo: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case detail
        case id
        case isDone
        case isToday
    }
    
    var detail: String // 내용
    var id: TimeInterval // 구분
    var isDone: Bool // select button 선태 여부
    var isToday: Bool // today, upcoming
    
    init(detail: String, id: TimeInterval, isDone: Bool, isToday: Bool) {
        self.detail = detail
        self.id = id
        self.isDone = isDone
        self.isToday = isToday
    }
    
    init (detail: String, isToday: Bool) {
        self.detail = detail
        self.id = Date().timeIntervalSince1970
        self.isDone = false
        self.isToday = isToday
    }
    
    mutating func update(detail: String, isDone: Bool, isToday: Bool) {
        self.detail = detail
        self.isDone = isDone
        self.isToday = isToday
    }
    
    // 동등 조건 추가
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
