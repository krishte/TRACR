//
//  ContentView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

class DisplayedDate: ObservableObject {
    @Published var score: Int = 0
}

struct ContentView: View {
    @EnvironmentObject var changingDate: DisplayedDate

    init() {
        if #available(iOS 14.0, *) {
            // iOS 14 doesn't have extra separators below the list by default.
        } else {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
        }
       // UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
//        UITableView.appearance().backgroundColor = .clear
//        changingDate.score = 1
    }
    
    var body: some View {
        TabView {
            HomeView().environmentObject(changingDate).tabItem {
                Image(systemName: "house").resizable().scaledToFill()
                Text("Home").font(.body)
            }
            
            ClassesView().tabItem {
                Image(systemName: "list.dash").resizable().scaledToFill()
                Text("Classes")
            }
            
             FilterView().tabItem {
                Image(systemName:"paperclip").resizable().scaledToFill()
                Text("Assignments")
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
