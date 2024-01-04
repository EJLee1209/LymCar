//
//  EditFavoriteView.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import SwiftUI

struct EditFavoriteView: View {
    @Binding var tabViewIsHidden: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach((1...10), id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 7) {
                                Text("춘천역")
                                    .font(.system(size: 16, weight: .bold))
                                Text("강원도 춘천시 공지로 591")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.theme.secondaryTextColor)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 18)
                            .padding(.horizontal, 12)
                            
                            Divider()
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                
                NavigationLink {
                    EditFavoriteMapView()
                } label: {
                    Text("추가하기")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                }
                .background(Color.theme.brandColor)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal ,21)
                .padding(.bottom)
            }
            .background(Color.theme.backgroundColor)
            .padding(.top, 10)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("즐겨찾기 편집")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Text("편집")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white)
                        .padding()
                })
            }
        }
        .onAppear {
            tabViewIsHidden = true
        }
    }
}

#Preview {
    EditFavoriteView(tabViewIsHidden: .constant(false))
}
