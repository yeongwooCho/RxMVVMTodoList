//
//  CalendarViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/29.
//

import UIKit
import FSCalendar
import RxSwift

class CalendarViewController: UIViewController {
    static let identifier = "CalendarViewController"
    
    @IBOutlet weak var calendar: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    var titleText: String?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI(title: self.titleText)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCalendar()
    }
    
    func updateUI(title: String?) {
        guard let titleString = title else { return }
        self.titleLabel?.text = titleString
        self.titleText = titleString
    }
    
    private func setupButtonTap() {
        selectButton.rx.tap
            .subscribe(onNext: { [weak self] buttonEvent in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    private func setupCalendar() {
        let calendar = Calendar(frameView: calendar).getCalendar()
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard let registerVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: RegisterTodoViewController.identifier) as? RegisterTodoViewController else { return }
//        guard let title = self.titleLabel.text else { return }
        guard let title = self.titleText else { return }
        if title == "Start Date" {
            registerVC.registerTodoViewModel.output.startDateRelay
                .accept(Date.dateToString(date: date, isTime: false))
        } else {
            registerVC.registerTodoViewModel.output.deadlineDateRelay
                .accept(Date.dateToString(date: date, isTime: false))
        }
    }
}
