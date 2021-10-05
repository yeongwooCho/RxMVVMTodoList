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
        case startDate
        case deadlineDate
    }
    
    var detail: String // 내용
    var id: TimeInterval // 구분 by timeIntervalSince1970
    var isDone: Bool // select button
    var startDate: String
    var deadlineDate: String
    
    init(detail: String, isDone: Bool, startDate: String, deadlineDate: String) {
        self.detail = detail
        self.id = Date().timeIntervalSince1970
        self.isDone = isDone
        self.startDate = startDate
        self.deadlineDate = deadlineDate
    }
    
    init(obj: Todo) {
        self.detail = obj.detail
        self.id = obj.id
        self.isDone = obj.isDone
        self.startDate = obj.startDate
        self.deadlineDate = obj.deadlineDate
    }
    
    init(obj: Todo, deadlineDate: String) {
        self.detail = obj.detail
        self.id = obj.id + TimeInterval(0.01) // 최소한 겹치지는 않게
        self.isDone = obj.isDone
        self.startDate = obj.startDate
        self.deadlineDate = deadlineDate
    }
    
    mutating func update(detail: String, isDone: Bool, startDate: String, deadlineDate: String) {
        self.detail = detail
        self.isDone = isDone
        self.startDate = startDate
        self.deadlineDate = deadlineDate
    }
    
    // 동등 조건 추가
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
