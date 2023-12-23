//
//  MapViewActionButton.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct MapViewActionButton: View {
    @Binding var mapState: MapState
    @EnvironmentObject var mapViewModel: MapViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.spring) {
                mapState = .none
            }
            
            mapViewModel.clearAllPropertiesForLocationSearch()
        }, label: {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundStyle(Color.theme.primaryTextColor)
                .padding()
                .background(Color.theme.backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 6)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MapViewActionButton(mapState: .constant(.none))
}
