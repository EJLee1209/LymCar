//
//  ShowCarPoolButton.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI

struct ShowCarPoolButton: View {
    @Binding var mapState: MapState
    
    var body: some View {
        Button(action: {
            withAnimation {
                mapState = .locationSelected
            }
        }, label: {
            Text("카풀 목록 보기")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.theme.primaryTextColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
        })
        .background(Color.theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 45))
        .overlay {
            RoundedRectangle(cornerRadius: 45)
                .stroke(lineWidth: 1)
                .fill(Color.theme.brandColor)
        }
    }
}

#Preview {
    ShowCarPoolButton(
        mapState: .constant(.none)
    )
}
