//
//  MenuCell.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import SwiftUI

enum RightContentType {
    case rightArrow
    case label(text: String)
    case none
}

struct MenuCell: View {
    let title: String
    let rightContentType: RightContentType
    let labelColor: Color
    
    init(
        title: String,
        rightContentType: RightContentType,
        labelColor: Color = Color.theme.secondaryTextColor
    ) {
        self.title = title
        self.rightContentType = rightContentType
        self.labelColor = labelColor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(labelColor)
                Spacer()
                
                switch rightContentType {
                case .rightArrow:
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.gray)
                case .label(let text):
                    Text(text)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.theme.secondaryTextColor)
                case .none:
                    Spacer()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.theme.backgroundColor)    
        }
    }
}

#Preview {
    MenuCell(
        title: "계정정보",
        rightContentType: .rightArrow
    )
}
