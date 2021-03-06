//
//  RegisterTodoViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/29.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RegisterTodoViewController: UIViewController {
    static let identifier = "RegisterTodoViewController"
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateAddButton: UIButton!
    @IBOutlet weak var deadLineDateLabel: UILabel!
    @IBOutlet weak var deadLineDateAddButton: UIButton!
    @IBOutlet weak var addTaskButton: UIButton!
    
    let registerTodoViewModel = RegisterTodoViewModel.shared
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLabel()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLayout()
    }
    
    private func setupDateLabel() {
        registerTodoViewModel.output.startDateRelay
            .asDriver(onErrorJustReturn: "")
            .drive(startDateLabel.rx.text)
            .disposed(by: disposeBag)
        
        registerTodoViewModel.output.deadlineDateRelay
            .asDriver(onErrorJustReturn: "")
            .drive(deadLineDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupButton() {
        startDateAddButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let calendarVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: CalendarViewController.identifier) as? CalendarViewController else { return }
                calendarVC.titleText = "Start Date"
                calendarVC.modalPresentationStyle = .fullScreen
                self?.present(calendarVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
            
        deadLineDateAddButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let calendarVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: CalendarViewController.identifier) as? CalendarViewController else { return }
                calendarVC.titleText = "Deadline Date"
                calendarVC.modalPresentationStyle = .fullScreen
                self?.present(calendarVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        addTaskButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("addTaskButton tap")
                guard let detail = self?.titleTextField.text, !detail.isEmpty, let startDate = self?.startDateLabel.text, let deadlineDate = self?.deadLineDateLabel.text else {
                    self?.setupAlert()
                    return
                }
                let todo = Todo.init(detail: detail, isDone: false, startDate: startDate, deadlineDate: deadlineDate)
                self?.registerTodoViewModel.input.registerTodo.onNext(todo)
                self?.titleTextField.text?.removeAll() // textField reset
                
                self?.navigationController?.popViewController(animated: true) // todo list view로 전환
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 10
        startDateLabel.layer.borderWidth = 1
        startDateLabel.layer.cornerRadius = 10
        startDateAddButton.layer.cornerRadius = 10
        deadLineDateLabel.layer.borderWidth = 1
        deadLineDateLabel.layer.cornerRadius = 10
        deadLineDateAddButton.layer.cornerRadius = 10
        addTaskButton.layer.cornerRadius = 10
    }
    
    private func setupAlert() {
        let actions: [UIAlertController.AlertAction] = [
            .action(title: "OK", style: .destructive),
//            .action(title: "yes")
        ]

        UIAlertController
            .present(in: self, title: "Task를 입력해주세요", message: "정상적인 입력이 아닙니다.", style: .alert, actions: actions)
            .subscribe(onSuccess: { buttonIndex in
                print("alert buttonIndex: \(buttonIndex)") // button index에 따른 control
            }, onFailure: { error in
                print("alert error: \(error.localizedDescription)")
            }, onDisposed: {
                print("alert disposed")
            })
            .disposed(by: disposeBag)
    }
}
