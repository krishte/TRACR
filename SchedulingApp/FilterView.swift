//
//  FilterView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct DropDown: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selectedFilter = 0
    @State private var showCompleted = false

    init() {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }

    var filters = ["Class", "Due date", "Total time", "Time left", "Name", "Type"]
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker(selection: $selectedFilter, label: Text("Sort by: ")) {
                        Section {
                            ForEach(0 ..< filters.count) {
                               Text(self.filters[$0])
                            }
                        }
                    }
                    Toggle(isOn: $showCompleted) {
                        Text("Show Completed Assignments")
                    }
                }
            }.frame(height: 90)
            
            AssignmentsView(selectedFilter: self.filters[selectedFilter], value: showCompleted)
        }
    }
}

struct AssignmentsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selection: Set<Assignment> = []

    var assignmentlistrequest: FetchRequest<Assignment>
    var assignmentlist: FetchedResults<Assignment>{assignmentlistrequest.wrappedValue}
    var showCompleted: Bool
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])

    var classlist: FetchedResults<Classcool>
    
    init(selectedFilter:String, value: Bool){
        if (selectedFilter == "Due date") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
        }
            
        else if (selectedFilter == "Total time") {
           self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.totaltime, ascending: true)])
        }
            
        else if (selectedFilter == "Class") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
        }
            
        else if (selectedFilter == "Name") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.name, ascending: true)])
        }
            
        else if (selectedFilter == "Time left") {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.timeleft, ascending: true)])
        }
            
        else {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.type, ascending: true)])
        }
        self.showCompleted = value
    }
    
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(assignmentlist) { assignment in
                  if (assignment.completed == self.showCompleted) {
                        VStack {
                            IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: self.showCompleted, assignment2: assignment).onTapGesture {
                                    self.selectDeselect(assignment)
                                }.animation(.spring()).shadow(radius: 10)
                        }
                    }
                }.animation(.spring())
            }
        }
    }
}

struct FilterView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noClassesAlert = false
    var body: some View {
        NavigationView{
            VStack {
                DropDown()
            }
            .navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 3.7) {
                        Button(action: {print("settings button clicked")}) {
                            Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }.padding(.leading, 2.0);
                    
                        Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 5);

                        Button(action: {
                            self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
                            
                        }) {
                            Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }.contextMenu{
                            Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
                                Text("Assignment")
                                Image(systemName: "paperclip")
                            }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noClassesAlert) {
                                Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                            }
                            Button(action: {self.NewClassPresenting.toggle()}) {
                                Text("Class")
                                Image(systemName: "list.bullet")
                            }.sheet(isPresented: $NewClassPresenting, content: {
                                NewClassModalView(NewClassPresenting: self.$NewClassPresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                Text("Occupied Time")
                                Image(systemName: "clock.fill")
                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: { NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewFreetimePresenting.toggle()}) {
                                Text("Free Time")
                                Image(systemName: "clock")
                            }.sheet(isPresented: $NewFreetimePresenting, content: { NewFreetimeModalView(NewFreetimePresenting: self.$NewFreetimePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewGradePresenting.toggle()}) {
                                Text("Grade")
                                Image(systemName: "percent")
                            }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                        }
                }.padding(.top, -11.0)).navigationBarTitle("Assignment List")
         }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return FilterView().environment(\.managedObjectContext, context)
    }
}


