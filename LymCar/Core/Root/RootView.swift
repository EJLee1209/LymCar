//
//  RootView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appData: AppData
    @State private var mapState: MapState = .none
    @State private var selectedTab: TabMenuItem = .map
    @State private var loginViewIsPresented = false
    @State private var showSplashView = true
    
    var body: some View {
        ZStack {
            if showSplashView {
                SplashView()
            } else {
                NavigationView {
                    ZStack(alignment: .bottom) {
                        /// Tab item views - 탭바의 뷰들
                        ZStack(alignment: .top) {
                            switch selectedTab {
                            case .history:
                                HistoryView()
                            case .map:
                                MapView(
                                    mapState: $mapState,
                                    locationSearchManager: appData.locationSearchManager
                                )
                            case .menu:
                                MenuView(loginViewIsPresented: $loginViewIsPresented)
                            }
                        }
                        /// Tab bar view - 탭바
                        if mapState != .searchingForLocation {
                            MainTabView(selectedItem: $selectedTab)
                                .transition(.move(edge: .bottom))
                        }
                        
                        /// bottom sheet - 카풀 목록
                        if mapState == .locationSelected {
                            if let user = appData.currentUser {
                                CarPoolListView(
                                    user: user,
                                    carPoolManager: appData.carPoolManager
                                )
                                .transition(.move(edge: .bottom))
                            }
                        }
                        
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    .fullScreenCover(isPresented: $loginViewIsPresented, content: {
                        /// didLogin == false -> 로그인 화면을 보여줌
                        /// LoginView에서는 @Binding 프로퍼티를 통해 로그인 성공시 didLogin을 toggle -> 로그인 화면 dismiss
                        LoginView(
                            isPresented: $loginViewIsPresented,
                            authManager: appData.authManager
                        )
                    })
                }
                .tint(.white)
                
                
            }
        }
        .task {
            if let _ = await appData.checkUserAndFetchUserCarPool() { }
            else { loginViewIsPresented.toggle() }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showSplashView.toggle()
                }
            }
        }
        .onAppear {
            /// 네비게이션바 타이틀 속성 변경
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
        }
        .alert(
            appData.alertMessage,
            isPresented: $appData.alertIsPresented
        ) {
            switch appData.alertRole {
            case .withAction(let action):
                Button(role: .destructive, action: {
                    action()
                }, label: {
                    Text("확인")
                })
                
                Button(role: .cancel, action: {}, label: {
                    Text("취소")
                })
            case .cancel:
                Button(action: {}, label: {
                    Text("확인")
                })
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(
            AppData(
                authManager: AuthManager(),
                carPoolManager: CarPoolManager(),
                locationSearchManager: LocationSearchManager()
            )
        )
}
