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
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCalendar()
    }
    
    func updateUI() {
        guard let titleString = titleText else { return }
        titleLabel.text = titleString
    }
    
    func setupButtonTap() {
        selectButton.rx.tap
            .subscribe(onNext: { [weak self] buttonEvent in
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
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
        if self.titleText == "Start Date" {
            RegisterTodoViewModel.shared.output.startDateRelay
                .accept(Date.dateString(date: date))
        } else {
            RegisterTodoViewModel.shared.output.deadlineDateRelay
                .accept(Date.dateString(date: date))
        }
    }
}
