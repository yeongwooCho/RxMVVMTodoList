//
//  ObservableViewModel.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

//import Foundation
//import Alamofire
//import RxSwift
//import RxCocoa
//
//
////protocol ObservableViewModelProtocol {
////    func fetchEmployees()
////    func setError(_ message: String)
////    var employees: Observable<[Todo]> { get set } // (1)
////    var errorMessage: Observable<String?> { get set }
////    var error: Observable<Bool> { get set }
////}
//
//class ObservableTest<T> { // Observable의 value값이 바뀌면 listener이 호출된다.
//    private var listener: ((T) -> Void)?
//
//    var value: T {
//        didSet {
//            listener?(value)
//        }
//    }
//
//    init(_ value: T) {
//        self.value = value
//    }
//
//    func bind(_ closure: @escaping (T) -> Void) {
//        closure(value)
//        listener = closure
//    }
//}
//
//protocol ObservableTestViewModelInterface {
//    func fetchTodos()
//    func setError(_ message: String)
//    var todos: ObservableTest<[Todo]> { get set } // (1)
//    var errorMessage: ObservableTest<String?> { get set }
//    var error: ObservableTest<Bool> { get set }
//}
//
//class ObservableTestViewModel: ObservableTestViewModelInterface {
//
//    var apiManager: AlamofireRxCall
//    var errorMessage: ObservableTest<String?> = ObservableTest(nil)
//    var error: ObservableTest<Bool> = ObservableTest(false)
////    var apiManager: APIManager?
//    var todos: ObservableTest<[Todo]> = ObservableTest([]) // (2)
//
//    init(manager: AlamofireRxCall = AlamofireRxCall()) {
//        self.apiManager = manager
//    }
//
//    func setAPIManager(manager: AlamofireRxCall) {
//        self.apiManager = manager
//    }
//
//    func fetchTodos() {
//        self.apiManager.requestGet { todos in
//            self.todos  = todos
//        }
//
//        self.apiManager.getEmployees { (result: DataResponse<AlamofireRxCall, AFError>) in
//            switch result.result {
//            case .success(let response):
//                if response.status == "success" {
//                    self.employees = Observable(response.data) // (3)
//                    return
//                }
//                self.setError("에러 메시지")
//            case .failure:
//                self.setError("에러 메시지")
//            }
//        }
//    }
//    func setError(_ message: String) {
//        self.errorMessage = ObservableTest(message)
//        self.error = ObservableTest(true)
//    }
//}
//
