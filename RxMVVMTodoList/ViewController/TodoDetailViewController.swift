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

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var registerTimeLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var deadlineDateLabel: UILabel!
    
    @IBOutlet weak var editDetailTextField: UITextField!
    @IBOutlet weak var editStartDateTextField: UITextField!
    @IBOutlet weak var editDeadlineDateTextField: UITextField!
    
    let todoDetailViewModel = TodoDetailViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindUI()
        setButtonTap()
        setWillEdit()
        setDidEdit()
    }
    
    private func setBindUI() {
        todoDetailViewModel.output.todo
            .subscribe(onNext: { [weak self] todo in
                self?.detailLabel.text = todo.detail
                self?.idLabel.text = String(todo.id)
                self?.registerTimeLabel.text = Date.dateToString(date: Date(timeIntervalSince1970: todo.id), isTime: true)
                self?.startDateLabel.text = todo.startDate
                self?.deadlineDateLabel.text = todo.deadlineDate
                self?.editUpdateUI(edit: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func setButtonTap() {
        self.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setWillEdit() {
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.editUpdateUI(edit: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setDidEdit() {
        completedButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.editUpdateUI(edit: false)
                do { // 수정 자료만 던진다. value를 실제 객체 todo로 만드는 것 까지 진행
                    let obj = try self?.todoDetailViewModel.input.todoInfo.value().map{ Todo.init(obj: $0) }
                    if var todo = obj, let detail = self?.editDetailTextField.text, let startDate = self?.editStartDateTextField.text, let deadlineDate = self?.editDeadlineDateTextField.text {
                        guard let todoListVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoListViewController.identifier) as? TodoListViewController else { return }
                        todoListVC.todoListViewModel.updateEditingTodos(obj: todo, detail: detail, startDate: startDate, deadlineDate: deadlineDate)
                        todo.update(detail: detail, isDone: false, startDate: startDate, deadlineDate: deadlineDate)
                        self?.todoDetailViewModel.input.todoInfo.onNext(todo)
                    }
                } catch let error {
                    print("error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func editUpdateUI(edit: Bool) {
        self.editDetailTextField.isHidden = !edit
        self.editStartDateTextField.isHidden = !edit
        self.editDeadlineDateTextField.isHidden = !edit
        self.completedButton.isHidden = !edit
        self.editButton.isHidden = edit
    }
}
