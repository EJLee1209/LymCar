//
//  CarPoolChatRoomView.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI

struct ChatRoomView: View {
    @EnvironmentObject var appData: AppData
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color.theme.brandColor
                    .ignoresSafeArea()
                
                Color.theme.backgroundColor
                    .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(.all, edges: .bottom)
                    .padding(.top, 24)
            }
            
            VStack {
                Text("인원 4명(남성끼리 타기)")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                
                /// 채팅뷰
                List {
                    ForEach(viewModel.messages, id: \.self) { wrappedMessage in
                        MessageCell(wrappedMessage: wrappedMessage)
                            .padding(.top, 24)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                
                
                MessageInputView(
                    text: $viewModel.messageText,
                    sendButtonAction: viewModel.sendMessage
                )
            }
            .padding(.top, 43)
            
            
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        print("DEBUG: 채팅방 나가기")
                    }, label: {
                        Text("채팅방 나가기")
                    })
                    
                    Button(action: {
                        print("DEBUG: 카풀 마감하기")
                    }, label: {
                        Text("카풀 마감하기")
                    })
                } label: {
                    VStack(spacing: 3) {
                        Circle()
                            .fill(.white)
                            .frame(width: 4, height: 4)
                        Circle()
                            .fill(.white)
                            .frame(width: 4, height: 4)
                        Circle()
                            .fill(.white)
                            .frame(width: 4, height: 4)
                            
                    }
                    .frame(width: 24, height: 24)
                }

            }
        }
        
        
    }
}

#Preview {
    ChatRoomView(
        viewModel: .init(
            carPool: CarPool.mock,
            currentUser: .mock,
            carPoolManager: CarPoolManager()
        )
    )
        .environmentObject(
            AppData(
                authManager: AuthManager(),
                carPoolManager: CarPoolManager(),
                locationSearchManager: LocationSearchManager()
            )
        )
}
