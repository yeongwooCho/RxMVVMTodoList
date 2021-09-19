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
    var id: Int // 구분
    var isDone: Bool // 클릭이 되었는가
    var isToday: Bool // today인가
    
    init(detail: String, id: Int, isDone: Bool, isToday: Bool) {
        self.detail = detail
        self.id = id
        self.isDone = isDone
        self.isToday = isToday
    }
    
    mutating func update(detail: String, isDone: Bool, isToday: Bool) {
        self.detail = detail
        self.isDone = isDone
        self.isToday = isToday
    }
    
    // TODO: 동등 조건 추가
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
