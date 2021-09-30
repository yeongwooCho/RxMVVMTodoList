//
//  CalendarViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/29.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupCalendar()
    }

}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    private func setupCalendar() {
//        calendarView.
        let calendar = Calendar(frameView: calendar).getCalendar()
//        calendarView.dataSource = self
//        calendarView.delegate = self
//        view.addSubview(Calendar(frameView: calendarView).getCalendar())
//        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
//        self.calendar = calendar

    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectDate = dateFormatter.string(from: date)
        print(selectDate)
    }
}
