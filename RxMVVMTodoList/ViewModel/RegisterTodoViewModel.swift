//
//  RegisterTodoViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/10/01.
//

import Foundation
import RxCocoa
import RxSwift

protocol RegisterViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    var apiService: RxNetworkCallInterface { get } // protocol
    var disposeBag: DisposeBag { get }
}

class RegisterTodoViewModel: RegisterViewModelType {
    
    static let shared = RegisterTodoViewModel()
    
    struct Input {
        let registerTodo = PublishSubject<Todo>() // register todo 할때 이용
    }
    
    struct Output {
        var startDateRelay = BehaviorRelay<String>(value: Date.dateToString(date: Date(), isTime: false))
        var deadlineDateRelay = BehaviorRelay<String>(value: Date.dateToString(date: Date(timeIntervalSinceNow: 86400), isTime: false))
    }
    
    var input: Input
    var output: Output
    var apiService: RxNetworkCallInterface // protocol
    var disposeBag: DisposeBag
    
    init(input: Input = Input(), output: Output = Output(), apiService: RxNetworkCallInterface = AlamofireRxCall()) {
        print("registerViewModel 리소스 생성되었습니다.")
        self.input = input
        self.output = output
        self.apiService = apiService
        self.disposeBag = DisposeBag()
        setRegisterTodo()
    }
    
    deinit {
        print("registerViewModel 리소스 반환되었습니다.")
    }
    
    private func setRegisterTodo() {
        self.input.registerTodo
            .subscribe(onNext: { [weak self] todo in self?.addTodos(todo: todo) // MARK: 여기 이상함
            }, onError: { error in
                print("error: \(error.localizedDescription)")
            }, onCompleted: {
                print("registerVM add todo completed")
            }, onDisposed: {
                print("registerVM todo disposed")
            })
            .disposed(by: disposeBag)
    }
            
    private func addTodos(todo: Todo) {
        apiService.requestGet { todos in print("registerVM addTodos requestGet completion: \(todos)") }
            .subscribe(onSuccess: { [weak self] todos in
                if todos == [] {
                    self?.putTodos(todos: [todo])
                } else {
                    var registerTodos = todos
                    registerTodos.append(todo)
                    self?.putTodos(todos: registerTodos)
                }
            }, onFailure: { error in
                print("registerVM add todos error: \(error.localizedDescription)")
            }, onDisposed: {
                print("registerVM add todos disposed.")
            })
            .disposed(by: disposeBag)
    }
    
    private func putTodos(todos: [Todo]) {
        apiService.requestPut(params: todos) { todos in // completion
            print("registerVM requestPut completion: \(todos)")
            guard let todoListVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoListViewController.identifier) as? TodoListViewController else { return }
            todoListVC.todoListViewModel.output.todoList.accept(todos)
        }
        .subscribe(onSuccess: { todos in
            print("registerVM putTodos success on next: \(todos)")
//                self?.output.todoList.accept($0)
        }, onFailure: { error in
            print("registerVM putTodos error_code: \(error._code), description: \(error.localizedDescription)")
        }, onDisposed: {
            print("registerVM putTodos onDisposed")
        })
        .disposed(by: disposeBag)
    }
}
