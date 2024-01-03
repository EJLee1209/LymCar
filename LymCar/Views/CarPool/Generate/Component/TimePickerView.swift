//
//  TimePickerView.swift
//  LymCar
//
//  Created by 이은재 on 12/24/23.
//

import SwiftUI

struct TimePickerView: View {
    let title: String
    @Binding var date: Date
    var dateRange: ClosedRange<Date> {
        let max = Calendar.current.date(
            byAdding: .weekOfMonth,
            value: 2,
            to: Date()
        )!
        return Date()...max
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.theme.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker(selection: $date, in: dateRange) {
                Text("언제 출발할까요?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryTextColor)
            }
        }
    }
}

#Preview {
    TimePickerView(
        title: "출발시간",
        date: .constant(Date())
    )
}
