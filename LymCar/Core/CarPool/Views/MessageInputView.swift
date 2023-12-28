//
//  MessageInputView.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    let buttonAction: () -> Void
    
    var body: some View {
        HStack {
            TextField(text: $messageText) {
                Text("대화를 통해 약속을 잡아보세요!")
            }
            Button {
                buttonAction()
            } label: {
                Image("arrow-up-circle")
            }
        }
        .padding(14)
        .background(Color.theme.secondaryBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 12)
        .padding(.bottom)
    }
}

#Preview {
    MessageInputView(
        messageText: .constant(""),
        buttonAction: {  }
    )
}
