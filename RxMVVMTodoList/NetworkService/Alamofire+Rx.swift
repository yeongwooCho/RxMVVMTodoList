//
//  Alamofire+Rx.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol RxNetworkCallInterface {
    typealias T = Todo
    var url: String { get }
    func requestGet(completion: @escaping ([T]) -> Void) -> Single<[T]>
    func requestPut(params: [T], completion: @escaping ([T]) -> Void) -> Single<[T]>
}

class AlamofireRxCall: RxNetworkCallInterface {
    var url = "https://rxtodolist-6d4e2-default-rtdb.asia-southeast1.firebasedatabase.app/todos.json"
//    var url = "https://sendy-todolist-default-rtdb.asia-southeast1.firebasedatabase.app/todos.json"

    func requestGet(completion: @escaping ([T]) -> Void) -> Single<[T]> {
        return Single<[T]>.create { (single) -> Disposable in
            AF.request(self.url, // alamofire를 활용한 request
                       method: .get)
                .validate(statusCode: 200..<300) // 200 ~ 299
                .responseJSON(completionHandler: { response in // 응답은 json으로 받는다
                    switch response.result {
                    case .success(let obj):
                        
                        guard let objArray = obj as? [[String: Any]]  else { // parsing부분 json -> data
                            print("Parsing되는 데이터가 DB에 존재하지 않는다.")
                            single(.success([]))
                            completion([])
                            return
                        }
                        do {
                            let data = try JSONSerialization.data(withJSONObject: objArray, options: [])
                            let decoder = JSONDecoder()
                            let todos = try decoder.decode([Todo].self, from: data)
                            print("success requestGet: \(todos)")
                            single(.success(todos))
                            completion(todos) // escaping closure. 함수 실행이 완료되었을때 실행된다.
                        } catch let error {
                            single(.failure(error))
                            completion([])
                        }
                    case .failure(let error):
                        single(.failure(error))
                        completion([])
                    }
                })
                return Disposables.create()
        }
    }
    
    func requestPut(params: [T], completion: @escaping ([T]) -> Void) -> Single<[T]> {
        return Single<[T]>.create { single in
            AF.request(self.url,
                       method: .put,
                       parameters: params,
                       encoder: JSONParameterEncoder.default,
                       headers: ["Content-Type": "application/json", "Accept": "application/json"])
                .validate(statusCode: 200..<300)
                .responseString { response in
                    switch response.result {
                    case .success: // 성공했다면 put한 데이터를 이벤트로 보낸다.
                        single(.success(params))
                        completion(params)
                    case .failure(let error):
                        single(.failure(error))
                        print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    }
                }
            return Disposables.create()
        }
    }
}
