//
//  HistoryView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.brandColor
                    .ignoresSafeArea()
                
                CharacterSayView(text: "개발 중인 기능입니다!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.theme.backgroundColor)
                    .padding(.top, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("히스토리")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
    }
}

#Preview {
    HistoryView()
}
