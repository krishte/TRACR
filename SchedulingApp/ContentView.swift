//
//  ContentView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI
import UserNotifications
import GoogleSignIn
import GoogleAPIClientForREST

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
    
//    @Published var setupLaunchClass: Bool = false
//    @Published var setupLaunchFreetime: Bool = false
}

class AddTimeSubassignmentBacklog: ObservableObject {
    @Published var backlogList: [[String: String]] = []
}

class MasterRunning: ObservableObject {
    @Published var masterRunningNow: Bool = false
    @Published var masterDisplay: Bool = false
    @Published var onlyNotifications: Bool = false
    @Published var displayText: Bool = false
}

struct MasterRunningDisplay: View {
    @EnvironmentObject var masterRunning: MasterRunning
  //  @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            Text("Optimizing Schedule").foregroundColor(Color.black)
            ZStack(alignment: .leading) {
                Rectangle().foregroundColor(.gray).opacity(0.6).frame(width: 163, height: 3)
                Rectangle().foregroundColor(.blue).frame(width: masterRunning.masterDisplay ? 163 : 0, height: 3).animation(.spring())
            }.cornerRadius(3)
        }.padding(.all, 15).frame(maxHeight: 70).background(Color.white).cornerRadius(10).padding(.all, 15).shadow(radius: 3)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var firstLaunchTutorial: Bool = false
    
    init() {
        if #available(iOS 14.0, *) {
            // iOS 14 doesn't have extra separators below the list by default.
        } else {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
        }
        GIDSignIn.sharedInstance().restorePreviousSignIn()

       // UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
//        UITableView.appearance().backgroundColor = .clear
//        changingDate.score = 1
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func initialize() {
        let defaults = UserDefaults.standard
        
        if !defaults.bool(forKey: "Launched Before") {
            defaults.set(true, forKey: "Launched Before")
            let gradingschemes: [String] = ["P", "N1-7", "LA-F"]
            defaults.set(0, forKey: "weeklyminutesworked")
            let lastmondaydate =  Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            let nextmondaydate = Date(timeInterval: 604800, since: lastmondaydate)
            
            defaults.set(nextmondaydate, forKey: "weeklyzeroday")
            
            
            
            defaults.set(gradingschemes, forKey: "savedgradingschemes")
            let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
            
            for assignmenttype in assignmenttypes {
                let newType = AssignmentTypes(context: self.managedObjectContext)
                
                newType.type = assignmenttype
                newType.rangemin = 60
                newType.rangemax = 180
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            defaults.set(Date(), forKey: "lastNudgeDate")
            
            self.firstLaunchTutorial = true
        }
        var val = defaults.object(forKey: "weeklyzeroday") as? Date
        if (val == nil)
        {
            val = Date()
        }
        if (Date() > val!)
        {
            defaults.set(0, forKey: "weeklyminutesworked")
            let lastmondaydate =  Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
            let nextmondaydate = Date(timeInterval: 604800, since: lastmondaydate)
            defaults.set(nextmondaydate, forKey: "weeklyzeroday")
            
        }
        for (index, element) in classlist.enumerated()
        {
            if (element.isTrash)
            {
                self.managedObjectContext.delete(self.classlist[index])
            }

        }
        
        
    }

    var body: some View {
        ZStack {
            TabView {
                HomeView().tabItem {
                    Image(systemName: "house").resizable().scaledToFill()
                    Text("Home").font(.body)
                }
                
                FilterView().tabItem {
                    Image(systemName:"doc.plaintext").resizable().scaledToFill()
                    Text("Assignments")
                }
                
                ClassesView().tabItem {
                    Image(systemName: "folder").resizable().scaledToFill()
                    Text("Classes")
                }
                
                ProgressView().tabItem {
                    Image(systemName: "chart.bar").resizable().scaledToFit()
                    Text("Progress")
                }
                
//                GoogleView().tabItem {
//                    Image(systemName: "person.circle.fill").resizable().scaledToFit()
//                    Text("Hello")
//                }

                
                
                

            }.onAppear
            {
                initialize()
                let defaults = UserDefaults.standard

                defaults.set(false, forKey:"accessedclassroom")
                
            }.onDisappear
            {
                let defaults = UserDefaults.standard
                defaults.set(Date(timeIntervalSinceNow: 0), forKey: "lastaccessdate")
                
            }//.accentColor(Color.orange)
            
            VStack {
                MasterRunningDisplay().offset(y: masterRunning.masterDisplay ? 0 : -200 ).animation(.spring())
                Spacer()
            }.frame(width: UIScreen.main.bounds.size.width).background((masterRunning.masterDisplay ? Color(UIColor.label).opacity(0.15) : Color.clear).edgesIgnoringSafeArea(.all))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        ContentView()
    }
}
