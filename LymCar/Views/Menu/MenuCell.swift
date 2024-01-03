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
    let imageName: String?
    let title: String
    let rightContentType: RightContentType
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if let imageName = imageName {
                    Image(imageName)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryTextColor)
                    .padding(.horizontal, 17)
                Spacer()
                
                switch rightContentType {
                case .rightArrow:
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.theme.secondaryBackgroundColor)
                case .label(let text):
                    Text(text)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.theme.secondaryTextColor)
                case .none:
                    Spacer()
                }
            }
            .padding(.horizontal, 19)
            .padding(.vertical, 12)
            .background(Color.theme.backgroundColor)
            
            Divider()
        }
    }
}

#Preview {
    MenuCell(
        imageName: nil,
        title: "계정정보",
        rightContentType: .rightArrow
    )
}
