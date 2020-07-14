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
    
    var filters = ["Class", "Due date", "Total time", "Time left", "Name", "Type", "Grade", "Completed Assignments"]
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
                }
            }.frame(height: 50)
            
            AssignmentsView(selectedFilter: self.filters[selectedFilter])
            
        }
    }

}

struct IndividualAssignmentFilterView: View {
    var assignment: Assignment
    let isExpanded: Bool
    var body: some View {

        
        VStack {
            if (!isExpanded)
            {
              Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
              Text("Due date: " + assignment.duedate.description).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
            }
            else
            {
                Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                Text("Type: " + assignment.type).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                Text("Due date: " + assignment.duedate.description).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
                Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                Text("Time left:  " + String(assignment.timeleft)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
            }

                ZStack {
                   RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                   HStack {
                       RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.green).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)), alignment: .leading)
                       Spacer()
                   }
                  
                   
               }
            }.padding(10).background( Color(assignment.color)).cornerRadius(20)
    }
    
    
}

struct AssignmentsView: View {
    

    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selection: Set<Assignment> = []

    
    var assignmentlistrequest: FetchRequest<Assignment>
    var assignmentlist: FetchedResults<Assignment>{assignmentlistrequest.wrappedValue}
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    

    

    init(selectedFilter:String){
        if (selectedFilter == "Due date")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
        }
        else if (selectedFilter == "Total time")
        {
           self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.totaltime, ascending: true)])
        }
        else if (selectedFilter == "Class")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
        }
        else if (selectedFilter == "Name")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.name, ascending: true)])
        }
        else if (selectedFilter == "Time left")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.timeleft, ascending: true)])
        }
        else if (selectedFilter == "Type")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.type, ascending: true)])
        }
        else if (selectedFilter == "Grade")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.grade, ascending: true)])
        }
        else
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true)])
        }

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
            
            List {
                ForEach(self.assignmentlist) {
                    assignment in
                    IndividualAssignmentFilterView(assignment: assignment, isExpanded: self.selection.contains(assignment)).onTapGesture {
                        self.selectDeselect(assignment)
                        }.animation(.spring()).shadow(radius: 10)

                   
                }.onDelete { indexSet in
                    for index in indexSet {
                        for classity in self.classlist {
                            if (classity.name == self.assignmentlist[index].subject)
                            {
                                classity.assignmentnumber -= 1
                            }
                        }
                        self.managedObjectContext.delete(self.assignmentlist[index])
                    }
                   
                   
                    
                      do {
                       try self.managedObjectContext.save()
                        
                      } catch {
                       print(error.localizedDescription)
                       }
                    print("Assignment deleted")
                }
            }
        }
    }
    
    
}
struct FilterView: View {
    

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
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


