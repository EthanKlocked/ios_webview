//
//  AllDealApp.swift
//  AllDeal
//
//  Created by Ethan Kim on 2023/04/04.
//

import SwiftUI

extension View{
    func toAnyView() -> AnyView{
        AnyView(self)
    }
}

struct ContentView: View {
    
    @State private var showLoading: Bool = false
    
    var body: some View {
        VStack {
            WebView(url:URL(string: "https:alldeal.kr")!, showLoading: $showLoading).overlay(showLoading ? ProgressView("Loading...").toAnyView():EmptyView().toAnyView())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
