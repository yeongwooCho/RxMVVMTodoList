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
            .subscribe(onNext: { [weak self] todo in
                self?.addTodos(todo: todo)
                print("Add task button에 의한 데이터 받음 \(todo)")
            }, onError: { error in
                print("error: \(error.localizedDescription)")
            }, onCompleted: {
                print("register todo completed")
            }, onDisposed: {
                print("register todo disposed")
            })
            .disposed(by: disposeBag)
    }
            
    private func addTodos(todo: Todo) {
        apiService.requestGet { todos in
            print("register requestGet: Todos == \(todos)")
        }
        .subscribe(onSuccess: { [weak self] todos in
            if todos == [] {
                self?.putTodos(todos: [todo])
            } else {
                var registerTodos = todos
                registerTodos.append(todo)
                self?.putTodos(todos: registerTodos)
            }
        }, onFailure: { error in
            print("add todos error: \(error.localizedDescription)")
        }, onDisposed: {
            print("register add todos disposed.")
        })
        .disposed(by: disposeBag)
    }
    
    private func putTodos(todos: [Todo]) {
        apiService.requestPut(params: todos) { todos in
            // completion
            print("DB에 저장한 데이터는 다음과 같습니다.")
            print(todos)}
            .subscribe(onSuccess: { todos in
                print("onNext: \(todos)")
//                self?.output.todoList.accept($0)
            }, onFailure: { error in
                print("onError = { error_code: \(error._code), description: \(error.localizedDescription)}")
            }, onDisposed: {
                print("Save onDisposed")
            })
            .disposed(by: disposeBag)
    }
}
