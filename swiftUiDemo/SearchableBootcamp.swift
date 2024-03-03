//
//  SearchableBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 03/03/2024.
//

import SwiftUI
import Combine

struct Restaurant : Identifiable , Hashable {
    let id : String
    let title : String
    let cuisine : CuisineOption
}

enum CuisineOption : String {
    case american , itaian , japanese
}

final class SearchableDataManager {
    
    func getAllRestaurant() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .itaian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american)
        ]
    }
}


@MainActor
final class SearchableBootcampViewModel : ObservableObject {
    @Published private(set) var allRestaurant : [Restaurant] = []
    @Published private(set) var filterdRestaurant : [Restaurant] = []
    @Published var searchText : String = ""
    private var cancellables = Set<AnyCancellable>()
    let manager = SearchableDataManager()
    
    var isSearching : Bool {
        !searchText.isEmpty
    }
    
    init() {
        addSubscribre()
    }
    
    private func addSubscribre(){
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterdRestraunt(searchText: searchText)
                
            }
            .store(in: &cancellables)
    }
    
    func filterdRestraunt(searchText : String){
        guard !searchText.isEmpty else{
            filterdRestaurant = []
            return
        }
        let search = searchText.lowercased()
        filterdRestaurant = allRestaurant.filter({ restraunt in
            let titleContainSearch = restraunt.title.lowercased().contains(search)
            let cuisineContainDSearch = restraunt.cuisine.rawValue.lowercased().contains(search)
            return titleContainSearch || cuisineContainDSearch
        })
       
    }
    
    func loadRestaurant() async {
        do {
            allRestaurant = try await manager.getAllRestaurant()
        } catch  {
            print(error)
        }
    }
    
    
}

struct SearchableBootcamp: View {
    @StateObject private var viewModel = SearchableBootcampViewModel()
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                ForEach(viewModel.isSearching ? viewModel.filterdRestaurant : viewModel.allRestaurant , id: \.self) { restraunt in
                    restrauntRow(restraunt: restraunt)
                }
            }
            .padding()
        }
        .navigationTitle("Restraunts")
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restraunt...")
        .task {
            await viewModel.loadRestaurant()
        }
    }

    
    private func restrauntRow(restraunt : Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10){
         
            Text(restraunt.title)
                .font(.headline)
            Text(restraunt.cuisine.rawValue)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity ,alignment: .leading )
        .background(Color.black.opacity(0.05))
    }
}

#Preview {
    NavigationStack{
        SearchableBootcamp()
    }
}
