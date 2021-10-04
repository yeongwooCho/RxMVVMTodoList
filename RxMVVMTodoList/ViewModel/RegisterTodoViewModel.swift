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
    var disposeBag: DisposeBag { get }
}

class RegisterTodoViewModel: RegisterViewModelType {
    
    static let shared = RegisterTodoViewModel()
    
    struct Input {
        let reloadDate = PublishSubject<String>()
    }
    
    struct Output {
        var startDateRelay = BehaviorRelay<String>(value: Date.dateString(date: Date()))
        var deadlineDateRelay = BehaviorRelay<String>(value: Date.dateString(date: Date(timeIntervalSinceNow: 86400)))
    }
    
    var input: Input
    var output: Output
    var disposeBag: DisposeBag
    
    init(input: Input = Input(), output: Output = Output()) {
        print("registerViewModel 리소스 생성되었습니다.")
        self.input = input
        self.output = output
        self.disposeBag = DisposeBag()
        setDateRelay()
    }
    
    deinit {
        print("registerViewModel 리소스 반환되었습니다.")
    }
    
    func setDateRelay() {
//        self.input.reloadDate
//            .do(onNext: { str in print("여기 나오면 승산있다. \(str)") })
//            .bind(to: self.output.startDateRelay)
//            .disposed(by: disposeBag)
        
//        self.input.reloadDate
//            .subscribe(onNext: { [weak self] data in
//                if data.contains("Start Date|") {
//                    data.split(separator: "|")[1]
//                    self?.output.startDateRelay
//                        .accept(<#T##event: String##String#>)
//                } else {
//                    se
//                }
//                
//            })
//            .disposed(by: disposeBag)
//        calendarViewModel.output.startDateRelay
//            .subscribe(onNext: { [weak self] date in
//                self?.output.startDateRelay.accept(date)
//                print("여기는 registerViewModel에서 calendarViewModel.output.startDateRelay 상태를 파악하는 곳이다. \(String(describing: self?.calendarViewModel.output.startDateRelay.value))")
//            })
//            .disposed(by: disposeBag)
        
        
//        calendarViewModel.output.startDateRelay
//            .bind(to: self.output.startDateRelay)
//            .disposed(by: disposeBag)
        
//        calendarViewModel.output.startDateRelay
//        self.output.startDateRelay
//            .subscribe(onNext: { date in
//                print("registerViewModel에서 date를 출력하면 다음과 같다.")
//                print(date)
////                print(self?.calendarViewModel.output.startDateRelay.value ?? "default value")
//            })
//            .disposed(by: disposeBag)
//        
////        calendarViewModel.output.deadlineDateRelay
//        self.output.deadlineDateRelay
//            .subscribe(onNext: { date in
////                self?.output.deadlineDateRelay.accept(date)
////                print("여기는 registerViewModel에서 calendarViewModel.output.deadlineDateRelay 상태를 파악하는 곳이다. \(String(describing: self?.calendarViewModel.output.deadlineDateRelay.value))")
//                
//            })
//            .disposed(by: disposeBag)
    }
}
