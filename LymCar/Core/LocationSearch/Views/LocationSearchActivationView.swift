//
//  LocationSearchActivationView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct LocationSearchActivationView: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            Text("어디로 갈까요?")
                .font(.system(size: 16))
                .foregroundStyle(.gray)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
            
            Image("search")
                .padding(.vertical, 13)
                .padding(.trailing, 16)
        }
        .background(Color.theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .shadow(radius: 3)
    }
}

#Preview {
    LocationSearchActivationView()
}
