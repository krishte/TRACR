//
//  SettingsView.swift
//  SchedulingApp
//
//  Created by Charan Vadrevu on 06.08.20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>

    func deleteAll() {
        for (index, _) in subassignmentlist.enumerated() {
             self.managedObjectContext.delete(self.subassignmentlist[index])
        }
        for (index, _) in assignmentlist.enumerated() {
             self.managedObjectContext.delete(self.assignmentlist[index])
        }
        for (index, _) in classlist.enumerated() {
             self.managedObjectContext.delete(self.classlist[index])
        }
//        for (index, _) in freetimelist.enumerated() {
//             self.managedObjectContext.delete(self.freetimelist[index])
//        }
        do {
            try self.managedObjectContext.save()
            print("Class number changed")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        List {
            NavigationLink(destination: Text("bulk n stuff and also umm the aspfo sif oj dark mode themes stuff")) {
                 ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .fill(Color.red)
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
                
                    HStack {
                     Text("Preferences").font(.system(size: 24)).fontWeight(.bold).frame(height: 80)
                        Spacer()

                    }.padding(.horizontal, 25)
                 }
            }
            
            NavigationLink(destination: NotificationsView()) {
                ZStack {
                           
                   RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue)
                       .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
               

                   HStack {
                    Text("Notifications").font(.system(size: 24)).fontWeight(.bold).frame(height: 80)
                       Spacer()

                   }.padding(.horizontal, 25)
                }
            }
            
            NavigationLink(destination: HelpCenterView()) {
                 ZStack {
                            
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .fill(Color.green)
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
                

                    HStack {
                     Text("FAQ").font(.system(size: 24)).fontWeight(.bold).frame(height: 80)
                        Spacer()

                    }.padding(.horizontal, 25)
                 }
            }
            
            Divider().frame(height: 10)
            
            NavigationLink(destination: Text("email and team")) {
                 ZStack {
                            
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .fill(Color.orange)
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
                

                    HStack {
                     Text("About us").font(.system(size: 24)).fontWeight(.bold).frame(height: 80)
                        Spacer()

                    }.padding(.horizontal, 25)
                 }
            }
            
            Button(action: {self.deleteAll()}, label: {Text("Clear All Data").frame(minWidth: 0, maxWidth: .infinity).padding().foregroundColor(.red).background(Color.gray).cornerRadius(40).padding(.horizontal, 20)})
        }.navigationBarTitle("Settings")
    }
}
struct HelpCenterView: View {
    
    var body: some View {
        Text("Get HEEEELLLLPPPP")
    }
}

struct NotificationsView: View {
    let beforeassignmenttimes = [0, 5, 10, 15, 30]
    @State var selectedbeforeassignment = 0
    @State var selectedbeforebreak = 0
    let beforebreaktimes = [0,5, 10, 15, 30]
    @State var atassignmentstart = false
    @State var atbreakstart = false
    @State var atassignmentend = false
    @State var atbreakend = false
    
    var body: some View {
        // NavigationView {
          //  VStack {
                //Text("hello")
                    //NavigationView {
        VStack {
            //Spacer()
                        Form {
                            
                            Picker(selection: $selectedbeforeassignment, label: Text("Before Assignment")) {
                                ForEach(0 ..< beforeassignmenttimes.count) {
                                    
                                    if (self.beforeassignmenttimes[$0] == 0)
                                    {
                                        Text("None")
                                    }
                                    else
                                    {
                                        Text(String(self.beforeassignmenttimes[$0]) + " minutes")
                                    }
                                    

                                }
                            }
                            Picker(selection: $selectedbeforebreak, label: Text("Before Break")) {
                                ForEach(0 ..< beforebreaktimes.count) {

                                    if (self.beforebreaktimes[$0] == 0)
                                    {
                                        Text("None")
                                    }
                                    else
                                    {
                                        Text(String(self.beforebreaktimes[$0]) + " minutes")
                                    }
                                    

                                }
                            }
                            Toggle(isOn: $atassignmentstart) {
                                Text("Assignment start")
                            }
                            Toggle(isOn: $atbreakstart) {
                                Text("Break start")
                            }
                            Toggle(isOn: $atassignmentend) {
                                Text("Assignment end")
                            }
                            Toggle(isOn: $atbreakend) {
                                Text("Break end")
                            }
                        }.navigationBarTitle("Notifications", displayMode: .inline)
        }
                   // }
               // }//.navigationBarItems(leading: Text("H")).navigationBarTitle("Notifications", displayMode: .inline)
        //}
    }
}
