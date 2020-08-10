//
//  SettingsView.swift
//  SchedulingApp
//
//  Created by Charan Vadrevu on 06.08.20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import Foundation
import Combine
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
        @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    
    @State var cleardataalert = false
    var body: some View {
        Form {
        List {
            Section {
                NavigationLink(destination: PreferencesView()) {
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
            }
            Section {
                Button(action: {
                    self.cleardataalert.toggle()

                }) {
                    Text("Clear All Data").foregroundColor(Color.red)
                }.alert(isPresented:$cleardataalert) {
                    Alert(title: Text("Are you sure you want to clear all data?"), message: Text("There is no undoing this operation"), primaryButton: .destructive(Text("Clear All Data")) {
                        self.delete()
                        print("data cleared")
                    }, secondaryButton: .cancel())
                }
                
            }
            }
            
            Button(action: {self.deleteAll()}, label: {Text("Clear All Data").frame(minWidth: 0, maxWidth: .infinity).padding().foregroundColor(.red).background(Color.gray).cornerRadius(40).padding(.horizontal, 20)})
        }.navigationBarTitle("Settings")
    }
    func delete() -> Void {
        for (index, _) in self.subassignmentlist.enumerated() {
             self.managedObjectContext.delete(self.subassignmentlist[index])
        }
        for (index, _) in self.assignmenttypeslist.enumerated() {
             self.managedObjectContext.delete(self.assignmenttypeslist[index])
        }
        for (index, _) in self.assignmentlist.enumerated() {
             self.managedObjectContext.delete(self.assignmentlist[index])
        }
        for (index, _) in self.classlist.enumerated() {
             self.managedObjectContext.delete(self.classlist[index])
        }
//                for (index, _) in self.freetimelist.enumerated() {
//                     self.managedObjectContext.delete(self.freetimelist[index])
//                }
    }
}
struct HelpCenterView: View {
    
