//
//  CountView.swift
//  LymCar
//
//  Created by 이은재 on 12/24/23.
//

import SwiftUI

struct CountView: View {
    let title: String
    @Binding var count: Int
    
    private let maxNumber: Int = 4
    private let minNumber: Int = 2
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.theme.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 48) {
                Button(action: {
                    if count > minNumber { count -= 1 }
                }, label: {
                    Image("minus-circle")
                })
                
                VStack(spacing: 0) {
                    Text("\(count)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.theme.primaryTextColor)
                    Capsule()
                        .fill(Color.theme.brandColor)
                        .frame(width: 40, height: 5)
                }
                
                Button(action: {
                    if count < maxNumber { count += 1 }
                }, label: {
                    Image("plus-circle")
                })
            }
            
            
        }
    }
}

#Preview {
    CountView(
        title: "최대 인원수",
        count: .constant(4)
    )
}
