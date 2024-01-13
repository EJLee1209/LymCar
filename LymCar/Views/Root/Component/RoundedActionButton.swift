//
//  RoundedActionButton.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import SwiftUI

struct RoundedActionButton: View {
    let label: String
    let action: () -> Void
    let backgroundColor: Color
    let labelColor: Color
    
    init(
        label: String,
        action: @escaping () -> Void,
        backgroundColor: Color = Color.theme.brandColor,
        labelColor: Color = .white
    ) {
        self.label = label
        self.action = action
        self.backgroundColor = backgroundColor
        self.labelColor = labelColor
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(label)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(labelColor)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
        })
        .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}

#Preview {
    RoundedActionButton(
        label: "로그인", action: { }
    )
}
