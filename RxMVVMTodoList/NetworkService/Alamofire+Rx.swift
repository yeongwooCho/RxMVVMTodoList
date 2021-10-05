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
        return Observable.create { observer -> Disposable in // Observable: 이벤트 발생시 다양한 조건으로 이벤트를 보낼 건지를 정의
            AF.request(self.url, // alamofire를 활용한 request
                       method: .get)
                .validate(statusCode: 200..<300) // 200 ~ 299
                .responseJSON(completionHandler: { response in // 응답은 json으로 받는다
                    switch response.result {
                    case .success(let obj):
                        guard let objArray = obj as? [[String: Any]]  else { // parsing부분 json -> data
                            print("Parsing되는 데이터가 DB에 존재하지 않는다.")
                            observer.onNext([])
//                            observer.onError(response.error ?? GetFailureReason.notFound)
                            completion([])
                            return
                        }
                        do {
                            let data = try JSONSerialization.data(withJSONObject: objArray, options: [])
                            let decoder = JSONDecoder()
                            let todos = try decoder.decode([Todo].self, from: data)
                            observer.onNext(todos) // 오류 발생이 나지 않으면 subscribe 한 모든 Observer에게 next 이벤트 전달
                            completion(todos) // escaping closure. 함수 실행이 완료되었을때 실행된다.
                        } catch let error {
                            observer.onError(error)
                            completion([])
//                            print("error: \(error.localizedDescription)")
                        }
                    case .failure(let error):
                        observer.onError(error)
//                        print(error.localizedDescription)
                        completion([])
                    }
                })
                return Disposables.create() // 그 후, 리소스를 반환하는 disposable를 생성한다
        } // 결국 이러한 Observable 입니다~ 이거 구독하면 이러이러한 조건에서 이벤트를 보낼꺼에요~ 정의한것
    } // 결국 requestGet을 구독하는 Observer는 전달받은 데이터를 처리하면 된다.
    
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
//                        observer.onCompleted()
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
