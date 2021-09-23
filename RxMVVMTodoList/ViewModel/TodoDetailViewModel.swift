//
//  TodoDetailViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/23.
//

import UIKit
import RxCocoa
import RxSwift

class TodoDetailViewModel: ViewModelType {
    struct Input {
        let todoInfo = BehaviorSubject<Todo?>(value: nil)
    }
    
    struct Output {
        var detail: Observable<String>
        var id: Observable<Int>
        var isDone: Observable<Bool>
        var isToday: Observable<Bool>
    }
    
    var input: Input
    var output: Output
    
    init() {
        self.input = Input()
        
        let detail = self.input.todoInfo
            .filter { $0 != nil }
            .map { $0!.detail }
        
        let id = self.input.todoInfo
            .filter { $0 != nil }
            .map { $0!.id }
        
        let isDone = self.input.todoInfo
            .filter { $0 != nil }
            .map { $0!.isDone }
        
        let isToday = self.input.todoInfo
            .filter { $0 != nil }
            .map { $0!.isToday }
        
        self.output = Output(detail: detail, id: id, isDone: isDone, isToday: isToday)
    }
}
