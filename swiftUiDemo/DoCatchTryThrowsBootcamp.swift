//
//  DoCatchTryThrowsBootcamp.swift
//  swiftUiDemo_concurrency
//
//  Created by Mohamed Abd Elhakam on 28/02/2024.
//

import SwiftUI


//MARK: How to use Do, Try, Catch, and Throws in Swift | Swift Concurrency #1

// handel error of all cases with do, catch, try, throws


//MARK: dataManager
class DoCatchTryThrowsBootcampDataManager {
    let isactive : Bool = false
    let isactive2 : Bool = true
    
    //defualt way
    func getTitle()->(title:String?,error:Error?){
        if isactive{
            return ("end Title",nil)
        }else{
            return (nil, URLError(.badURL))
        }
    }
    
    // result way
    func getTitle2()-> Result<String,Error>{
        if isactive {
            return .success("end Title")
        }else{
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    // throws way
    func getTitle3() throws -> String {
        if isactive {
            return "end Title"
        }else {
            throw URLError(.badServerResponse)
        }
    }
    
    
    func getTitle4() throws -> String {
       
        throw URLError(.badServerResponse)
    }
    
    func getTitle5() throws -> String {
        if isactive2 {
            return "final Title"
        }else {
            throw URLError(.badServerResponse)
        }
    }


    
    
}

//MARK: viewModel
class DoCatchTryThrowsBootcampViewModel : ObservableObject {
    @Published var text : String = "Starting text ..."
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle(){
        /*
        let returnValue = manager.getTitle()
        if let newTitle = returnValue.title {
            self.text = newTitle
        }else if let error = returnValue.error {
            self.text = error.localizedDescription
        }
         */   //MARK: call of getTitle()
        
        /*
        let returnValue = manager.getTitle2()
        switch returnValue {
        case .success(let success):
            self.text = success
        case .failure(let failure):
            self.text = failure.localizedDescription
        }
         */   //MARK: call of getTitle2()
        
        /*
        do{
            let returnTitle = try manager.getTitle3()
            self.text = returnTitle
        }catch{
            self.text = error.localizedDescription
        }
         */   //MARK: call of getTitle3()
       
        //MARK: call of getTitle4() and getTitle5() --> together
        do{
            let returnTitle = try? manager.getTitle4()
            if let returnTitle = returnTitle {
                self.text = returnTitle
            }
            let returnTitle2 = try manager.getTitle5()
                self.text = returnTitle2
        }catch{
            self.text = error.localizedDescription
        }
        
    }
}

//MARK: viewController
struct DoCatchTryThrowsBootcamp: View {
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300, alignment: .center)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrowsBootcamp()
}
