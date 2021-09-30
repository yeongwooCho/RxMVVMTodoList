//
//  TestViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/22.
//

import Foundation
import RxSwift
import RxCocoa


/*
View Model
: 실제적인 View Model의 객체이다.
: 사용자의 입력을 받아 특정 비즈니스 로직을 처리하거나 API 요청을 보내 데이터를 가져온다.
: 해당 View에서 필요한 전체적인 로직을 처리하는 객체이다. View와 1:1로 매칭했다.
*/

//protocol ViewModelType {
//    associatedtype Input
//    associatedtype Output
//
//    var input: Input { get }
//    var output: Output { get }
//}
//
//class TestViewModel: ViewModelType {
//    struct Input {
//        let reloadTrigger = PublishSubject<Void>()
//    }
//
//    struct Output {
//        let todoList = BehaviorRelay<[Todo]>(value: [])
//        let refreshing = BehaviorSubject<Bool>(value: false)
//    }
//
//    var input: Input
//    var output: Output
//
//    let apiService: AlamofireRxCall
//    var disposeBag = DisposeBag()
//
//    init(input: Input = Input(),
//         output: Output = Output(),
//         apiService: AlamofireRxCall = AlamofireRxCall()) {
//        self.input = input
//        self.output = output
//        self.apiService = apiService
//
//
////        setReloadTrigger()
//    }

//    func fetchCars() {
//        apiService.requestGet { todos in
//            print("todos: \(todos)")
//        }
//        .subscribe
//
//        apiService.requestGet(completion: [])
//            .subscribe { [weak self] in
//                self?.output.todoList
//            }
//
//        apiService.requestCars()
//            .subscribe { [weak self] in
//                self?.output.carsList.accept($0)
//            }
//            .disposed(by: disposeBag)
//    }
//
//    private func setReloadTrigger() {
//        self.input.reloadTrigger
//            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true)})
//            .delay(.seconds(3), scheduler: MainScheduler.instance)
//            .flatMapLatest { [weak self] in
//                (self?.apiService.requestGet(completion: []))!
//            }
//
//        self.input.reloadTrigger
//            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true)})
//            .delay(.seconds(3), scheduler: MainScheduler.instance)
//            .flatMapLatest { [weak self] in
//                (self?.apiService.requestCars())!
//            }
//            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false) })
//            .bind(to: self.output.carsList)
//            .disposed(by: disposeBag)
//    }

//    deinit {
//        disposeBag = DisposeBag()
//    }
//}
//
//class CarViewModel: ViewModelType {
//    struct Input {
//        let reloadTrigger = PublishSubject<Void>()
//    }
//
//    struct Output {
//        let carsList = BehaviorRelay<[Car]>(value: [])
//        let refreshing = BehaviorSubject<Bool>(value: false)
//    }
//
//    var input: Input
//    var output: Output
//
//    let apiService: CarsAPIService
//    var disposeBag = DisposeBag()
//
//    init(input: Input = Input(),
//         output: Output = Output(),
//         apiService: CarsAPIService = CarsAPIService(networkManager: NetworkManagerStub())) {
//        self.input = input
//        self.output = output
//        self.apiService = apiService
//
//
//        setReloadTrigger()
//    }
//
//    func fetchCars() {
//        apiService.requestCars()
//            .subscribe { [weak self] in
//                self?.output.carsList.accept($0)
//            }
//            .disposed(by: disposeBag)
//    }
//
//    private func setReloadTrigger() {
//        self.input.reloadTrigger
//            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true)})
//            .delay(.seconds(3), scheduler: MainScheduler.instance)
//            .flatMapLatest { [weak self] in
//                (self?.apiService.requestCars())!
//            }
//            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false) })
//            .bind(to: self.output.carsList)
//            .disposed(by: disposeBag)
//    }
//
//    deinit() {
//        disposeBag = DisposeBag()
//    }
//}













// ViewModel에 있던것
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
//}


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
