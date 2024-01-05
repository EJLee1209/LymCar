//
//  FavoriteLocationSearchView.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import SwiftUI

struct FavoriteLocationSearchView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: EditFavoriteMapView.ViewModel
    @State private var viewHeight: CGFloat = 240
    @FocusState private var textFieldIsFocused: Bool
    
    private let minHeight: CGFloat = 240
    private let maxHeight: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(alignment: .center) {
            
            Capsule()
                .fill(Color.theme.secondaryBackgroundColor)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            if !viewModel.annotations.isEmpty {
                HStack(spacing: 9) {
                    Text(viewModel.selectedLocationTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.theme.secondaryTextColor)
                        .frame(width: 24, height: 24)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.top, 20)
            }
            
            HStack {
                TextField(text: $viewModel.searchText) {
                    Text("장소를 검색해주세요")
                }
                .focused($textFieldIsFocused)
                .submitLabel(.search)
                .onTapGesture {
                    withAnimation {
                        viewHeight = maxHeight
                    }
                }
                
                Image("search")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(Color.theme.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal, 22)
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.searchResults, id: \.self) { location in
                        Button(action: {
                            viewModel.didSelectLocation(location)
                            textFieldIsFocused = false
                            withAnimation {
                                viewHeight = minHeight
                            }
                        }, label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.theme.primaryTextColor)
                                Text(location.subtitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.theme.secondaryTextColor)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            
                            Divider()
                        })
                    }
                }
            }
            
            
            RoundedActionButton(
                label: "확인",
                action: {
                    addFavorite()
                    textFieldIsFocused = false
                },
                backgroundColor: buttonBackgroundColor(),
                labelColor: buttonLabelColor()
            )
            .padding(.top, 10)
            .padding(.bottom, 40)
            .padding(.horizontal, 22)
            .disabled(viewModel.annotations.isEmpty)
        }
        .background(Color.theme.backgroundColor)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(radius: 3)
        .frame(maxHeight: viewHeight)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    viewHeight -= gesture.translation.height
                }
                .onEnded { gesture in
                    withAnimation {
                        if viewHeight > UIScreen.main.bounds.height / 2 {
                            viewHeight = maxHeight
                        } else {
                            viewHeight = minHeight
                        }
                    }
                    
                }
        )
    }
    
    func buttonBackgroundColor() -> Color {
        return viewModel.annotations.isEmpty ? Color.theme.secondaryBackgroundColor : Color.theme.brandColor
    }
    
    func buttonLabelColor() -> Color {
        return viewModel.annotations.isEmpty ? Color.theme.secondaryTextColor : .white
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
            
            withAnimation {
                viewModel.showPopUp = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    viewModel.showPopUp = false
                })
            }
            
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    func addFavorite() {
        guard let coordinate = viewModel.selectedLocationCoordinate else { return }
        
        let newFavorite = Favorite(context: managedObjectContext)
        
        newFavorite.title = viewModel.selectedLocationTitle
        newFavorite.subtitle = viewModel.selectedLocationSubTitle
        newFavorite.latitude = coordinate.latitude
        newFavorite.longitude = coordinate.longitude
        
        saveContext()
    }
}

#Preview {
    FavoriteLocationSearchView(viewModel: .init(locationSearchManager: LocationSearchManager()))
}
