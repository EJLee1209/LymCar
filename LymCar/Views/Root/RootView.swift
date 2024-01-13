//
//  RootView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI
import Combine

struct RootView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @EnvironmentObject private var appData: AppData
    @State private var mapState: MapState = .none
    @State private var tabViewIsHidden: Bool = false
    @State private var selectedTab: TabMenuItem = .map
    @State private var loginViewIsPresented = false
    @State private var showSplashView = true
    
    var body: some View {
        ZStack {
            if showSplashView {
                SplashView()
            } else {
                ZStack(alignment: .bottom) {
                    /// Tab item views - 탭바의 뷰들
                    ZStack(alignment: .top) {
                        switch selectedTab {
                        case .history:
                            HistoryView()
                        case .map:
                            MapView(
                                mapState: $mapState,
                                tabViewIsHidden: $tabViewIsHidden,
                                locationSearchManager: appData.locationSearchManager
                            )
                        case .menu:
                            MenuView(
                                loginViewIsPresented: $loginViewIsPresented,
                                tabViewIsHidden: $tabViewIsHidden
                            )
                        }
                    }
                    /// Tab bar view - 탭바
                    if mapState == .none && !tabViewIsHidden {
                        MainTabView(selectedItem: $selectedTab)
                            .transition(.move(edge: .bottom))
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
        }
        .task {
            if let _ = await appData.checkUserAndFetchUserCarPool() {}
            else { loginViewIsPresented = true }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showSplashView.toggle()
                }
            }
        }
        .alert(
            role: appData.alertRole,
            alertMessage: appData.alertMessage,
            isPresented: $appData.alertIsPresented
        )
        .loadingProgress(viewState: appData.viewState)
        .onReceive(appDelegate.$fcmToken.combineLatest(appData.$currentUser), perform: { (fcmToken, user) in
            /// fcmToken 퍼블리셔와 currentUser 퍼블리셔를 combineLatest로 묶어서 하나의 퍼블리셔로 만듬
            /// 이렇게하면, 로그아웃 또는 로그인을 해서 유저 정보가 변경되었을 때에도 토큰 값을 Firestore에 업데이트 할 수 있음
            guard let token = fcmToken else { return }
            appData.updateFcmToken(token)
        })
        
    }
}

#Preview {
    RootView()
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
