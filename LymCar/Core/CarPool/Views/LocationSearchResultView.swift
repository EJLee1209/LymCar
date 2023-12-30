//
//  LocationSearchResultView.swift
//  LymCar
//
//  Created by 이은재 on 12/29/23.
//

import SwiftUI

struct LocationSearchResultView: View {
    @ObservedObject var viewModel: CarPoolGenerateView.ViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Text("위치 검색 결과")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.theme.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.leading, 22)
            
            /// location list view
            List {
                ForEach(viewModel.localSearchResult, id: \.self) { local in
                    Button(action: {
                        viewModel.didSelectLocal(with: local)
                        dismiss()
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(local.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.theme.primaryTextColor)
                            Text(local.subtitle)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.theme.secondaryTextColor)
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 15)
                    })
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background(Color.theme.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 12)
            .padding(.bottom, 80)
        }
        .background(Color.theme.backgroundColor)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(radius: 3)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    LocationSearchResultView(viewModel: .init(
        currentUser: .mock,
        departurePlaceText: "",
        destinationText: "",
        departurePlaceCoordinate: nil,
        destinationCoordinate: nil,
        carPoolManager: CarPoolManager(),
        locationSearchManager: LocationSearchManager())
    )
}
