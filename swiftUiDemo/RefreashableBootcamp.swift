//
//  RefreashableBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 03/03/2024.
//

import SwiftUI

//MARK: How to use Refreshable modifier in SwiftUI | Swift Concurrency #15


//MARK: data manager
final class RefreashableDataManager {
    
    func getData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return ["Apple" , "Orange" , "Watermelon"].shuffled()
    }
    
}

//MARK: view model
@MainActor
final class RefreashableBootcampViewModel : ObservableObject {
    @Published private(set) var items : [String] = []
    let manager = RefreashableDataManager()
    
    func loadData() async {
        Task
        {
            do{
                items = try await manager.getData()
                
            }catch{
                print(error)
            }
        }
        
    }
}


struct RefreashableBootcamp: View {
    @StateObject private var viewModel = RefreashableBootcampViewModel()
    
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    ForEach(viewModel.items , id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                    
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .navigationTitle("Refreashable")
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    RefreashableBootcamp()
}
