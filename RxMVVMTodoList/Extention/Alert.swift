//
//  Alert.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/10/06.
//

import UIKit
import Foundation
import RxSwift

extension UIAlertController {

    struct AlertAction {
        var title: String?
        var style: UIAlertAction.Style

        static func action(title: String?, style: UIAlertAction.Style = .default) -> AlertAction {
            return AlertAction(title: title, style: style)
        }
    }

    static func present(in viewController: UIViewController, title: String?, message: String?,
                        style: UIAlertController.Style, actions: [AlertAction]) -> Single<Int> {
        return Single<Int>.create { single in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            actions.enumerated().forEach { index, action in
                let action = UIAlertAction(title: action.title, style: action.style) { _ in
                    single(.success(index))
//                    observer.onNext(index)
//                    observer.onCompleted()
                }
                alertController.addAction(action)
            }
            viewController.present(alertController, animated: true, completion: nil)
            return Disposables.create { alertController.dismiss(animated: true, completion: nil) }
        }
    }
}
