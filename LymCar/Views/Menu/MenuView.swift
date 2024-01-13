//
//  MenuView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appData: AppData
    @Binding var loginViewIsPresented: Bool
    @Binding var tabViewIsHidden: Bool
    @State private var privacyPolicyIsPresented: Bool = false
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.theme.brandColor
                    .ignoresSafeArea()
                
                if let currentUser = appData.currentUser {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            
                            Text("안녕하세요\n\(currentUser.name)님")
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.leading)
                                .padding(.top, 46)
                                .padding(.horizontal, 21)
                            
                            HStack(spacing: 4) {
                                Text(currentUser.gender)
                                
                                Rectangle()
                                    .frame(width: 2)
                                
                                Text(verbatim: currentUser.email)
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.theme.secondaryTextColor)
                            .padding(.top, 6)
                            .padding(.horizontal, 21)
                            
                            Divider()
                                .padding(.top, 32)
                            
                            ForEach(MenuType.allCases, id: \.self) { menu in
                                menuCell(menu)
                            }
                        }
                    }
                    .background(Color.theme.backgroundColor)
                    .padding(.top, 10)
                } else {
                    CharacterSayView(text: "로그인이 필요합니다")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.theme.backgroundColor)
                        .padding(.top, 10)
                }
            }
            .sheet(isPresented: $privacyPolicyIsPresented, content: {
                WebView(url: Constant.privacyPolicyURL)
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("메뉴")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .onAppear {
                tabViewIsHidden = false
            }
            .onReceive(appData.$viewState, perform: { state in
                switch state {
                case ViewState.successToNetworkRequest:
                    loginViewIsPresented = true
                default:
                    break
                }
            })
        }
        .tint(.white)
    }
    
    @ViewBuilder
    private func menuCell(_ menu: MenuType) -> some View {
        switch menu {
        case .editFavorite:
            NavigationLink {
                EditFavoriteView(tabViewIsHidden: $tabViewIsHidden)
            } label: {
                MenuCell(
                    title: menu.rawValue,
                    rightContentType: .rightArrow
                )
            }
        default:
            Button {
                menuButtonAction(menu)
            } label: {
                MenuCell(
                    title: menu.rawValue,
                    rightContentType: menu.rightContentType,
                    labelColor: menu == .logout || menu == .deleteUser ? Color.theme.red : Color.theme.secondaryTextColor
                )
            }
        }
        Divider()
    }
    
    private func menuButtonAction(_ menu: MenuType) {
        switch menu {
        case .logout:
            appData.alert(
                message: "정말로 로그아웃 하시겠습니까?",
                role: .both(positiveAction: {
                    appData.logout()
                    loginViewIsPresented.toggle()
                }, negativeAction: { })
            )
        case .deleteUser:
            appData.alert(
                message: "회원 탈퇴를 원하시면 패스워드를 입력해주세요",
                role: .withTextField(
                    text: $password,
                    positiveAction: {
                        appData.deleteUser(withPassword: password)
                    },
                    negativeAction: { print("DEBUG: 회원탈퇴 취소") }
                )
            )
        case .privacyPolicy:
            privacyPolicyIsPresented = true
        default:
            break
        }
    }
}

#Preview {
    MenuView(
        loginViewIsPresented: .constant(true), tabViewIsHidden: .constant(true)
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
