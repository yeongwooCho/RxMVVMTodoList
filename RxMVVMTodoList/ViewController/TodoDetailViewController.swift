//
//  TodoDetailViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/23.
//

import UIKit
import RxSwift

class TodoDetailViewController: UIViewController {

    static let identifier = "TodoDetailViewController"

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registerTimeLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var deadlineDateLabel: UILabel!
    
    let todoDetailViewModel = TodoDetailViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindUI()
    }
    
    func setBindUI() {
        todoDetailViewModel.output.todo
            .subscribe(onNext: { [weak self] todo in
                self?.detailLabel.text = todo.detail
                self?.idLabel.text = String(todo.id)
                self?.registerTimeLabel.text = Date.dateToString(date: Date(timeIntervalSince1970: todo.id), isTime: true)
                self?.startDateLabel.text = todo.startDate
                self?.deadlineDateLabel.text = todo.deadlineDate
            })
            .disposed(by: disposeBag)
    }
}
