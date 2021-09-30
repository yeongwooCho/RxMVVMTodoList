//
//  RegisterTodoViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/29.
//

import UIKit
import FSCalendar

class RegisterTodoViewController: UIViewController {

    fileprivate weak var calendar: FSCalendar!
    
//    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateAddButton: UIButton!
    
    @IBOutlet weak var deadLineDateLabel: UILabel!
    @IBOutlet weak var deadLineDateAddButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 10
        startDateLabel.layer.borderWidth = 1
        startDateLabel.layer.cornerRadius = 10
        startDateAddButton.layer.cornerRadius = 10
        deadLineDateLabel.layer.borderWidth = 1
        deadLineDateLabel.layer.cornerRadius = 10
        deadLineDateAddButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupItemSelected() {
//        startDateAddButton.rx.tap
//            .single()
        
//        tableView.rx.itemSelected
//            .subscribe(onNext: { [weak self] indexPath in
//                guard let detailVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoDetailViewController.identifier) as? TodoDetailViewController else { return }
//                let selectedTodo = self?.todoListViewModel.output.todoList.value[indexPath.item]
//                detailVC.todoDetailViewModel.input.todoInfo.onNext(selectedTodo)
//                detailVC.modalPresentationStyle = .fullScreen
//                self?.present(detailVC, animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
    }
}

