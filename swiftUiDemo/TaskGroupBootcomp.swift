//
//  TaskGroupBootcomp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 02/03/2024.
//

import SwiftUI

//MARK: How to use TaskGroup to perform concurrent Tasks in Swift | Swift Concurrency #6



//MARK: data manager
class TaskGroupBootcompDataManager {
    func fetchImage(urlString : String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        do{
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data){
                return image
            }else{
                throw URLError(.badURL)
            }
        }catch{
            throw error
        }
    }
    
    func fetchImagesWithAsyncLet() async throws ->[UIImage] {
        async let fetchImage1 = try await fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = try await fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = try await fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = try await fetchImage(urlString: "https://picsum.photos/300")
        let (image1,image2,image3,image4) = await(try fetchImage1 , try fetchImage2 , try fetchImage3 , try fetchImage4)
        return [image1 , image2 ,image3 ,image4]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlstring = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images : [UIImage] = []
            images.reserveCapacity(urlstring.count)
            /*
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
             */    //MARK: comment 1
            
            
            for urlString in urlstring {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }
    
}


//MARK: viewModel
class TaskGroupBootcompViewModel : ObservableObject {
    @Published var images : [UIImage] = []
    let manager = TaskGroupBootcompDataManager()
    func getImages() async {
//        if let images = try? await manager.fetchImagesWithAsyncLet() {
//            self.images.append(contentsOf: images)
//        }
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}


//MARK: viewController
struct TaskGroupBootcomp: View {
    @StateObject private var viewModel = TaskGroupBootcompViewModel()
    private let colums = [GridItem(.flexible()) , GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: colums) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        
                    }// forEach
                }// lazyGrid
            }// ScrollView
            .navigationTitle("Task Group 🥳")
        }
        .task {
            await viewModel.getImages()
        }
    }
}

#Preview {
    TaskGroupBootcomp()
}


//MARK: in function -->  fetchImagesWithAsyncLet()   if want to load 20 or 30 or 40 of task code is become hard and not scalable so we want to use Task Group

// if we not want to add task group manwally like //MARK: comment 1   ----> do anaother way like it founded
