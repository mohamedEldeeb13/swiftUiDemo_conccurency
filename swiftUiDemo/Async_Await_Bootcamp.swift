//
//  Async_Await_Bootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 29/02/2024.
//

import SwiftUI

//MARK: How to use async / await keywords in Swift | Swift Concurrency #3

//MARK: viewModel
class Async_Await_ViewModel : ObservableObject {
    @Published var dataArray : [String] = []
    
    
    func getTitle1(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.dataArray.append("title1: \(Thread.current)")
        }
    }
    
    func getTitle2(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 2){
            let title2 = "title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title2)
                let title3 = "title3: \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
  
    
    func addAuthor1() async {
        let author1 = "author1:\(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author1)
        }
        
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let author2 = "author2:\(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author2)
            let author3 = "author3:\(Thread.current)"
            self.dataArray.append(author3)
        }
        
    }
    
    func addSomeThing() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "something1:\(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something1)
            let something2 = "something2:\(Thread.current)"
            self.dataArray.append(something2)
        }
    }
}



//MARK: viewController
struct Async_Await_Bootcamp: View {
    @StateObject private var viewModel = Async_Await_ViewModel()
    var body: some View {
        List{
            ForEach(viewModel.dataArray,id: \.self) { data in
                Text(data)
            }
        }
        .onAppear{
            Task
            {
                await viewModel.addAuthor1()
                await viewModel.addSomeThing()
                let final = "Final text: \(Thread.current)"
                viewModel.dataArray.append(final)
            }
//            viewModel.getTitle1()
//            viewModel.getTitle2()
        
        }
    }
}

#Preview {
    Async_Await_Bootcamp()
}
