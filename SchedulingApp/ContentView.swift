//
//  ContentView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI
import UserNotifications

class DisplayedDate: ObservableObject {
    @Published var score: Int = 0
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>

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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
      //  self.schedulenotifications()
    }

    var body: some View {
        TabView {
            HomeView().tabItem {
                Image(systemName: "house").resizable().scaledToFill()
                Text("Home").font(.body)
            }
            
            FilterView().tabItem {
                Image(systemName:"paperclip").resizable().scaledToFill()
                Text("Assignments")
            }
            
            ClassesView().tabItem {
                Image(systemName: "list.dash").resizable().scaledToFill()
                Text("Classes")
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
