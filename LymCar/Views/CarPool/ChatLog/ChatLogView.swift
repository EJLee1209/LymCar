//
//  CarPoolChatRoomView.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI
import Combine

struct ChatLogView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var appDelegate: AppDelegate
    @StateObject private var viewModel: ViewModel
    
    @Binding var tabViewIsHidden: Bool
    
    private var keyboardisShowingPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification).map { _ in true },
            NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification).map { _ in false }
        ).eraseToAnyPublisher()
    }
    
    init(
        carPool: CarPool,
        user: User,
        tabViewIsHidden: Binding<Bool>,
        carPoolManager: CarPoolManagerType,
        messageManager: MessageManagerType
    ) {
        self._tabViewIsHidden = tabViewIsHidden
        let viewModel = ViewModel(
            carPool: carPool,
            currentUser: user,
            carPoolManager: carPoolManager,
            messageManager: messageManager
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
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
                Text("인원 \(viewModel.carPool.personCount)명")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                
                ScrollViewReader { proxy in
                    /// 채팅뷰
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.messages, id: \.self) { wrappedMessage in
                                MessageCell(wrappedMessage: wrappedMessage)
                                    .id(wrappedMessage)
                                    .padding(.top, 24)
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(viewModel.messages.last, anchor: .bottom)
                        }
                        .onReceive(viewModel.$newMessages) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                                proxy.scrollTo(viewModel.messages.last, anchor: .bottom)
                            })
                        }
                        .onReceive(keyboardisShowingPublisher, perform: { isShowing in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last)
                            }
                        })
                    }
                    .refreshable {
                        viewModel.fetchMessages()
                    }
                    
                }
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
                    Button(action: viewModel.exitCarPoolButtonAction) {
                        Text("채팅방 나가기")
                    }
                    
                    if viewModel.showDeactivateCarPoolButton {
                        Button(action: viewModel.deactivateCarPoolButtonAction) {
                            Text("카풀 마감하기")
                        }
                    }
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
        .alert(
            role: viewModel.alertRole,
            alertMessage: viewModel.alertMessage,
            isPresented: $viewModel.alertIsPresented
        )
        .onReceive(viewModel.$isExit, perform: { isExit in
            if isExit {
                dismiss()
            }
        })
        .onAppear {
            viewModel.fetchMessages()
            viewModel.subscribeCarPool()
            appDelegate.viewingChatRoomId = viewModel.carPool.id
            
            tabViewIsHidden = true
        }
        .onDisappear {
            viewModel.onDisappear()
            appDelegate.viewingChatRoomId.removeAll()
            
            withAnimation {
                tabViewIsHidden = false
            }
        }
        
    }
}

#Preview {
    ChatLogView(
        carPool: .mock,
        user: .mock,
        tabViewIsHidden: .constant(true),
        carPoolManager: CarPoolManager(),
        messageManager: MessageManager()
    )
    .environmentObject(
        AppData(
            authManager: AuthManager(),
            carPoolManager: CarPoolManager(),
            locationSearchManager: LocationSearchManager(),
            messageManager: MessageManager()
        )
    )
    .environmentObject(AppDelegate())
}

