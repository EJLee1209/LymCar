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
    @StateObject private var viewModel: ViewModel
    
    init(locationSearchManager: LocationSearchManagerType) {
        self._viewModel = .init(wrappedValue: .init(locationSearchManager: locationSearchManager))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                Map(
                    coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.annotations
                ) { anno in
                    MapMarker(coordinate: anno.coordinate)
                }
                .padding(.top, 10)
                
                if viewModel.showPopUp {
                    Text("즐겨찾기 추가 완료")
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .background(Color.theme.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(lineWidth: 2)
                                .fill(Color.theme.brandColor)
                        }
                        .padding(.top, 20)
                }
            }
            
            
            FavoriteLocationSearchView(viewModel: viewModel)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("즐겨찾기")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .alert(
            viewModel.alertMessage,
            isPresented: $viewModel.alertIsPresented
        ) {
            Button(action: {}, label: {
                Text("확인")
            })
        }
        .onAppear {
            viewModel.setUserLocation()
        }
    }
}

#Preview {
    EditFavoriteMapView(locationSearchManager: LocationSearchManager())
}