    var body: some View {
        Text("Get HEEEELLLLPPPP")
    }
}
struct PreferencesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: AssignmentTypes.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \AssignmentTypes.type, ascending: true)])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State private var typeval: Int = 150

    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    var body: some View {
        VStack {
          //  Form {
                ScrollView(showsIndicators: false) {
                    ForEach(self.assignmenttypeslist) {
                        assignmenttype in
                        DetailPreferencesView(assignmenttype: assignmenttype)
                    }
                }
           // }.navigationBarTitle("Preferences")
        }.navigationBarTitle("Preferences")
    }
}
struct DetailPreferencesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var assignmenttype: AssignmentTypes
    @FetchRequest(entity: AssignmentTypes.entity(),
                  sortDescriptors: [])

    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State var currentdragoffsetmin = CGSize.zero
    @State var currentdragoffsetmax = CGSize.zero
    @State var newdragoffsetmax = CGSize.zero
    @State private var typeval: Double = 0
    @State private var typeval2: Double = 0
    @State private var newdragoffsetmin = CGSize.zero
    
    @State var rectangleWidth = UIScreen.main.bounds.size.width - 60;
    
    init(assignmenttype: AssignmentTypes)
    {
        self.assignmenttype = assignmenttype


    }
    func setValues() -> Bool {
        self.typeval = Double(assignmenttype.rangemin)
        self.typeval2 = Double(assignmenttype.rangemax)
        return true;
        
    }
    var body: some View
    {
            
            VStack {
//                if (setValues())
//                {
//
//                }
                Text(assignmenttype.type).font(.title).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
                //Text(String(assignmenttype.rangemin) + " " + String(assignmenttype.rangemax))
                
//                VStack {
//                    Slider(value: $typeval, in: 30...300, step: 15)
//                    Text("Min: " + String(Int(typeval)))
//                }
//                VStack {
//                    Slider(value: $typeval2, in: 30...300, step: 15)
//                    Text("Max: " + String(Int(typeval2)))
//                }
                
                ZStack {

                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.rectangleWidth, height: 20, alignment: .leading).overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: self.rectangleWidth, height: 20, alignment: .leading)
                    )
                    Rectangle().fill(Color.green).frame(width: max(self.currentdragoffsetmax.width - self.currentdragoffsetmin.width, 0), height: 19).offset(x: getrectangleoffset())
                    
                    VStack {
                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2)
                        Text(String(roundto15minutes(roundvalue: getmintext())))

                    }.offset(x:  self.currentdragoffsetmin.width, y: 15)
                        // 3.
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                               // print(value.translation.width)
   
                                self.currentdragoffsetmin = CGSize(width: value.translation.width + self.newdragoffsetmin.width, height: value.translation.height + self.newdragoffsetmin.height)
                                
                                if (self.currentdragoffsetmin.width < -1*self.rectangleWidth/2)
                                {
                                    self.currentdragoffsetmin.width = -1*self.rectangleWidth/2
                                }
                                if (self.currentdragoffsetmin.width > self.rectangleWidth/2)
                                {
                                    self.currentdragoffsetmin.width = self.rectangleWidth/2
                                }
                                if (self.currentdragoffsetmin.width > self.currentdragoffsetmax.width)
                                {
                                    self.currentdragoffsetmin.width = self.currentdragoffsetmax.width
                                }
                        }   // 4.
                            .onEnded { value in
                               self.currentdragoffsetmin = CGSize(width: value.translation.width + self.newdragoffsetmin.width, height: value.translation.height + self.newdragoffsetmin.height)
                                if (self.currentdragoffsetmin.width < -1*self.rectangleWidth/2)
                                {
                                    self.currentdragoffsetmin.width = -1*self.rectangleWidth/2
                                }
                                if (self.currentdragoffsetmin.width > self.rectangleWidth/2)
                                {
                                    self.currentdragoffsetmin.width = self.rectangleWidth/2
                                }
                                if (self.currentdragoffsetmin.width > self.currentdragoffsetmax.width)
                                {
                                    self.currentdragoffsetmin.width = self.currentdragoffsetmax.width
                                }
                                self.newdragoffsetmin = self.currentdragoffsetmin
                            }
                    )
                    VStack {
                        Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2)
                        Text(String(roundto15minutes(roundvalue: getmaxtext())))
                    }.offset(x:  self.currentdragoffsetmax.width, y: 15)
                         // 3.
                         .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                             .onChanged { value in
                                // print(value.translation.width)
    
                                 self.currentdragoffsetmax = CGSize(width: value.translation.width + self.newdragoffsetmax.width, height: value.translation.height + self.newdragoffsetmax.height)
                                 
                                 if (self.currentdragoffsetmax.width < -1*self.rectangleWidth/2)
                                 {
                                     self.currentdragoffsetmax.width = -1*self.rectangleWidth/2
                                 }
                                 if (self.currentdragoffsetmax.width > self.rectangleWidth/2)
                                 {
                                     self.currentdragoffsetmax.width = self.rectangleWidth/2
                                 }
                                if (self.currentdragoffsetmax.width < self.currentdragoffsetmin.width)
                                {
                                    self.currentdragoffsetmax.width = self.currentdragoffsetmin.width
                                }
                         }   // 4.
                             .onEnded { value in
                                self.currentdragoffsetmax = CGSize(width: value.translation.width + self.newdragoffsetmax.width, height: value.translation.height + self.newdragoffsetmax.height)
                                 if (self.currentdragoffsetmax.width < -1*self.rectangleWidth/2)
                                 {
                                     self.currentdragoffsetmax.width = -1*self.rectangleWidth/2
                                 }
                                 if (self.currentdragoffsetmax.width > self.rectangleWidth/2)
                                 {
                                     self.currentdragoffsetmax.width = self.rectangleWidth/2
                                 }
                                if (self.currentdragoffsetmax.width < self.currentdragoffsetmin.width)
                                {
                                    self.currentdragoffsetmax.width = self.currentdragoffsetmin.width
                                }
                                self.newdragoffsetmax = self.currentdragoffsetmax
                             }
                     )

                }
