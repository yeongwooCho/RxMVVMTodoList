//
//  Calendar.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/29.
//

import UIKit
import Foundation
import FSCalendar

class Calendar {
    private var calendar: FSCalendar = FSCalendar()
    
    init(frameView: UIView) {
        self.calendar = setLayoutCalendar(frameView: frameView)
    }
    
    deinit {
        self.calendar = FSCalendar()
    }
    
    func setLayoutCalendar(frameView: UIView) -> FSCalendar {
        let calendar = FSCalendar(frame: frameView.frame)
        
        calendar.appearance.titleDefaultColor = .black // 달력의 평일 날짜 색깔
        calendar.appearance.titleWeekendColor = .red // 달력의 토,일 날짜 색깔
        calendar.appearance.headerTitleColor = #colorLiteral(red: 0.1812617481, green: 0.3442890644, blue: 0.9237771034, alpha: 1) // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.weekdayTextColor = #colorLiteral(red: 0.1812617481, green: 0.3442890644, blue: 0.9237771034, alpha: 1) // 달력의 요일 글자 색깔
        calendar.appearance.selectionColor = #colorLiteral(red: 0.1812617481, green: 0.3442890644, blue: 0.9237771034, alpha: 1) // 선택했을때 색깔
        calendar.appearance.headerDateFormat = "YYYY년 M월" // 달력의 년월 글자 바꾸기
        calendar.locale = Locale(identifier: "ko_KR") // 한국달력
        return calendar
    }
    
    func getCalendar() -> FSCalendar {
        return self.calendar 
    }
}
