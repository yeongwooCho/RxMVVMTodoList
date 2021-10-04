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
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateAddButton: UIButton!
    @IBOutlet weak var deadLineDateLabel: UILabel!
    @IBOutlet weak var deadLineDateAddButton: UIButton!
    
    let registerTodoViewModel = RegisterTodoViewModel.shared
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLabel()
        setupAddButtonSelected()
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
    
    private func setupAddButtonSelected() {
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
    }
}
