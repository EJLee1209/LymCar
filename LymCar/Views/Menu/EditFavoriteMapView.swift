//
//  EditFavoriteMapView.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import SwiftUI
import MapKit
import Combine


struct EditFavoriteMapView: View {
    @StateObject private var viewModel: ViewModel = .init()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .padding(.top, 10)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            
            FavoriteLocationSearchView(viewModel: viewModel)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("즐겨찾기")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            viewModel.setUserLocation()
        }
    }
}

#Preview {
    EditFavoriteMapView()
}
