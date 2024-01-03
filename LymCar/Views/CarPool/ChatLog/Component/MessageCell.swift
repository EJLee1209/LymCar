//
//  MyMessageCell.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI



struct MessageCell: View {
    
    let wrappedMessage: WrappedMessage
    
    var body: some View {
        switch wrappedMessage {
        case .currentUser(let message):
            /// current user message cell
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Text(message.prettyTimestamp)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.theme.brandColor)
    
                    Text(message.text)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.theme.brandColor)
                        .cornerRadius(10, corners: [.topLeft, .topRight, .bottomLeft])
                }
                .padding(.leading, 50)
                .padding(.trailing, 10)
            }
            
        case .otherUser(let message):
            /// other user message cell
            HStack {
                Spacer()
    
                VStack(alignment: .leading) {
                    Text(message.sender.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.theme.primaryTextColor)
    
                    HStack(spacing: 8) {
                        Text(message.text)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.theme.primaryTextColor)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.theme.secondaryBackgroundColor)
                            .cornerRadius(10, corners: [.topLeft, .topRight, .bottomRight])
    
                        Text(message.prettyTimestamp)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.theme.brandColor)
    
                        Spacer()
                    }
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 50)
        case .system(let message):
            /// system message cell
            Text(message.text)
                .font(.system(size: 11, weight: .regular))
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.theme.secondaryTextColor)
        }
    }
}

#Preview {
    MessageCell(
        wrappedMessage: .currentUser(message: .mock)
    )
}
