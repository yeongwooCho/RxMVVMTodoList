//
//  TodoViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Alamofire

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    var apiService: RxNetworkCallInterface { get }
    var disposeBag: DisposeBag { get }
}

class TodoViewModel: ViewModelType {
    
    struct Input {
        let reloadTrigger = PublishSubject<Void>() // 이벤트 전달받고 전달해줄 놈, 구독이후 이벤트 전달, trigger: 방아쇠
    }
    
    struct Output {
        let todoList = BehaviorRelay<[Todo]>(value: []) // 이벤트를 받아 binding할때 쓰는놈, 현재는 비어있다.
        let refreshing = BehaviorSubject<Bool>(value: false) // TableView refreshing 해야할지 판단
        
        let sectionTodoList = BehaviorRelay<[SectionModel<String, Todo>]>(value: [])
    }
    
    var input: Input
    var output: Output
    var apiService: RxNetworkCallInterface // protocol
    var disposeBag: DisposeBag
    
    init(input: Input = Input(), output: Output = Output(), apiService: RxNetworkCallInterface = AlamofireRxCall()) { // dependency injection
        self.input = input
        self.output = output
        self.apiService = apiService
        self.disposeBag = DisposeBag()
        setReloadTrigger()
        setSubscribedTodoList()
    }
    
    private func setReloadTrigger() { // ViewModel 생성시 호출된다.
        // doOn은 구독 시점이 아닌 이벤트 발생시점에 처리할 작업이 있을때 사용한다. 구독과는 연관이 없다.
        self.input.reloadTrigger
            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true) })
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] in
                (self?.apiService.requestGet(completion: { todos in print("여기는 setReloadTrigger: \(todos)")}))!
            }
            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false) }) // refresh
            .bind(to: self.output.todoList)
            .disposed(by: disposeBag)
    }
    
    private func setSubscribedTodoList() { // todoList <-> sectionTodoLabel
        self.output.todoList
            .subscribe(onNext: { [weak self] todos in
                let dicTodos = Dictionary.init(grouping: todos, by: {$0.deadlineDate})
                let sectionModelTodos = dicTodos.map { (key, value) in
                    SectionModel.init(model: key, items: value)
                }
                self?.output.sectionTodoList.accept(sectionModelTodos)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTodos() { // ViewController에서 호출할 것, 네트워크 콜을 VC에서 VM에게 요청하는 곳이다.
        apiService.requestGet { todos in print("여기는 fetchTodos: \(todos)") }
            .subscribe(onNext: { [weak self] in
                self?.output.todoList.accept($0)
            }, onError: { error in
                print("requestGet을 통해 받아온 데이터가 없습니다. error: \(error.localizedDescription)")
            }, onCompleted: {
                print("completed. 성공")
            }, onDisposed: {
                print("disposed. 리소스 반환")
            }).disposed(by: disposeBag)
    }
    
    
    
    // value로 데이터 가져오는거 원래 안됨 -> 이거도 안되고 있는거임// 수정바람
    func addTodos(todo: Todo) {
        var todos = self.output.todoList.value
        print("addTodos1 todos \(todos)")
        todos.append(todo)
        print("addTodos2 todos \(todos)")
        self.putTodos(todos: todos)
    }
    
    func deleteTodos(todo: Todo) {
        var todos = self.output.todoList.value
        print("deleteTodos1 todos \(todos)")
        todos = todos.filter{ $0.id != todo.id }
        print("deleteTodos2 todos \(todos)")
        self.putTodos(todos: todos)
    }
    
    private func putTodos(todos: [Todo]) {
        apiService.requestPut(params: todos) { todos in
            // completion
            print("DB에 저장한 데이터는 다음과 같습니다.")
            print(todos)}
            .subscribe(onNext: { [weak self] in
                print("onNext: \($0)")
                self?.output.todoList.accept($0)
            }, onError: { print("onError = { error_code: \($0._code), description: \($0.localizedDescription)}")
            }, onCompleted: { print("Save onCompleted")
            }, onDisposed: { print("Save onDisposed")
            })
            .disposed(by: disposeBag)
    }
}
// 일단 network call에서 실시간이 되려면 ViewModel이 View에게 어떤 이벤트를 받게되면 반응을한다.
// 이 반응을 받으면 ViewModel은 Repository에게 request을 하게 되고 ViewModel은 response를 받아 View에게 callback을 전달한다.
// VM은 apiService에 repository를 갖고 있고, observable을 구독하고 있다. 그럼 실행시키고 해당 이벤트를 콜백으로 받아 이를 처리한다.
// 이벤트 처리 구조는 VM에 있는 output.todoList에 accept하는 과정만 하면 된다.
// 왜? output.todoList를 View가 구독하고 있기 때문이다.
