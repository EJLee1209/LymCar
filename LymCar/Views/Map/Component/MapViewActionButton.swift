//
//  MapViewActionButton.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct MapViewActionButton: View {
    @EnvironmentObject var appData: AppData
    @ObservedObject var mapViewModel: MapView.ViewModel
    @Binding var mapState: MapState
    
    var body: some View {
        Button(action: {
            withAnimation(.spring) {
                mapState = .none
            }
            
            mapViewModel.clearAllPropertiesForLocationSearch()
            appData.clearLocation()
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
    MapViewActionButton(
        mapViewModel: MapView.ViewModel(locationSearchManager: LocationSearchManager()),
        mapState: .constant(.none)
    )
        .environmentObject(
            AppData(
                authManager: AuthManager(),
                carPoolManager: CarPoolManager(),
                locationSearchManager: LocationSearchManager(),
                messageManager: MessageManager()
            ))
}
