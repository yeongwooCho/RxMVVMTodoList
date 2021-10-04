////
////  CalendarViewModel.swift
////  RxMVVMTodoList
////
////  Created by 조영우 on 2021/10/03.
////
////
//import Foundation
//import RxCocoa
//import RxSwift
//
//protocol CalendarViewModelType {
//    // Input, Output이라는 type이 있다.
//    // 어떤 타입인지 프로토콜을 채택하면 정의 해야한다.
//    associatedtype Input
//    associatedtype Output
//    
//    // 그 타입을 가진 변수들이다.
//    var input: Input { get }
//    var output: Output { get }
////    var apiService: RxNetworkCallInterface { get }
//    var disposeBag: DisposeBag { get }
//}
//
//class CalendarViewModel: CalendarViewModelType {
//    
//    struct Input {
////        let reloadDate = BehaviorRelay<String>() // ?
////        let reloadDate = BehaviorRelay<String>(value: Date.dateString(date: Date()))
//    }
//    
//    struct Output {
//        var startDateRelay = BehaviorRelay<String>(value: Date.dateString(date: Date()))
//        var deadlineDateRelay = BehaviorRelay<String>(value: Date.dateString(date: Date(timeIntervalSinceNow: 86400)))
//    }
//    
//    var input: Input
//    var output: Output
////    var apiService: RxNetworkCallInterface // protocol
////    var registerViewModel = RegisterTodoViewModel()
//    var disposeBag: DisposeBag
//    
//    init(input: Input = Input(), output: Output = Output()) {
//        print("calendar view model이 리소스 생성되었습니다.")
//        self.input = input
//        self.output = output
////        self.apiService = apiService
//        
//        self.disposeBag = DisposeBag()
//        setDate()
//    }
//    
//    deinit {
//        print("calendar view model이 리소스 해제되었습니다.")
//        print("calendar view model이 리소스 해제되었습니다.")
//        print("calendar view model이 리소스 해제되었습니다.")
//    }
//    
//    func setDate() {
//        
////        self.input.reloadTrigger
////            .do(onNext: { [weak self] in self?.output.refreshing.onNext(true) })
////            .delay(.seconds(3), scheduler: MainScheduler.instance)
////            .flatMapLatest { [weak self] in
////                (self?.apiService.requestGet(completion: { todos in print("여기는 setReloadTrigger: \(todos)")}))!
////            }
////            .do(onNext: { [weak self] _ in self?.output.refreshing.onNext(false) }) // refresh
////            .bind(to: self.output.todoList)
////            .disposed(by: disposeBag)
////        self.input.reloadDate
////            .subscribe(onNext: { _ in
////                print(123)
////            })
////            .disposed(by: disposeBag)
////        self.output.startDateRelay
////            .subscribe(onNext: { [weak self] date in
////                print("여기는 CalendarViewController")
////                print("date = \(date)")
////                print(self?.output.startDateRelay.value)
////
////            })
////            .disposed(by: disposeBag)
//        
//        // reload Date가 변경되었어르때 start를 변경시키면 된다.
////        self.output.startDateRelay
////            .bind(to: self.output.startDateRelay)
////            .disposed(by: disposeBag)
////        
////        self.output.deadlineDateRelay
////            .bind(to: self.output.deadlineDateRelay)
////            .disposed(by: disposeBag)
//        
//        
//        self.output.startDateRelay
//            .subscribe(onNext: { data in
//                print("calendarViewModel에서 \(data)를 전달받았다.")
//                
//            }, onError: { error in
//                print("calendarViewModel error")
//                print("error: \(error.localizedDescription)")
//            })
//            .disposed(by: disposeBag)
//    }
//    
//}
