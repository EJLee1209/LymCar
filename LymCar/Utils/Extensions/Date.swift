//
//  Date.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import Foundation

extension Date {
    func dateToString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
