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
                Text("Home").font(.body)
                
            }
            ClassesView().tabItem {
                Image(systemName: "list.dash").resizable().scaledToFill()
                Text("Classes")
                
            }
             FilterView().tabItem {
                Image(systemName:"tortoise").resizable().scaledToFill()
                Text("Filter")
                }
            ProgressView().tabItem {
                Image(systemName: "chart.bar").resizable().scaledToFit()
                Text("Progress")
                    
                }
        }
            
        
    }
}
    

    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
