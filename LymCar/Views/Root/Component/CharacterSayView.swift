//
//  CharacterSayView.swift
//  LymCar
//
//  Created by 이은재 on 1/12/24.
//

import SwiftUI

struct CharacterSayView: View {
    let text: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image("character")
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.theme.primaryTextColor)
                .multilineTextAlignment(.center)
        }
        
    }
}

#Preview {
    CharacterSayView(text: "+버튼을 눌러\n첫번째 채팅방을 생성해보세요!")
}