//                HStack {
//                   // Text("Min: " + String(roundto15minutes(roundvalue: getmintext()))).frame(width: rectangleWidth/2)
//                 //   Text("Max: " + String(roundto15minutes(roundvalue: getmaxtext()))).frame(width: rectangleWidth/2)
//                }
                Spacer().frame(height: 30)
                Divider().frame(width: rectangleWidth, height: 2)

            }.padding(10).onAppear {
                self.typeval = Double(self.assignmenttype.rangemin)
                self.typeval2 = Double(self.assignmenttype.rangemax)
                self.currentdragoffsetmin.width = ((CGFloat(self.assignmenttype.rangemin)-195)/105)*self.rectangleWidth/2
                self.currentdragoffsetmax.width = ((CGFloat(self.assignmenttype.rangemax)-195)/105)*self.rectangleWidth/2
                self.newdragoffsetmin.width = ((CGFloat(self.assignmenttype.rangemin)-195)/105)*self.rectangleWidth/2
                self.newdragoffsetmax.width = ((CGFloat(self.assignmenttype.rangemax)-195)/105)*self.rectangleWidth/2
            }.onDisappear {
//                self.assignmenttype.rangemin = Int64(self.typeval)
//                self.assignmenttype.rangemax = Int64(self.typeval2)
                self.assignmenttype.rangemin  = Int64(self.roundto15minutes(roundvalue: self.getmintext()))
                self.assignmenttype.rangemax  = Int64(self.roundto15minutes(roundvalue: self.getmaxtext()))
                do {
                    try self.managedObjectContext.save()
                    //print("AssignmentTypes rangemin/rangemax changed")
                } catch {
                    print(error.localizedDescription)
                }
            }

        
    }
    func roundto15minutes(roundvalue: Int) -> Int {
        if (roundvalue % 15 <= 7)
        {
            return roundvalue - (roundvalue % 15)
        }
        else{
            return roundvalue + 15 - (roundvalue % 15)
        }
    }
    func getrectangleoffset() -> CGFloat {
        return -1*((self.currentdragoffsetmax.width-self.currentdragoffsetmin.width)/2 - (self.currentdragoffsetmin.width))+max(self.currentdragoffsetmax.width - self.currentdragoffsetmin.width, 0)
    }
    func getmintext() -> Int {
        return 195 + Int((self.currentdragoffsetmin.width/(rectangleWidth/2))*105)
    }
    func getmaxtext() -> Int {
        return 195 + Int((self.currentdragoffsetmax.width/(rectangleWidth/2))*105)
    }
}
struct NotificationsView: View {
    let beforeassignmenttimes = ["At Start", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]
    @State var selectedbeforeassignment = 0
    @State var selectedbeforebreak = 0
    let beforebreaktimes = [0,5, 10, 15, 30]
    @State var atassignmentstart = false
    @State var atbreakstart = false
    @State var atassignmentend = false
    @State private var selection: Set<String> = ["None"]
    @State private var selection2: Set<String> = ["None"]
    @State var atbreakend = false
    
    
    
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    private func selectDeselect2(_ singularassignment: String) {
        if selection2.contains(singularassignment) {
            selection2.remove(singularassignment)
        } else {
            selection2.insert(singularassignment)
        }
    }
    var body: some View {
        // NavigationView {
          //  VStack {
                //Text("hello")
                    //NavigationView {
        VStack {
            //Spacer()
                        Form {
                       //     Text("Before Tasks").font(.title)
                            Section(header: Text("Before Tasks").font(.system(size: 20))) {
                                List {
                                    HStack {
                                         Button(action: {
                                            if (self.selection.count != 1) {
                                                self.selection.removeAll()
                                                self.selectDeselect("None")
                                            }
                                             
                                         }) {
                                             Text("None").foregroundColor(.black)
                                         }
                                        
                                         if (self.selection.contains("None")) {
                                             Spacer()
                                             Image(systemName: "checkmark").foregroundColor(.blue)
                                         }
                                     }
                                    ForEach(self.beforeassignmenttimes,  id: \.self) { repeatoption in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Button(action: {self.selectDeselect(repeatoption)
                                                    if (self.selection.count==0) {
                                                        self.selectDeselect("None")
                                                    }
                                                    else if (self.selection.contains("None")) {
                                                        self.selectDeselect("None")
                                                    }
                                                    
                                                }) {
                                                    Text(repeatoption).foregroundColor(.black)
                                                }
                                                if (self.selection.contains(repeatoption)) {
                                                    Spacer()
                                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                       //     Text("Before Break").font(.title)
                            Section(header: Text("Before Break").font(.system(size: 20))) {
                                List {
                                    HStack {
                                         Button(action: {
                                            if (self.selection2.count != 1) {
                                                self.selection2.removeAll()
                                                self.selectDeselect2("None")
                                            }
                                             
                                         }) {
                                             Text("None").foregroundColor(.black)
                                         }
                                        
                                         if (self.selection2.contains("None")) {
                                             Spacer()
                                             Image(systemName: "checkmark").foregroundColor(.blue)
                                         }
                                     }
                                    ForEach(self.beforeassignmenttimes,  id: \.self) { repeatoption in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Button(action: {self.selectDeselect2(repeatoption)
                                                    if (self.selection2.count==0) {
                                                        self.selectDeselect2("None")
                                                    }
                                                    else if (self.selection2.contains("None")) {
                                                        self.selectDeselect2("None")
                                                    }
                                                    
                                                }) {
                                                    Text(repeatoption).foregroundColor(.black)
                                                }
                                                if (self.selection2.contains(repeatoption)) {
                                                    Spacer()
                                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
//                            Picker(selection: $selectedbeforeassignment, label: Text("Before Assignment")) {
//                                ForEach(0 ..< beforeassignmenttimes.count) {
//
//                                    if (self.beforeassignmenttimes[$0] == 0)
//                                    {
//                                        Text("None")
//                                    }
//                                    else
//                                    {
//                                        Text(String(self.beforeassignmenttimes[$0]) + " minutes")
//                                    }
//
//
//                                }
//                            }
//                            Picker(selection: $selectedbeforebreak, label: Text("Before Break")) {
//                                ForEach(0 ..< beforebreaktimes.count) {
//
//                                    if (self.beforebreaktimes[$0] == 0)
//                                    {
//                                        Text("None")
//                                    }
//                                    else
//                                    {
//                                        Text(String(self.beforebreaktimes[$0]) + " minutes")
//                                    }
//
//
//                                }
//                            }
//                            Toggle(isOn: $atassignmentstart) {
//                                Text("Assignment start")
//                            }
//                            Toggle(isOn: $atbreakstart) {
//                                Text("Break start")
//                            }
//                            Toggle(isOn: $atassignmentend) {
//                                Text("Assignment end")
//                            }
//                            Toggle(isOn: $atbreakend) {
//                                Text("Break end")
//                            }
                        }.navigationBarTitle("Notifications", displayMode: .inline)
        }.onAppear() {
            let defaults = UserDefaults.standard
            let array = defaults.object(forKey: "savedassignmentnotifications") as? [String] ?? ["None"]
            self.selection = Set(array)
            let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
            self.selection2 = Set(array2)
        }.onDisappear() {
            let defaults = UserDefaults.standard
            let array = Array(self.selection)
            defaults.set(array, forKey: "savedassignmentnotifications")
            let array2 = Array(self.selection2)
            defaults.set(array2, forKey: "savedbreaknotifications")
        }
                   // }
               // }//.navigationBarItems(leading: Text("H")).navigationBarTitle("Notifications", displayMode: .inline)
        //}
    }
}
