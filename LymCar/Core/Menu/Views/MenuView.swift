//
//  MenuView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI



struct MenuView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("메뉴")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 10)
                
                if let currentUser = rootViewModel.currentUser {
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
                                MenuCell(
                                    imageName: menu.imageName,
                                    title: menu.rawValue,
                                    rightContentType: .rightArrow
                                )
                            }
                            
                            Divider()
                                .frame(height: 10)
                                .background(Color.theme.secondaryBackgroundColor)
                            
                            ForEach(SecondMenuType.allCases, id: \.self) { menu in
                                MenuCell(
                                    imageName: nil,
                                    title: menu.rawValue,
                                    rightContentType: .label(text: menu.labelText)
                                )
                            }
                            
                            Divider()
                                .frame(height: 10)
                                .background(Color.theme.secondaryBackgroundColor)
                            
                            ForEach(ThirdMenuType.allCases, id: \.self) { menu in
                                MenuCell(
                                    imageName: nil,
                                    title: menu.rawValue,
                                    rightContentType: .rightArrow
                                )
                            }
                        }
                    }
                    .background(Color.theme.backgroundColor)
                    .padding(.top, 26)
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
                    .padding(.top, 26)
                }
            }
        }
        
    }
}

#Preview {
    MenuView()
        .environmentObject(RootViewModel())
}
