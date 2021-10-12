//
//  garbage.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/30.
//

import Foundation

//
//        // keyboard Detection
//        // MARK: 이거는 Rx기반 Observable, Observer을 통한 이벤트 전달 방법 존재한지 확인하기
//        // 키보드 등장, 나감을 observe하다가 발생하면 #selector에 해당하는 함수를 실행한다.
//        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        

//// rx 기반이 아닌 NotificationCenter에 의한 이벤트 전달방식
//// MARK: rx 기반 있는지 확인하고, 적용하기
//extension TodoListViewController {
//    @objc private func adjustInputView(noti: Notification) {
//        guard let userInfo = noti.userInfo else { return }
//        // 키보드 높이에 따른 인풋뷰 위치 변경
//        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//
//        if noti.name == UIResponder.keyboardWillShowNotification {
//            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
//            inputViewBottom.constant = adjustmentHeight
//        } else {
//            inputViewBottom.constant = 0
//        }
//        print("---> Keyboard End Frame: \(keyboardFrame)")
//    }
//}






//        tableView.rx.itemSelected
//            .subscribe(onNext: { [weak self] indexPath in
//                guard let detailVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoDetailViewController.identifier) as? TodoDetailViewController else { return }
//                let selectedTodo = self?.todoListViewModel.output.sectionTodoList.value[indexPath.section].items[indexPath.item]
//                detailVC.todoDetailViewModel.input.todoInfo.onNext(selectedTodo)
//                self?.present(detailVC, animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
    






//    func requestGet(completion: @escaping ([Todo]) -> Void) -> Observable<[Todo]> {
//        return Observable.create { observer -> Disposable in // Observable: 이벤트 발생시 다양한 조건으로 이벤트를 보낼 건지를 정의
//            AF.request(self.url, // alamofire를 활용한 request
//                       method: .get)
//                .validate(statusCode: 200..<300) // 200 ~ 299
//                .responseJSON(completionHandler: { response in // 응답은 json으로 받는다
//                    switch response.result {
//                    case .success(let obj):
//                        guard let objArray = obj as? [[String: Any]]  else { // parsing부분 json -> data
//                            print("Parsing되는 데이터가 DB에 존재하지 않는다.")
//                            observer.onNext([])
////                            observer.onError(response.error ?? GetFailureReason.notFound)
//                            completion([])
//                            return
//                        }
//                        do {
//                            let data = try JSONSerialization.data(withJSONObject: objArray, options: [])
//                            let decoder = JSONDecoder()
//                            let todos = try decoder.decode([Todo].self, from: data)
//                            observer.onNext(todos) // 오류 발생이 나지 않으면 subscribe 한 모든 Observer에게 next 이벤트 전달
//                            completion(todos) // escaping closure. 함수 실행이 완료되었을때 실행된다.
//                        } catch let error {
//                            observer.onError(error)
//                            completion([])
////                            print("error: \(error.localizedDescription)")
//                        }
//                    case .failure(let error):
//                        observer.onError(error)
////                        print(error.localizedDescription)
//                        completion([])
//                    }
//                })
//                return Disposables.create() // 그 후, 리소스를 반환하는 disposable를 생성한다
//        } // 결국 이러한 Observable 입니다~ 이거 구독하면 이러이러한 조건에서 이벤트를 보낼꺼에요~ 정의한것
//    } // 결국 requestGet을 구독하는 Observer는 전달받은 데이터를 처리하면 된다.

//    func requestPut(params: [Todo], completion: @escaping ([Todo]) -> Void) -> Observable<[Todo]> {
//        return Observable.create { observer in
//            AF.request(self.url,
//                       method: .put,
//                       parameters: params,
//                       encoder: JSONParameterEncoder.default,
//                       headers: ["Content-Type": "application/json", "Accept": "application/json"])
//                .validate(statusCode: 200..<300)
//                .responseString { response in
//                    switch response.result {
//                    case .success:
//                        observer.onNext(params)
////                        observer.onCompleted()
//                        completion(params)
//                    case .failure(let error):
//                        observer.onError(error)
//                        print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
//                    }
//                }
//            return Disposables.create()
//        }
//    }


//enum GetFailureReason: Int, Error {
//    case unAuthorized = 401
//    case notFound = 404
//}




//    @IBOutlet weak var checkButton: UIButton!
//    @IBOutlet weak var completedButton: UIButton!
//    @IBOutlet weak var strikeThroughView: UIView!
//    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!

//
//    var completedButtonTapHandler: (() -> Void)?
//
//    // 셀이 화면에서 깨어날 때
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        reset()
//    }
//
//    // 재사용되는 셀의 속성을 초기화 하는 과정
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        reset()
//    }
//
//    func updateUI(todo: Todo) {
////        checkButton.isSelected = todo.isDone
//        descriptionLabel.text = todo.detail
////        descriptionLabel.alpha = todo.isDone ? 0.2 : 1
////        completedButton.isHidden = todo.isDone == false
////        showStrikeThrough(todo.isDone)
//    }
//
//    // check가 되었을 때, 등장하는 가림막 view의 width 변경
//    private func showStrikeThrough(_ show: Bool) {
////        if show {
////            strikeThroughWidth.constant = descriptionLabel.bounds.width
////        } else {
////            strikeThroughWidth.constant = 0
////        }
//    }
//
//    private func reset() {  // check 가 아닌 본래의 상태
//        descriptionLabel.alpha = 1
////        completedButton.isHidden = true
////        showStrikeThrough(false)
//    }
//
//    @IBAction func checkButtonTapped(_ sender: Any) {
////        checkButton.isSelected = !checkButton.isSelected
////        let isDone = checkButton.isSelected
////        descriptionLabel.alpha = isDone ? 0.2 : 1
////        completedButton.isHidden = !isDone
////        showStrikeThrough(isDone)
//    }
//
//    @IBAction func completedButtonTapped(_ sender: Any) {
////        completedButtonTapHandler?()
//    }
//}
