//
//  CarPoolGenerateView.swift
//  LymCar
//
//  Created by 이은재 on 12/24/23.
//

import SwiftUI

struct CarPoolGenerateView: View {
    @Binding var mapState: MapState
    
    @State private var startLocationText = ""
    @State private var destinationText = ""
    @State private var personCount = 2
    @State private var departureDate = Date()
    @State private var genderOptionIsActivate = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            Color.theme.backgroundColor
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(.all, edges: .bottom)
                .padding(.top, 60)
            
            VStack(spacing: 0) {
                
                ZStack(alignment: .leading) {
                    Button(action: {
                        withAnimation {
                            mapState = .locationSelected
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .padding(10)
                    })
                    .padding(.leading, 10)
                    
                    Text("방 만들기")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
                
                
                /// 위치 검색 뷰
                LocationSearchInputView(
                    startLocationText: $startLocationText,
                    destinationText: $destinationText,
                    rightContentType: .swap
                )
                .padding(.trailing, 16)
                .background(Color.theme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 12)
                .padding(.top, 13)
                .shadow(radius: 4)
                
                /// 방 옵션 설정 뷰
                VStack(spacing: 25) {
                    CountView(
                        title: "최대 인원수",
                        count: $personCount
                    )
                    
                    
                    TimePickerView(title: "출발시간", date: $departureDate)
                    
                    OptionView(
                        title: "탑승 옵션",
                        isActivate: $genderOptionIsActivate
                    )
                    
                    Spacer()
                    /// 방 만들기 버튼
                    
                    Button(action: {
                        
                    }, label: {
                        Text("방 만들기")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    })
                    .background(Color.theme.brandColor)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .shadow(radius: 4, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 36)
                .padding(.bottom, 47)
                
            }
        }
    }
}

#Preview {
    CarPoolGenerateView(
        mapState: .constant(.none)
    )
}
