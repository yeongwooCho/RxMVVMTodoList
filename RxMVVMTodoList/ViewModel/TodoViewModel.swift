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
        let reloadTrigger = PublishSubject<Void>() // 이벤트 전달받고 전달해줄 놈, 구독이후 이벤트 전달, trigger: 방아쇠\
        let completedTrigger = PublishSubject<Void>()
    }
    
    struct Output {
        let refreshing = BehaviorSubject<Bool>(value: false) // TableView refreshing 해야할지 판단
        
        let todoList = BehaviorRelay<[Todo]>(value: []) // 이벤트를 받아 binding할때 쓰는놈, 현재는 비어있다.
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
            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true)})
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] in
                (self?.apiService.requestGet(completion: { todos in print("setReloadTrigger completion: \(todos)")}))!
            }
            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false)})
            .bind(to: self.output.todoList)
            .disposed(by: disposeBag)
    }
    
    private func setSubscribedTodoList() { // todoList <-> sectionTodoLabel
        self.output.todoList
            .subscribe(onNext: { [weak self] todos in
                print("여기서 todo accept한것 데이터를 받아버림 \(todos)")
                let dicTodos = Dictionary.init(grouping: todos, by: {$0.deadlineDate})
                let sectionModelTodos = dicTodos.map { (key, value) in
                    SectionModel.init(model: key, items: value)
                }.sorted { $0.model < $1.model } // string도 크기가 존재한다.
                print(sectionModelTodos)
                self?.output.sectionTodoList.accept(sectionModelTodos)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTodos() { // ViewController에서 호출할 것, 네트워크 콜을 VC에서 VM에게 요청하는 곳이다.
        apiService.requestGet { todos in print("todoVM fetchTodos completion: \(todos)") }
            .subscribe(onSuccess: { [weak self] todos in
                self?.output.todoList.accept(todos)
            }, onFailure: { error in
                print("requestGet을 통해 받아온 데이터가 없습니다. error: \(error.localizedDescription)")
            }, onDisposed: {
                print("todoVM fetchTodos 리소스 반환 disposed.")
            }).disposed(by: disposeBag)
    }
    
    func deleteTodos(todo: Todo) {
        var todos = self.output.todoList.value
        todos = todos.filter{ $0.id != todo.id }
        self.putTodos(todos: todos)
    }
    
    func deleteTodos(at index: IndexPath) {
        let todo = self.output.sectionTodoList.value[index[0]].items[index[1]]
        deleteTodos(todo: todo)
    }
    
    func updateTodos(obj item: Todo, deadlineDate: String) {
        var todos = self.output.todoList.value.map { Todo.init(obj: $0) }
        let updatedItem = Todo.init(obj: item, deadlineDate: deadlineDate)
        guard let index = todos.firstIndex(of: item) else { return }
        todos.remove(at: index)
        todos.append(updatedItem)
        self.putTodos(todos: todos)
    }
    
    func updateEditingTodos(obj item: Todo, detail: String, startDate: String, deadlineDate: String) {
        apiService.requestGet { print("TodoViewModel updateEditingTodos requestGet: \($0)") }
            .subscribe { getDatas in
                var todos = getDatas.map { Todo.init(obj: $0) }
                var updatedItem = Todo.init(obj: item)
                updatedItem.update(detail: detail, isDone: false, startDate: startDate, deadlineDate: deadlineDate)
                
                guard let index = todos.firstIndex(of: item) else { return }
                todos.remove(at: index)
                todos.append(updatedItem)
                self.putTodos(todos: todos)
            } onFailure: { error in
                print("error: \(error.localizedDescription)")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
    }
    
    private func putTodos(todos: [Todo]) {
        apiService.requestPut(params: todos) { todos in
            // completion
            print("DB에 저장한 데이터는 다음과 같습니다.")
            print(todos)}
            .subscribe(onSuccess: { [weak self] todos in
                print("onNext: \(todos)")
                self?.output.todoList.accept(todos)
            }, onFailure: { error in
                print("onError = { error_code: \(error._code), description: \(error.localizedDescription)")
            }, onDisposed: {
                print("Save onDisposed")
            })
            .disposed(by: disposeBag)
    }
}
// 일단 network call에서 실시간이 되려면 ViewModel이 View에게 어떤 이벤트를 받게되면 반응을한다.
// 이 반응을 받으면 ViewModel은 Repository에게 request을 하게 되고 ViewModel은 response를 받아 View에게 callback을 전달한다.
// VM은 apiService에 repository를 갖고 있고, observable을 구독하고 있다. 그럼 실행시키고 해당 이벤트를 콜백으로 받아 이를 처리한다.
// 이벤트 처리 구조는 VM에 있는 output.todoList에 accept하는 과정만 하면 된다.
// 왜? output.todoList를 View가 구독하고 있기 때문이다.
