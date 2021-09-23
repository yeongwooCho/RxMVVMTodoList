//
//  TodoViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol ViewModelType {
    // Input, Output이라는 type이 있다.
    // 어떤 타입인지 프로토콜을 채택하면 정의 해야한다.
    associatedtype Input
    associatedtype Output
    
    // 그 타입을 가진 변수들이다.
    var input: Input { get }
    var output: Output { get }
}

class TodoViewModel: ViewModelType {
    
    struct Input {
        let reloadTrigger = PublishSubject<Void>() // 이벤트 전달받고 전달해줄 놈, 구독이후 이벤트 전달, trigger: 방아쇠
        let inputTodoList = PublishSubject<[Todo]>() // MARK: put 할때는 데이터의 이동이 필요하다.
    }
    
    struct Output {
        let todoList = BehaviorRelay<[Todo]>(value: []) // 이벤트를 받아 binding할때 쓰는놈, 현재는 비어있다.
        let refreshing = BehaviorSubject<Bool>(value: false) // collectionView refreshing 해야할지 판단
    }
    
    var input: Input
    var output: Output
    let apiService: RxNetworkCallInterface // protocol
    var disposeBag = DisposeBag()
    
    init(input: Input = Input(), output: Output = Output(), apiService: RxNetworkCallInterface = AlamofireRxCall()) { // dependency injection
        self.input = input
        self.output = output
        self.apiService = apiService
        setReloadTrigger() // 장전, 땅!! 하는 중간다리 역할하는놈 setting 하기
    }
    
    func fetchTodos() { // ViewController에서 호출할 것, 네트워크 콜을 VC에서 VM에게 요청하는 곳이다.
        apiService.requestGet { todos in print("여기는 fetchTodos: \(todos)") }
            .subscribe { [weak self] in
                self?.output.todoList.accept($0)
            }
            .disposed(by: disposeBag)
    }
    
    func putTodos(todo: Todo) {
        var todos = self.output.todoList.value
        todos.append(todo)
        apiService.requestPut(params: todos) { todos in
            // completion
            print("DB에 저장한 데이터는 다음과 같습니다.")
            print(todos)
        }
        .subscribe(onNext: { print("onNext: \($0)")},
                     onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")},
                     onCompleted: { print("Save onCompleted")},
                     onDisposed: { print("Save onDisposed")})
         .disposed(by: disposeBag)

        fetchTodos()
//        apiService.requestPut(params: todos, completion: { todos in print("여기는 fetchTodos: \(todos)") })
//            .subscribe { [weak self] in
//                self?.input.inputTodoList.
//            }
//        apiService.requestPut(params: [], completion: { todos in print("여기는 fetchTodos: \(todos)") })
//            .subscribe { [weak self] in
//                self?.input.inputTodoList.accept
//            }
    }
    
    func deleteTodos(todo: Todo) {
        var todos = self.output.todoList.value
        todos = todos.filter{ $0.id != todo.id }
        apiService.requestPut(params: todos) { todos in
            // completion
            print("DB에 저장한 데이터는 다음과 같습니다.")
            print(todos)
        }
        .subscribe(onNext: { print("onNext: \($0)")},
                     onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")},
                     onCompleted: { print("Save onCompleted")},
                     onDisposed: { print("Save onDisposed")})
         .disposed(by: disposeBag)

        fetchTodos()
    }
    
    // strong reference cycle의 발생을 막기위해 closure내부에서 self를 사용하면 [weak self]을 항상 명시해주자
    // 이러면 self? 으로 사용하면 된다.
    private func setReloadTrigger() { // ViewModel 생성시 호출된다.
        // doOn은 구독 시점이 아닌 이벤트 발생시점에 처리할 작업이 있을때 사용한다.
        self.input.reloadTrigger
            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true) })
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] in // requestGet
                (self?.apiService.requestGet(completion: { todos in print(todos)}))!
            }
            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false) })
            .bind(to: self.output.todoList) // BehaviorRelay<[Todo]> 에 binding
            .disposed(by: disposeBag)
        // refreshing에 true 이벤트 3초 유지, requestGet, refreshing에 false, 가져온 데이터 todoList에 binding.
    }
    
//    enum Section: Int, CaseIterable {
//        case today
//        case upcoming
//
//        var title: String {
//            switch self {
//            case .today: return "Today"
//            default: return "Upcoming"
//            }
//        }
//    }
}


//    private let manager = TodoManager.shared
//
//    var todos: [Todo] {
//        return manager.todos
//    }
//
//    var todayTodos: [Todo] {
//        return todos.filter { $0.isToday == true }
//    }
//
//    var upcomingTodos: [Todo] {
//        return todos.filter { $0.isToday == false }
//    }
//
//    var numOfSection: Int {
//        return Section.allCases.count
//    }
//
//    func addTodo(_ todo: Todo) {
//        manager.addTodo(todo)
//    }
//
//    func deleteTodo(_ todo: Todo) {
//        manager.deleteTodo(todo)
//    }
//
//    func updateTodo(_ todo: Todo) {
//        manager.updateTodo(todo)
//    }
//
//    func loadTasks() {
//        manager.retrieveTodo()
//    }
//
//class TodoManager {
//    static let shared = TodoManager(apiService: AlamofireRxCall()) // 본래 것으로 생성
//    
//    let disposeBag = DisposeBag()
//    var todos: [Todo] = []
//    var apiService: RxNetworkCallInterface
//    
//    // protocol을 채택한 뒤 생성할 때는 dependency injection을 활용해서 본래의 것으로 생성한다.
//    init(apiService: RxNetworkCallInterface) {
//        self.apiService = apiService
//    }
//    
//    func createTodo(detail: String, isToday: Bool) -> Todo {
//        let timeOfRegister = Date().timeIntervalSince1970
//        return Todo(detail: detail, id: Int(timeOfRegister), isDone: false, isToday: isToday)
//    }
//    
//    func addTodo(_ todo: Todo) {
//        todos.append(todo)
//        saveTodo()
//    }
//    
//    func deleteTodo(_ todo: Todo) {
//        todos = todos.filter{ $0.id != todo.id }
//        saveTodo()
//    }
//    
//    func updateTodo(_ todo: Todo) {
//        guard let index = todos.firstIndex(of: todo) else { return }
//        todos[index].update(detail: todo.detail, isDone: todo.isDone, isToday: todo.isToday)
//        saveTodo()
//    }
//    
//    func saveTodo() {
//        TodoManager.shared.apiService.requestPut(params: self.todos) { todos in
//            // completion
//            print("DB에 저장한 데이터는 다음과 같습니다.")
//            print(todos)
//        }.subscribe(onNext: { print("onNext: \($0)")},
//                     onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")},
//                     onCompleted: { print("Save onCompleted")},
//                     onDisposed: { print("Save onDisposed")})
//         .disposed(by: disposeBag)
//    }
//    
//    func retrieveTodo() {
//        TodoManager.shared.apiService.requestGet { todos in
//            // completion
//            print("DB에서 가져온 데이터는 다음과 같습니다.")
//            print(todos)
//        }.subscribe(
//            onNext: {
//                print("onNext: \($0)")
//                self.todos = $0 },
//            onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")},
//            onCompleted: { print("Retrieve onCompleted")},
//            onDisposed: { print("Retrieve onDisposed")})
//        .disposed(by: disposeBag)
//    }
//}
