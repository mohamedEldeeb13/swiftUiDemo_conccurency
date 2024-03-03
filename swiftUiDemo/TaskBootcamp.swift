//
//  TaskBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 29/02/2024.
//

import SwiftUI

//MARK: How to use Task and .task in Swift | Swift Concurrency #4


//MARK: viewModel
class TaskViewModel : ObservableObject {
    @Published var image : UIImage? = nil
    @Published var image2 : UIImage? = nil
    
    func fetchImage() async {
        do{
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url,delegate: nil)
            await MainActor.run {
                self.image = UIImage(data: data)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    func fetchImage2() async {
        do{
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url,delegate: nil)
            await MainActor.run {
                self.image2 = UIImage(data: data)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
}


//MARK: viewController
struct TaskBootcamp: View {
    @StateObject private var viewModel = TaskViewModel()
    
    
    var body: some View {
        VStack(spacing: 40){
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }// vstack
        .onAppear(perform: {
            Task{
                await viewModel.fetchImage()
                await viewModel.fetchImage2()
            }
            /*
            Task{
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage()
                
            }
            Task{
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage2()
            }
             */      //MARK: comment 1
        })
    }
}

#Preview {
    TaskBootcamp()
}


//MARK: Notes :-

//MARK: in function [fetchImage() , fetchImage2()] if call two function in only on Task the function fetch sequentail , mean first image will show and second image will show after first image show
// i want to make two image show in the same time

//MARK: to solve it we can call each of function in only Task like  ----> comment 1
// but this soluthin is bad becuase write to Task in the same area



//MARK: order of Task priority
/*
 Task(priority: .high) {
 print("high:\(Thread.current):\(Task.currentPriority)")
 }
 Task(priority: .userInitiated) {
 print("userInitiated:\(Thread.current):\(Task.currentPriority)")
 }
 Task(priority: .low) {
 print("low:\(Thread.current):\(Task.currentPriority)")
 }
 Task(priority: .utility) {
 print("utility:\(Thread.current):\(Task.currentPriority)")
 }
 Task(priority: .background) {
 print("background:\(Thread.current):\(Task.currentPriority)")
 }
 */
