//
//  TodoViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import Foundation
import RxSwift
import Alamofire


class TodoManager {
    static let shared = TodoManager(networkcall: AlamofireRxCall())
    
    let disposeBag = DisposeBag()
    var todos: [Todo] = []
    var interface: RxNetworkCallInterface
    
    init(networkcall: RxNetworkCallInterface) {
        interface = networkcall
    }
    
    func createTodo(detail: String, isToday: Bool) -> Todo {
        let timeOfRegister = Date().timeIntervalSince1970
        return Todo(detail: detail, id: Int(timeOfRegister), isDone: false, isToday: isToday)
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        saveTodo()
    }
    
    func deleteTodo(_ todo: Todo) {
        todos = todos.filter{ $0.id != todo.id }
        saveTodo()
    }
    
    func updateTodo(_ todo: Todo) {
        guard let index = todos.firstIndex(of: todo) else { return }
        todos[index].update(detail: todo.detail, isDone: todo.isDone, isToday: todo.isToday)
        saveTodo()
    }
    
    func saveTodo() {
        TodoManager.shared.interface.requestPut(params: self.todos) { todos in
            // completion
            print("DB에 저장한 데이터는 다음과 같습니다.")
            print(todos)
        }.subscribe(onNext: { print("onNext: \($0)")},
                     onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")},
                     onCompleted: { print("Save onCompleted")},
                     onDisposed: { print("Save onDisposed")})
         .disposed(by: disposeBag)
    }
    
    func retrieveTodo() {
        TodoManager.shared.interface.requestGet { todos in
            // completion
            print("DB에서 가져온 데이터는 다음과 같습니다.")
            print(todos)
        }.subscribe(
            onNext: {
                print("onNext: \($0)")
                self.todos = $0 },
            onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")},
            onCompleted: { print("Retrieve onCompleted")},
            onDisposed: { print("Retrieve onDisposed")})
        .disposed(by: disposeBag)
    }
}


class TodoViewModel {
    
    enum Section: Int, CaseIterable {
        case today
        case upcoming
        
        var title: String {
            switch self {
            case .today: return "Today"
            default: return "Upcoming"
            }
        }
    }
    
    init() {
        self.loadTasks()
    }
    
    private let manager = TodoManager.shared
    
    var todos: [Todo] {
        return manager.todos
    }
    
    var todayTodos: [Todo] {
        return todos.filter { $0.isToday == true }
    }
    
    var upcomingTodos: [Todo] {
        return todos.filter { $0.isToday == false }
    }
    
    var numOfSection: Int {
        return Section.allCases.count
    }
    
    func addTodo(_ todo: Todo) {
        manager.addTodo(todo)
    }
    
    func deleteTodo(_ todo: Todo) {
        manager.deleteTodo(todo)
    }
    
    func updateTodo(_ todo: Todo) {
        manager.updateTodo(todo)
    }
    
    func loadTasks() {
        manager.retrieveTodo()
    }
}
