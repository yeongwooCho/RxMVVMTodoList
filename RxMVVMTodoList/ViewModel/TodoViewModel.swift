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
    // Input, Output이라는 type이 있다.
    // 어떤 타입인지 프로토콜을 채택하면 정의 해야한다.
    associatedtype Input
    associatedtype Output
    
    // 그 타입을 가진 변수들이다.
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
        setReloadTrigger() // 장전, 땅!! 하는 중간다리 역할하는놈 setting 하기
    }
    
    // strong reference cycle의 발생을 막기위해 closure내부에서 self를 사용하면 [weak self]을 항상 명시해주자
    // 이러면 self? 으로 사용하면 된다.
    private func setReloadTrigger() { // ViewModel 생성시 호출된다.
        // doOn은 구독 시점이 아닌 이벤트 발생시점에 처리할 작업이 있을때 사용한다.
        self.input.reloadTrigger
            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true) })
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] in // requestGet의 이벤트를 기다리게 된다.
                (self?.apiService.requestGet(completion: { todos in print("여기는 setReloadTrigger: \(todos)")}))!
            }
            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false) }) // refresh
            .bind(to: self.output.todoList) // BehaviorRelay<[Todo]> 에 binding
            .disposed(by: disposeBag)
        // refreshing에 true 이벤트 3초 유지, requestGet, refreshing에 false, 가져온 데이터 todoList에 binding.
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
    
    func addTodos(todo: Todo) {
        var todos = self.output.todoList.value
        todos.append(todo)
        self.putTodos(todos: todos)
    }
    
    func deleteTodos(todo: Todo) {
        var todos = self.output.todoList.value
        todos = todos.filter{ $0.id != todo.id }
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
