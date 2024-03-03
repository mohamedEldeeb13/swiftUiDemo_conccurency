//
//  AsyncPublisherBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 03/03/2024.
//

import SwiftUI
import Combine

//MARK: How to use AsyncPublisher to convert @Published to Async / Await | Swift Concurrency #12


//MARK: data manager
class AsyncPublisherDataManager {
    @Published var myData : [String] = []
    func addData() async {
        myData.append("Apple")
       try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
        
    }
}


//MARK: view model
class AsyncPublisherBootcampViewModel : ObservableObject {
    
    @Published var dataArray : [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscriber()
    }
    
    private func addSubscriber() {
        
        Task{
            for await values in manager.$myData.values {
                self.dataArray = values
            }
        }
        
        
        /*
        manager.$myData
            .receive(on: DispatchQueue.main, options: nil)
            .sink { dataArray in
                self.dataArray = dataArray
            }
            .store(in: &cancellable)
         */   //MARK: way 1
    }
    
    func start() async {
        await manager.addData()
    }
    
}


//MARK: view controller
struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
       ScrollView
        {
            VStack
            {
                ForEach(viewModel.dataArray , id: \.self) { dataArray in
                    Text(dataArray)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}


//MARK: to convert published variable to async await we will use .values
