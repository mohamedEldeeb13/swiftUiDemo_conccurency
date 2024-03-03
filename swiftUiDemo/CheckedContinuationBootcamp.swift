//
//  CheckedContinuationBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 02/03/2024.
//

import SwiftUI
//MARK: How to use Continuations in Swift (withCheckedThrowingContinuation) | Swift Concurrency #7


//MARK: network Manager
class CheckedContinuationBootcampNetworkManager {
    func getData(url : URL) async throws -> Data {
        do {
           let (data,_) = try await URLSession.shared.data(from: url , delegate: nil)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url : URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                }else if let error = error {
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
}


//MARK: viewModel
class CheckedContinuationBootcampViewModel : ObservableObject {
    @Published var image : UIImage? = nil
    let manager = CheckedContinuationBootcampNetworkManager()
    
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return  }
        do {
//          let data = try await manager.getData(url: url)
            let data = try await manager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch{
            print(error)
        }
    }
}



//MARK: viewController
struct CheckedContinuationBootcamp: View {
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    var body: some View {
        ZStack
        {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200,height: 200)
            }
            
        }// ZStack
        .task {
            await viewModel.getImage()
        }
    }
}

#Preview {
    CheckedContinuationBootcamp()
}
