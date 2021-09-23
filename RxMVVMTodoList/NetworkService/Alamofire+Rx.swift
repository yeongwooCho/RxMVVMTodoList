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
    var url: String { get }
    func requestGet(completion: @escaping ([Todo]) -> Void) -> Observable<[Todo]>
    func requestPut(params: [Todo], completion: @escaping ([Todo]) -> Void) -> Observable<[Todo]>
}

class AlamofireRxCall: RxNetworkCallInterface {
    
    enum GetFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }
    
    var url = "https://sendy-todolist-default-rtdb.asia-southeast1.firebasedatabase.app/todos.json"

    func requestGet(completion: @escaping ([Todo]) -> Void) -> Observable<[Todo]> {
        return Observable.create { observer -> Disposable in
            AF.request(self.url,
                       method: .get)
                .validate(statusCode: 200..<300) // 200 ~ 299
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(let obj):
                        guard let objArray = obj as? [[String: Any]]  else {
                            observer.onError(response.error ?? GetFailureReason.notFound)
//                            completion([])
                            return
                        }
                        do {
                            let data = try JSONSerialization.data(withJSONObject: objArray, options: [])
                            let decoder = JSONDecoder()
                            let todos = try decoder.decode([Todo].self, from: data)
                            observer.onNext(todos)
                            completion(todos)
                        } catch let error {
                            observer.onError(error)
//                            print("error: \(error.localizedDescription)")
//                            completion([])
                        }
                    case .failure(let error):
                        observer.onError(error)
//                        print(error.localizedDescription)
//                        completion([])
                    }
                })
                return Disposables.create()
        }
    }
    
    func requestPut(params: [Todo], completion: @escaping ([Todo]) -> Void) -> Observable<[Todo]> {
        return Observable.create { observer in
            AF.request(self.url,
                       method: .put,
                       parameters: params,
                       encoder: JSONParameterEncoder.default,
                       headers: ["Content-Type": "application/json", "Accept": "application/json"])
                .validate(statusCode: 200..<300)
                .responseString { response in
                    switch response.result {
                    case .success:
                        observer.onNext(params)
                        observer.onCompleted()
                        completion(params)
                    case .failure(let error):
                        observer.onError(error)
                        print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    }
                }
            return Disposables.create()
        }
    }
}
