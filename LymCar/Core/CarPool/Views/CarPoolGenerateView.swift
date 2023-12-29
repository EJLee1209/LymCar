//
//  CarPoolGenerateView.swift
//  LymCar
//
//  Created by 이은재 on 12/24/23.
//

import SwiftUI

struct CarPoolGenerateView: View {
    @EnvironmentObject var AppData: AppData
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    @State var locationSearchResultViewIsPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            Color.theme.backgroundColor
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                .padding(.top, 24)
            
            GeometryReader { _ in
                VStack(spacing: 0) {
                    
                    /// 위치 검색 뷰
                    LocationSearchInputView(
                        departurePlaceText: $viewModel.departurePlaceText,
                        destinationText: $viewModel.destinationText,
                        rightContentType: .swap,
                        rightContentTapEvent: viewModel.swapLocation,
                        departureTextFieldOnSubmit: {
                            viewModel.localSearch(searchType: .departurePlace)
                            locationSearchResultViewIsPresented = true
                        },
                        destinationTextFieldOnSubmit: {
                            viewModel.localSearch(searchType: .destination)
                            locationSearchResultViewIsPresented = true
                        }
                    )
                    .padding(.trailing, 16)
                    .background(Color.theme.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 12)
                    .padding(.top, 13)
                    .shadow(radius: 4)
                    
                    /// 방 옵션 설정 뷰
                    VStack(spacing: 25) {
                        CountView(
                            title: "최대 인원수",
                            count: $viewModel.personCount
                        )
                        
                        TimePickerView(title: "출발시간", date: $viewModel.departureDate)
                        
                        OptionView(
                            title: "탑승 옵션",
                            isActivate: $viewModel.genderOptionIsActivate
                        )
                        
                        Spacer()
                        
                        /// 방 만들기 버튼
                        Button(action: {
                            viewModel.createCarPool()
                        }, label: {
                            Text("방 만들기")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                        })
                        .background(Color.theme.brandColor)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .shadow(radius: 4, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 36)
                    .padding(.bottom, 47)
                    
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle("방 만들기")
        .alert(
            viewModel.alertMessage,
            isPresented: $viewModel.alertIsPresented
        ) {
            Button {
                viewModel.viewState = .none
            } label: {
                Text("확인")
                    .font(.system(size: 15))
            }
        }
        .sheet(isPresented: $locationSearchResultViewIsPresented) {
            LocationSearchResultView()
                .environmentObject(viewModel)
        }
        .onReceive(viewModel.$viewState, perform: { viewState in
            switch viewState {
            case .successToNetworkRequest(let carPool):
                AppData.userCarPoolList.append(carPool)
                dismiss()
            default:
                break
            }
        })
        .loadingProgress(viewState: $viewModel.viewState)
        
    }
}

#Preview {
    CarPoolGenerateView(
        viewModel: .init(
            currentUser: .init(email: "", gender: .male, name: "", uid: ""),
            departurePlaceText: "강남역",
            destinationText: "강남역 스타벅스",
            departurePlaceCoordinate: .init(latitude: 37.1234, longitude: 127.1234),
            destinationCoordinate: .init(latitude: 37.1234, longitude: 127.1234),
            carPoolManager: CarPoolManager(),
            locationSearchManager: LocationSearchManager()
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
