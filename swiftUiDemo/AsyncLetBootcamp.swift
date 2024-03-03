//
//  AsyncLetBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 01/03/2024.
//

import SwiftUI

//MARK: How to use Async Let to perform concurrent methods in Swift | Swift Concurrency #5



struct AsyncLetBootcamp: View {
    
    @State private var images : [UIImage] = []
    let url = URL(string: "https://picsum.photos/300")!
    private let colums = [GridItem(.flexible()) , GridItem(.flexible()) ]
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                LazyVGrid(columns: colums) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            
                    }// forEach
                }// lazyGrid
            }// ScrollView
            .navigationTitle("Async Let 🥳")
            .onAppear{
                Task {
                    //MARK: comment 1
                    /*
                    do{
                        let image = try await fetchImage()
                        self.images.append(image)
                        
                        let image2 = try await fetchImage()
                        self.images.append(image2)
                        
                        let image3 = try await fetchImage()
                        self.images.append(image3)
                        
                        let image4 = try await fetchImage()
                        self.images.append(image4)
                    }catch{
                    }
                     */
                    
                    do{
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image , image2 , image3 , image4) = await (try fetchImage1 , try fetchImage2 , try fetchImage3 , try fetchImage4)
                        self.images.append(contentsOf: [image,image2,image3,image4])
                    }catch{
                    }
                }
            }
            
        }//NavigationView
    }
    
    func fetchImage() async throws -> UIImage {
        do {
            let (data , _) = try await URLSession.shared.data(from: url , delegate: nil)
            if let image = UIImage(data: data) {
                return image
            }else {
                throw URLError(.badURL)
            }
        }catch{
            throw error
        }
    }
}

#Preview {
    AsyncLetBootcamp()
}


//MARK: notes

//MARK: if call function like [ comment 1 ] images will reload sequentailly that mean first image will show then second image then thired image then fourth image

// i want to show all images at same time that is named as multiple brunch of tasks

// way 1
//use only one fetch function in one task like previous page --> but is bad code

// way 2
// use async let and can use async let in one Task


// can use more than function diffrent in result in async let , mean can fetch image in function and can fetch title in function ---> can call two function in async let

/*
 do{
 async let fetchImage1 = fetchImage()
 async let fetchTitle = fetchTitle()
 
 let (image , title) = await (try fetchImage1 , fetchTitle)
 }catch{
 
 }
 */
