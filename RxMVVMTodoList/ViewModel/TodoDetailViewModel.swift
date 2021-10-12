//
//  TodoDetailViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/23.
//

import UIKit
import RxCocoa
import RxSwift

protocol DetailViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}

class TodoDetailViewModel: DetailViewModelType { // : ViewModelType
    
    struct Input {
        let todoInfo = BehaviorSubject<Todo?>(value: nil)
    }
    
    struct Output {
        var todo: Observable<Todo>
    }
    
    var input: Input
    var output: Output
    
    init() {
        print("TodoDetailViewModel 생성")
        self.input = Input()
        let todo = self.input.todoInfo
            .map({$0!})
        self.output = Output(todo: todo)
    }
}
