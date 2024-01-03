//
//  MessageInputView.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var text: String
    let sendButtonAction: () -> Void
    
    var body: some View {
        HStack {
            TextField(text: $text) {
                Text("대화를 통해 약속을 잡아보세요!")
                    .font(.system(size: 14))
            }
            .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button {
                    sendButtonAction()
                } label: {
                    Image("arrow-up-circle")
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(Color.theme.secondaryBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 12)
        .padding(.bottom)
    }
}

#Preview {
    MessageInputView(
        text: .constant(""), sendButtonAction: { }
    )
        
}
