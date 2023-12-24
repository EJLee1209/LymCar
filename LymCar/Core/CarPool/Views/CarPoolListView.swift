//
//  CarPoolListView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct CarPoolListView: View {
    @Binding var mapState: MapState
    
    let rows: [GridItem] = [
        GridItem(.flexible(minimum: 225, maximum: 300))
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                print("DEBUG: 새로고침")
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .padding(13)
            })
            .background(Color.theme.backgroundColor)
            .clipShape(Circle())
            .shadow(radius: 1)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 11)
            
            VStack(spacing: 0) {
                HStack {
                    Text("카풀 목록")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button(action: {
                        withAnimation {
                            mapState = .generateCarPool
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray)
                    })
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 9, content: {
                        ForEach((1...10), id: \.self) { _ in
                            CarPoolCell()
                        }
                    })
                    .padding(.horizontal, 21)
                    .padding(.bottom, 50)
                }
            }
            .background(Color.theme.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 2)
            
        }
    }
}

#Preview {
    CarPoolListView(
        mapState: .constant(.none)
    )
}
