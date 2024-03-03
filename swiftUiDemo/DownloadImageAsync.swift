//
//  DownloadImageAsync.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 28/02/2024.
//

import SwiftUI
import Combine

//MARK: Download images with Async/Await, @escaping, and Combine | Swift Concurrency #2



//MARK: data manager
class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    
    func handleResponse(data : Data? , response : URLResponse?)-> UIImage?{
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else{
            return nil
        }
        return image
    }
    
    //MARK: download with completionHandler
    func downloadingWithEscaping(completionHandler:@escaping(_ image : UIImage? ,_ error : Error?)-> ()){
        
        URLSession.shared.dataTask(with: url) {[weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image , nil )
        }
        .resume()
    }
    
    //MARK: download with combine
    func downloadWithCombine()-> AnyPublisher<UIImage?,Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({$0})
            .eraseToAnyPublisher()
        
    }
    
    //MARK: download with Async_Await
    func downloadingWithAsync() async throws -> UIImage?{
        do{
            let (data , response) = try await URLSession.shared.data(from: url , delegate: nil)
            return handleResponse(data: data, response: response)
        }catch{
            throw error
        }
        
    }
    
    
}



//MARK: viewModel
class DownloadImageAsyncViewModel : ObservableObject {
    @Published var image : UIImage? = nil
    let manager = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    //MARK: fetch with completionHandler
    func fetchWithEscaping(){
         manager.downloadingWithEscaping { [weak self] image, error in
            if let image = image {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
    
    //MARK: fetch with combine
    func fetchWithcombine(){
        manager.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
    }
    
    //MARK: fetch with Async_await
    func fetchWithAsync() async {
        
        let image = try? await manager.downloadingWithAsync()
        await MainActor.run {
            self.image = image
        }
    }

}



//MARK: viewController
struct DownloadImageAsync: View {
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack
        {
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .scaledToFit()
                    
            }
           
        }// end of ZStack
        .onAppear(perform: {
//            viewModel.fetchWithEscaping()
//            viewModel.fetchWithcombine()
            Task{
                await viewModel.fetchWithAsync()
            }
        })
    }
}

#Preview {
    DownloadImageAsync()
}
