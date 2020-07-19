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

struct IndividualAssignmentFilterView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    
    
    @State var isDragged: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    var formatter: DateFormatter
    
    let isExpanded: Bool
    
    let isCompleted: Bool
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var assignmentduedate: String
    
    init(isExpanded2: Bool, isCompleted2: Bool, assignment2: Assignment)
    {
        isExpanded = isExpanded2
        isCompleted = isCompleted2
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        assignment = assignment2
        assignmentduedate = formatter.string(from: assignment2.duedate)
        
    }
    var body: some View {
        ZStack {
            VStack {
                if (isDragged && !self.isCompleted) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color.green) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: UIScreen.main.bounds.size.width-10+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
                            if (self.dragoffset.width < -110) {
                                Text("Complete").foregroundColor(Color.white).frame(width:100)
                            }
                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width + 110)
                            }
                        }
                    }
                }
            }
            
            VStack {
                if (!isExpanded) {
                    Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                    Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
                }
                    
                else {
                    Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                    Text("Type: " + assignment.type).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                    Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
                    Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                    Text("Time left:  " + String(assignment.timeleft)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                    HStack {
                        if (assignment.progress == 100)
                        {
                            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height: 20, alignment: .leading)
                        }
                        else
                        {
                            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height:20, alignment: .leading)
                            Spacer()
                        }

                    }
                }
            }.padding(10).background( Color(assignment.color)).cornerRadius(20).offset(x: self.dragoffset.width).gesture(DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onChanged { value in
                    if (!self.isCompleted)
                    {
                        self.dragoffset = value.translation
                        self.isDragged = true

                        if (self.dragoffset.width > 0) {
                            self.dragoffset = CGSize.zero
                            self.dragoffset.width = 0
                        }
                                            
                        if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 3/4) {
                            self.deleted = true
                        }
                    }

                }
                .onEnded { value in
                    if (!self.isCompleted)
                    {
                        self.dragoffset = .zero
                         self.isDragged = false
                         if (self.deleted == true) {
                             if (self.deleteonce == true) {
                                 self.deleteonce = false
                                 self.assignment.completed = true
                                 self.assignment.timeleft = 0
                                 self.assignment.progress = 100
                                 

                                 for classity in self.classlist {
                                     if (classity.name == self.assignment.subject) {
                                         classity.assignmentnumber -= 1
                                     }
                                 }
                                 for (index, element) in self.subassignmentlist.enumerated() {
                                     if (element.assignmentname == self.assignment.name)
                                     {
                                         self.managedObjectContext.delete(self.subassignmentlist[index])
                                     }
                                 }
                                 do {
                                     try self.managedObjectContext.save()
                                     print("Assignment completed")
                                 } catch {
                                     print(error.localizedDescription)
                                 }
                             }
                         }
                    }
 
                }).animation(.spring())
        }.padding(10)
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
//                .onDelete { indexSet in
//                    for index in indexSet {
//                        for classity in self.classlist {
//                            if (classity.name == self.assignmentlist[index].subject)
//                            {
//                                classity.assignmentnumber -= 1
//                            }
//                        }
//                        self.managedObjectContext.delete(self.assignmentlist[index])
//                    }
//
//
//
//                      do {
//                       try self.managedObjectContext.save()
//
//                      } catch {
//                       print(error.localizedDescription)
//                       }
//                    print("Assignment deleted")
//                }
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
    
    var body: some View {
        NavigationView{
            VStack {
                DropDown()
            }
            .navigationBarItems(
                leading:
                    HStack(spacing: UIScreen.main.bounds.size.width / 4.2) {
                        Button(action: {print("settings button clicked")}) {
                            Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }.padding(.leading, 2.0);
                    
                        Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4);

                        Button(action: {print("add button clicked")}) {
                            Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
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


