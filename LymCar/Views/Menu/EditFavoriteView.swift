//
//  EditFavoriteView.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import SwiftUI

struct EditFavoriteView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject private var appData: AppData
    @Binding var tabViewIsHidden: Bool
    
    @FetchRequest(
        entity: Favorite.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Favorite.title, ascending: true)
        ]
    ) var favorites: FetchedResults<Favorite>
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.brandColor
                .ignoresSafeArea()
            
            VStack {
                List {
                    ForEach(favorites) { favorite in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(favorite.title)
                                .font(.system(size: 16, weight: .bold))
                            Text(favorite.subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.theme.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 12)
                    }
                    .onDelete { deleteOffsets in
                        deleteFavorite(at: deleteOffsets)
                    }
                    
                    
                    .listRowBackground(Color.theme.backgroundColor)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                
                
                NavigationLink {
                    EditFavoriteMapView(
                        locationSearchManager: appData.locationSearchManager
                    )
                } label: {
                    Text("추가하기")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                }
                .background(Color.theme.brandColor)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .padding(.horizontal ,21)
                .padding(.bottom)
            }
            .background(Color.theme.backgroundColor)
            .padding(.top, 10)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("즐겨찾기 편집")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .onAppear {
            tabViewIsHidden = true
        }
    }
    
    func deleteFavorite(at offsets: IndexSet) {
        offsets.forEach { index in
            let favorite = self.favorites[index]
            self.managedObjectContext.delete(favorite)
        }
        saveContext()
    }
    
    func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
}

#Preview {
    EditFavoriteView(tabViewIsHidden: .constant(false))
        .environmentObject(AppData(authManager: AuthManager(), carPoolManager: CarPoolManager(), locationSearchManager: LocationSearchManager(), messageManager: MessageManager()))
}
