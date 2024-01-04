//
//  ContentView.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var appData: AppData
    @StateObject private var viewModel: ViewModel
    @Binding var mapState: MapState
    
    init(
        mapState: Binding<MapState>,
        locationSearchManager: LocationSearchManagerType
    ) {
        _mapState = mapState
        _viewModel = .init(wrappedValue: ViewModel(locationSearchManager: locationSearchManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ZStack(alignment: .top) {
                    MapViewRepresentable(
                        mapViewModel: viewModel,
                        mapState: $mapState
                    )
                    .ignoresSafeArea()
                    if mapState == .none {
                        LocationSearchActivationView()
                            .padding(.top, 40)
                            .onTapGesture {
                                withAnimation(.spring) {
                                    mapState = .searchingForLocation
                                }
                            }
                    }
                    
                    if mapState == .locationSelected {
                        MapViewActionButton(
                            mapViewModel: viewModel,
                            mapState: $mapState
                        )
                        .padding()
                    }
                    
                }
                
                VStack(spacing: 9) {
                    ShowCarPoolButton(mapState: $mapState)
                    if !appData.userCarPoolList.isEmpty {
                        CarPoolShortcutListView()
                    }
                }
                .padding(.bottom, 122)
                
                
                if mapState == .searchingForLocation {
                    LocationSearchView(
                        viewModel: viewModel,
                        mapState: $mapState
                    )
                }
                
                /// bottom sheet - 카풀 목록
                if mapState == .locationSelected {
                    if let user = appData.currentUser {
                        CarPoolListView(
                            user: user,
                            carPoolManager: appData.carPoolManager,
                            messageManager: appData.messageManager
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .alert(
                viewModel.alertMessage,
                isPresented: $viewModel.alertIsPresented
            ) {
                Button(action: {}, label: { Text("확인") })
            }
        }
        .tint(.white)
        .onAppear {
            /// 네비게이션바 타이틀 속성 변경
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
        }
    }
    
    
}

#Preview {
    MapView(
        mapState: .constant(.none),
        locationSearchManager: LocationSearchManager()
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
