//
//  Calendar.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/29.
//

import Foundation
import FSCalendar

class Calendar {
    
    private var calendar: FSCalendar = FSCalendar()
    
    init(frameView: UIView) {
        self.calendar = setLayoutCalendar(frameView: frameView)
    }
    
    func setLayoutCalendar(frameView: UIView) -> FSCalendar {
        
//        let frame: CGRect = CGRect(x: frameView.bounds.minX, y: frameView.bounds.minY, width: frameView.bounds.width, height: frameView.bounds.height)
//        let calendar = FSCalendar(frame: frame)
        let calendar = FSCalendar(frame: frameView.frame)
        // 달력의 평일 날짜 색깔
        calendar.appearance.titleDefaultColor = .black // 달력의 토,일 날짜 색깔
        calendar.appearance.titleWeekendColor = .red // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .systemPink // 달력의 요일 글자 색깔
        calendar.appearance.weekdayTextColor = .orange
        
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY년 M월"

        // 달력의 요일 글자 바꾸는 방법 1
        calendar.locale = Locale(identifier: "ko_KR")
                
        // 달력의 요일 글자 바꾸는 방법 2
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        return calendar
    }
    
    func getCalendar() -> FSCalendar {
        return self.calendar 
    }
}
