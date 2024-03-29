//
//  CarPoolListView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct CarPoolListView: View {
    @EnvironmentObject private var appData: AppData
    @StateObject private var viewModel: ViewModel
    
    @Binding var tabViewIsHidden: Bool
    
    let rows: [GridItem] = [
        GridItem(.flexible(minimum: 225))
    ]
    
    init(
        user: User,
        tabViewIsHidden: Binding<Bool>,
        carPoolManager: CarPoolManagerType,
        messageManager: MessageManagerType
    ) {
        self._tabViewIsHidden = tabViewIsHidden
        let viewModel = ViewModel(
            user: user,
            carPoolManager: carPoolManager,
            messageManager: messageManager
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            
            if let joinedCarPool = viewModel.joinedCarPool,
               let user = appData.currentUser
            {
                NavigationLink(
                    "",
                    isActive: $viewModel.navigateToChatRoomView,
                    destination: {
                        ChatLogView(
                            carPool: joinedCarPool,
                            user: user,
                            tabViewIsHidden: $tabViewIsHidden,
                            carPoolManager: appData.carPoolManager,
                            messageManager: appData.messageManager
                        )
                    }
                )
            }
            
            VStack(spacing: 0) {
                Button(action: {
                    viewModel.fetchCarPoolList()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.theme.primaryTextColor)
                        .padding(13)
                })
                .background(Color.theme.backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 1)
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 11)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("카풀 목록")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()

                        NavigationLink {
                            if let user = appData.currentUser {
                                CarPoolGenerateView(
                                    currentUser: user,
                                    departurePlaceText: appData.departurePlaceName,
                                    destinationText: appData.destinationName,
                                    departurePlaceCoordinate: appData.departureLocationCoordinate,
                                    destinationCoordinate: appData.destinationCoordinate,
                                    carPoolManager: appData.carPoolManager,
                                    messageManager: appData.messageManager,
                                    locationSearchManager: appData.locationSearchManager,
                                    chatLogViewIsPresented: $viewModel.navigateToChatRoomView,
                                    joinedRoom: $viewModel.joinedCarPool
                                )
                            }
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    
                    if viewModel.carPoolList.isEmpty {
                        CharacterSayView(text: "+버튼을 눌러\n첫번째 채팅방을 생성해보세요!")
                            .padding(.top, 26)
                            .padding(.bottom, 65)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: rows, spacing: 9, content: {
                                ForEach(viewModel.carPoolList) { carPool in
                                    Button(action: {
                                        didSelectListItem(carPool)
                                    }, label: {
                                        CarPoolCell(carPool: carPool)
                                    })
                                }
                            })
                            .padding(.horizontal, 21)
                            .padding(.bottom, 50)
                        }
                        .padding(.top, 14)
                    }
                }
                .background(Color.theme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(radius: 2)
                .onReceive(viewModel.$alertIsPresented, perform: { isPresented in
                    if isPresented {
                        appData.alert(
                            message: viewModel.alertMessage,
                            role: .negative(action: { })
                        )
                    }
                })
                
            }
        }
        .onAppear {
            viewModel.fetchCarPoolList()
        }
    }
    
    func didSelectListItem(_ carPool: CarPool) {
        if viewModel.isMyCarPool(carPool) {
            viewModel.joinedCarPool = carPool
            viewModel.navigateToChatRoomView = true
        } else {
            appData.alert(
                message: "카풀방에 참여하시겠습니까?",
                role: .both(
                    positiveAction: {
                        viewModel.joinCarPool(with: carPool)
                    },
                    negativeAction: { }
                )
            )
        }
    }
}

#Preview {
    CarPoolListView(
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
}
