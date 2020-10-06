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

class AddTimeSubassignment: ObservableObject {
    @Published var subassignmentname = "SubAssignmentNameBlank"
    @Published var subassignmentlength = 0
    @Published var subassignmentcolor = "one"
    @Published var subassignmentstarttimetext = "aa:bb"
    @Published var subassignmentendtimetext = "cc:dd"
    @Published var subassignmentdatetext = "dd/mm/yy"
    @Published var subassignmentindex = 0
    @Published var subassignmentcompletionpercentage: Double = 0
}

class ActionViewPresets: ObservableObject {
    @Published var actionViewOffset: CGFloat = UIScreen.main.bounds.size.width
    @Published var actionViewType: String = ""
    @Published var actionViewHeight: CGFloat = 0
}

class AddTimeSubassignmentBacklog: ObservableObject {
    @Published var backlogList: [[String: String]] = []
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    
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
    }
    
    func initialize() {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "Launched Before") {
        }
        else {
            print("a")
            defaults.set(true, forKey: "Launched Before")
            print("b")
            let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
            
            for assignmenttype in assignmenttypes {
                let newType = AssignmentTypes(context: self.managedObjectContext)
                
                newType.type = assignmenttype
                newType.rangemin = 30
                newType.rangemax = 300
                
                do {
                    try self.managedObjectContext.save()
                    print("new Subassignment")
                } catch {
                    print(error.localizedDescription)
                }
            }
            print("c")
            defaults.set(Date(), forKey: "lastNudgeDate")
            print("d")
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
        }.onAppear(perform: initialize)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        ContentView()
    }
}
