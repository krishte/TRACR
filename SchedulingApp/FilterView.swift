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
    @Binding var showCompleted: Bool
    @State private var selectedFilter = 0
    //@State private var showCompleted = false

    init(showCompleted2: Binding<Bool>) {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        self._showCompleted = showCompleted2
    }

    let filters = ["Class", "Due date", "Total time", "Time left", "Name", "Type"]
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
//                    Toggle(isOn: $showCompleted) {
//                        Text("Show Completed Assignments")
//                    }
                    //Text(showCompleted ? "Completed Assignments" : "To-Do Assignments").frame(width: 500, alignment: .leading)
                }
            }.frame(height: 50)
            
            AssignmentsView(selectedFilter: self.filters[selectedFilter], value: showCompleted)
        }
    }
}

struct AssignmentsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selection: Set<Assignment> = []

    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist2: FetchedResults<Assignment>
    var assignmentlistrequest: FetchRequest<Assignment>
    var assignmentlist: FetchedResults<Assignment>{assignmentlistrequest.wrappedValue}
    var showCompleted: Bool
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])

    var classlist: FetchedResults<Classcool>
    @State var showassignmentedit: Bool = false
    @State var selectedassignmentedit: String = ""
    
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
                            if (assignment.completed == true)
                            {
                                GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: self.showCompleted, assignment2: assignment, selectededit: self.$selectedassignmentedit, showedit: self.$showassignmentedit).environment(\.managedObjectContext, self.managedObjectContext).onTapGesture {
                                        self.selectDeselect(assignment)
                                    }.animation(.spring()).shadow(radius: 10)
                                
                            }
                            else
                            {
                                IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: self.showCompleted, assignment2: assignment, selectededit: self.$selectedassignmentedit, showedit: self.$showassignmentedit).environment(\.managedObjectContext, self.managedObjectContext).onTapGesture {
                                        self.selectDeselect(assignment)
                                    }.animation(.spring()).shadow(radius: 10)
                            }
                        }
                    }
                }.animation(.spring())
            }
        }.sheet(isPresented: $showassignmentedit, content: {
            EditAssignmentModalView(NewAssignmentPresenting: self.$showassignmentedit, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist2[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist2[self.getassignmentindex()].timeleft), duedate: self.assignmentlist2[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist2[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist2[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist2[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext)}).animation(.spring())
    }
    func getassignmentindex() -> Int {
        print(selectedassignmentedit)
        for (index, assignment) in assignmentlist2.enumerated() {
            if (assignment.name == selectedassignmentedit)
            {
                print(assignment.name)
                return index
            }
        }
        return 0
    }
}

struct FilterView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme

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
    @State var noAssignmentsAlert = false
    @State var completedvalue = false
    @State var showingSettingsView = false

    var body: some View {
        NavigationView{
            ZStack {
                NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                 { EmptyView() }
                VStack {
                    DropDown(showCompleted2: $completedvalue).environment(\.managedObjectContext, self.managedObjectContext)
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("fifteen")).frame(width: 70, height: 70).padding(20)
                            Button(action: {
                                self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
        //                        self.scalevalue = self.scalevalue == 1.5 ? 1 : 1.5
        //                        self.ocolor = self.ocolor == Color.blue ? Color.green : Color.blue

                                }) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).contextMenu{
                                                                Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
                                                                    Text("Assignment")
                                                                    Image(systemName: "paperclip")
                                                                }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: 0).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noClassesAlert) {
                                                                    Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                                                                }
                                                                Button(action: {self.NewClassPresenting.toggle()}) {
                                                                    Text("Class")
                                                                    Image(systemName: "list.bullet")
                                                                }.sheet(isPresented: $NewClassPresenting, content: {
                                                                    NewClassModalView(NewClassPresenting: self.$NewClassPresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                                    //                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                    //                                Text("Occupied Time")
                                    //                                Image(systemName: "clock.fill")
                                    //                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: { NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                                                                Button(action: {self.NewFreetimePresenting.toggle()}) {
                                                                    Text("Free Time")
                                                                    Image(systemName: "clock")
                                                                }.sheet(isPresented: $NewFreetimePresenting, content: { NewFreetimeModalView(NewFreetimePresenting: self.$NewFreetimePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                                                                Button(action: {self.getcompletedAssignments() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()}) {
                                                                    Text("Grade")
                                                                    Image(systemName: "percent")
                                                                }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting, classfilter: -1).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noAssignmentsAlert) {
                                                                    Alert(title: Text("No Assignments Completed"), message: Text("Complete an Assignment First"))
                                                                }
                                                            }.frame(width: 70, height: 70).padding(20).overlay(
                                    ZStack {
                                        //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                        Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30)
                                    }
                                )
                            }
                        }
                        
                    

                    }
                }
            }
            .navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                    Button(action: {self.showingSettingsView = true}) {
                            Image(systemName: "gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }.padding(.leading, 2.0)
                    
                    Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5)
                        Button(action: {
                            withAnimation(.spring())
                            {
                                self.completedvalue.toggle()
                            }
                            
                        }) {
                            Image(systemName: self.completedvalue ? "checkmark.circle.fill" : "checkmark.circle").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                }.padding(.top, 0)).navigationBarTitle("Assignment List")
        }.onDisappear() {
            self.showingSettingsView = false
        }
    }
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0)
            {
                return true;
            }
        }
        return false
    }
    //hello
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return FilterView().environment(\.managedObjectContext, context)
    }
}


