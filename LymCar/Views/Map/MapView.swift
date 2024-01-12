//
//  ContentView.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject private var appData: AppData
    @StateObject private var viewModel: ViewModel
    @Binding var mapState: MapState
    @Binding var tabViewIsHidden: Bool
    
    @FetchRequest(
        entity: Favorite.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Favorite.title, ascending: true)
        ]
    ) var favorites: FetchedResults<Favorite>
    
    init(
        mapState: Binding<MapState>,
        tabViewIsHidden: Binding<Bool>,
        locationSearchManager: LocationSearchManagerType
    ) {
        self._mapState = mapState
        self._tabViewIsHidden = tabViewIsHidden
        self._viewModel = .init(wrappedValue: ViewModel(locationSearchManager: locationSearchManager))
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
                        
                        VStack(spacing: 0) {
                            LocationSearchActivationView()
                                .padding(.top, 20)
                                .onTapGesture {
                                    withAnimation(.spring) {
                                        mapState = .searchingForLocation
                                    }
                                }
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(alignment: .center, spacing: 5) {
                                    ForEach(favorites) { favorite in
                                        Button(action: {
                                            viewModel.didSelectFavorite(with: favorite)
                                            appData.didSelectFavorite(with: favorite)
                                            mapState = viewModel.departurePlaceCoordinate == nil ? .searchingForLocation : .locationSelected
                                        }, label: {
                                            FavoriteButton(label: favorite.title)
                                        })
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                            .frame(height: 60)
                            
                            
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
                        CarPoolShortcutListView(tabViewIsHidden: $tabViewIsHidden)
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
                            tabViewIsHidden: $tabViewIsHidden,
                            carPoolManager: appData.carPoolManager,
                            messageManager: appData.messageManager
                        )
                        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        tabViewIsHidden: .constant(true),
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
