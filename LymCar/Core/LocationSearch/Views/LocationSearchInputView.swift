//
//  LocationSearchInputView.swift
//  LymCar
//
//  Created by 이은재 on 12/24/23.
//

import SwiftUI

struct LocationSearchInputView: View {
    @Binding var startLocationText: String
    @Binding var destinationText: String
    let rightContentType: RightContentType
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 9) {
                TextField(text: $startLocationText) {
                    Text("현재 위치 또는 위치 검색")
                        .font(.system(size: 15))
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 14)
                .background(Color.theme.secondaryBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                TextField(text: $destinationText) {
                    Text("어디로 갈까요?")
                        .font(.system(size: 15))
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 14)
                .background(Color.theme.secondaryBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(.leading, 9)
            .padding(.vertical, 9)
            
            Image(rightContentType.rawValue)
        }
    }
}

#Preview {
    LocationSearchInputView(
        startLocationText: .constant(""),
        destinationText: .constant(""),
        rightContentType: .swap
    )
}

extension LocationSearchInputView {
    enum RightContentType: String {
        case search
        case swap
    }
}
