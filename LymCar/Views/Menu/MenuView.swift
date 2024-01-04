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
    @State private var alertIsPresented = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.theme.brandColor
                    .ignoresSafeArea()
                
                if let currentUser = appData.currentUser {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
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
                            
                            ForEach(FirstMenuType.allCases, id: \.self) { menu in
                                NavigationLink {
                                    switch menu {
                                    case .editFavorite:
                                        EditFavoriteView(tabViewIsHidden: $tabViewIsHidden)
                                    }
                                } label: {
                                    MenuCell(
                                        imageName: menu.imageName,
                                        title: menu.rawValue,
                                        rightContentType: .rightArrow
                                    )
                                }
                            }
                            
                            Divider()
                                .frame(height: 10)
                                .background(Color.theme.secondaryBackgroundColor)
                            
                            ForEach(SecondMenuType.allCases, id: \.self) { menu in
                                Button(action: {
                                    switch menu {
                                    case .updateInformation:
                                        break
                                    case .privacyPolicy:
                                        break
                                    }
                                }, label: {
                                    MenuCell(
                                        imageName: nil,
                                        title: menu.rawValue,
                                        rightContentType: .label(text: menu.labelText)
                                    )
                                })
                            }
                            
                            Divider()
                                .frame(height: 10)
                                .background(Color.theme.secondaryBackgroundColor)
                            
                            ForEach(ThirdMenuType.allCases, id: \.self) { menu in
                                Button(action: {
                                    alertIsPresented.toggle()
                                }, label: {
                                    MenuCell(
                                        imageName: nil,
                                        title: menu.rawValue,
                                        rightContentType: .rightArrow
                                    )
                                })
                            }
                        }
                    }
                    .background(Color.theme.backgroundColor)
                    .padding(.top, 10)
                } else {
                    VStack {
                        Image("character")
                            .frame(maxWidth: .infinity)
                        
                        Text("로그인이 필요합니다")
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 46)
                            .padding(.horizontal, 21)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.theme.backgroundColor)
                    .padding(.top, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("메뉴")
                        .font(.system(size: 20, weight: .bold))
                }
            }
            .alert(
                "정말로 로그아웃 하시겠습니까?",
                isPresented: $alertIsPresented
            ) {
                
                Button(role: .destructive, action: {
                    appData.logout()
                    loginViewIsPresented.toggle()
                },label: {
                    Text("확인")
                })
                Button(role: .cancel, action: {}, label: {
                    Text("취소")
                })
            }
            
        }
        .tint(.white)
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
