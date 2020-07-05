//
//  ContentView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
     
        
            TabView {
                
            HomeView().tabItem {
                Image(systemName: "house").resizable().scaledToFill()
                Text("Schedule").font(.body)
                
            }.tag(1)
            ClassesView().tabItem {
                Image(systemName: "list.dash")
                Text("Classes")
                
            }.tag(1)
             FilterView().tabItem {
                Image(systemName:"tortoise")
                Text("Filter").tag(1)
                }
            ProgressView().tabItem {
                Image(systemName: "chart.bar").resizable().scaledToFit()
                Text("Progress").tag(1)
                }
            }
            
        
    }
}
    

    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
