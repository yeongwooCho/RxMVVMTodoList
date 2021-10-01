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
