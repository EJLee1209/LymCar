//
//  CarPoolListView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct CarPoolListView: View {
    @EnvironmentObject var appData: AppData
    @StateObject var viewModel: ViewModel
    
    let rows: [GridItem] = [
        GridItem(.flexible(minimum: 225))
    ]
    
    var body: some View {
        ZStack {
            
            if let joinedCarPool = viewModel.joinedCarPool,
               let vm = appData.makeChatRoomVM(with: joinedCarPool)
            {
                NavigationLink(
                    "",
                    isActive: $viewModel.navigateToChatRoomView,
                    destination: {
                        ChatLogView(viewModel: vm)
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
                            carpoolGenderateViewNavigationLink
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    
                    if viewModel.carPoolList.isEmpty {
                        Image("character")
                            .padding(.top, 26)
                        Text("+버튼을 눌러\n첫번째 채팅방을 생성해보세요!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.theme.primaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 65)
                            .padding(.top, 16)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: rows, spacing: 9, content: {
                                ForEach(viewModel.carPoolList) { carPool in
                                    Button(action: {
                                        appData.alert(
                                            message: "카풀방에 참여하시겠습니까?",
                                            isPresented: true,
                                            role: .withAction({
                                                viewModel.joinCarPool(with: carPool)
                                            })
                                        )
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
                    appData.alert(
                        message: viewModel.alertMessage,
                        isPresented: isPresented,
                        role: .cancel
                    )
                })
                
            }
        }
        .onAppear {
            viewModel.fetchCarPoolList()
        }
    }
    
    @ViewBuilder
    var carpoolGenderateViewNavigationLink: some View {
        if let vm = appData.makeCarPoolGenerateVM() {
            CarPoolGenerateView(viewModel: vm)
        }
    }
}

#Preview {
    CarPoolListView(
        viewModel: .init(
            user: User.mock,
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
