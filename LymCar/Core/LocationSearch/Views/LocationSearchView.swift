//
//  LocationSearchView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct LocationSearchView: View {
    @EnvironmentObject var viewModel: LocationSearchViewModel
    @Binding var mapState: MapState
    
    var body: some View {
        VStack {
            /// action button
            MapViewActionButton(mapState: $mapState)
                .padding(.bottom, 12)
                .padding(.leading, 16)
            
            /// header view
            HStack(spacing: 12) {
                VStack(spacing: 9) {
                    TextField(text: $viewModel.startLocationText) {
                        Text("현재 위치 또는 위치 검색")
                            .font(.system(size: 15))
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 14)
                    .background(Color.theme.secondaryBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    TextField(text: $viewModel.destinationText) {
                        Text("어디로 갈까요?")
                            .font(.system(size: 15))
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 14)
                    .background(Color.theme.secondaryBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.leading, 9)
                .padding(.vertical, 9)
                
                Image("search")
            }
            .padding(.horizontal, 16)
            
            Divider()
            
            /// location list view
            List {
                ForEach(viewModel.searchResults, id: \.self) { searchCompletion in
                    Button(action: {
                        viewModel.didSelectLocation(searchCompletion) {
                            withAnimation(.spring) {
                                if viewModel.destinationCoordinate != nil &&
                                    viewModel.startingPointCoordinate != nil {
                                    mapState = .locationSelected
                                }
                            }
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
        .environmentObject(LocationSearchViewModel())
}
