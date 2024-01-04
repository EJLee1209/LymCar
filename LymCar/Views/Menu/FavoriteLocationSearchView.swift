//
//  FavoriteLocationSearchView.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import SwiftUI

struct FavoriteLocationSearchView: View {
    @ObservedObject var viewModel: EditFavoriteMapView.ViewModel
    
    @State private var viewHeight: CGFloat = 240
    private let minHeight: CGFloat = 240
    
    var body: some View {
        VStack(alignment: .center) {
            
            Capsule()
                .fill(Color.theme.secondaryBackgroundColor)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            HStack(spacing: 9) {
                Text("춘천역")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.theme.primaryTextColor)
                
                Image(systemName: "pencil")
                    .foregroundStyle(Color.theme.secondaryTextColor)
                    .frame(width: 24, height: 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 20)
            
            HStack {
                TextField(text: $viewModel.searchText) {
                    Text("장소를 검색해주세요")
                }
                .submitLabel(.search)
                
                Image("search")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(Color.theme.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal, 22)
            
            ScrollView {
                LazyVStack {
                    ForEach((1...10), id: \.self) { i in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("춘천역")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.theme.primaryTextColor)
                            Text("강원도 춘천시 공지로 591")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.theme.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        Divider()
                    }
                }
            }
            
            RoundedActionButton(label: "확인", action: {  })
                .padding(.vertical, 29)
                .padding(.horizontal, 22)
        }
        .background(Color.theme.backgroundColor)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(radius: 3)
        .frame(maxHeight: viewHeight)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    viewHeight -= gesture.translation.height
                }
                .onEnded { gesture in
                    withAnimation {
                        if viewHeight > UIScreen.main.bounds.height / 2 {
                            viewHeight = UIScreen.main.bounds.height
                        } else {
                            viewHeight = minHeight
                        }
                    }
                    
                }
        )
    }
}

#Preview {
    FavoriteLocationSearchView(viewModel: .init())
}
