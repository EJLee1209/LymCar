//
//  LocationSearchView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct LocationSearchView: View {
    @EnvironmentObject var viewModel: MapView.ViewModel
    @EnvironmentObject var AppData: AppData
    @Binding var mapState: MapState
    
    var body: some View {
        VStack {
            /// action button
            MapViewActionButton(mapState: $mapState)
                .padding(.bottom, 12)
                .padding(.leading, 16)
            
            /// header view
            LocationSearchInputView(
                departurePlaceText: $viewModel.departurePlaceText,
                destinationText: $viewModel.destinationText,
                rightContentType: .search,
                rightContentTapEvent: nil,
                departureTextFieldOnSubmit: nil,
                destinationTextFieldOnSubmit: nil
            )
            .padding(.horizontal, 16)
            
            Divider()
            
            /// location list view
            List {
                ForEach(viewModel.searchResults, id: \.self) { searchCompletion in
                    Button(action: {
                        viewModel.didSelectLocation(searchCompletion) {
                            withAnimation(.spring) {
                                if viewModel.destinationCoordinate != nil &&
                                    viewModel.departurePlaceCoordinate != nil {
                                    mapState = .locationSelected
                                }
                            }
                            
                            AppData.didSelectLocation(
                                departurePlaceName: viewModel.departurePlaceText,
                                destinationName: viewModel.destinationText,
                                departureLocationCoordinate: viewModel.departurePlaceCoordinate,
                                destinationCoordinate: viewModel.destinationCoordinate
                            )
                        }
                        
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(searchCompletion.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.theme.primaryTextColor)
                            Text(searchCompletion.subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.theme.secondaryTextColor)
                            
                            Divider()
                        }
                    })
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                .background(Color.theme.backgroundColor)
            }
            .listStyle(.plain)
        }
        .background(Color.theme.backgroundColor)
    }
}

#Preview {
    LocationSearchView(mapState: .constant(MapState.searchingForLocation))
        .environmentObject(MapView.ViewModel(locationSearchManager: LocationSearchManager()))
        .environmentObject(
            AppData(
                authManager: AuthManager(),
                carPoolManager: CarPoolManager(),
                locationSearchManager: LocationSearchManager()
            )
        )
}
