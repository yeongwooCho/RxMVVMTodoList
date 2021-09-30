//
//  ObservableTest.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import Foundation
import RxSwift

//class ObservableTest<T> {
//    // Observable의 value값이 바뀌면 listener이 호출된다.
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
//protocol ObservableTestViewModelProtocol {
//    func fetchTodos()
////    func setError(_ message: String)
//    var todos: ObservableTest<[Todo]> { get set }
////    var errorMessage: ObservableTest<String?> { get set }
////    var error: ObservableTest<Bool> { get set }
//}
