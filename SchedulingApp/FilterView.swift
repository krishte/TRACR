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
    
    var filters = ["Class", "Due date", "Total time", "Time left", "Assignment name"]
    var body: some View {
        VStack {

            Form {
                Section {
                    Picker(selection: $selectedFilter, label: Text("Sort by: ")) {
                       ForEach(0 ..< filters.count) {
                          Text(self.filters[$0])
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
    var body: some View {

        
        VStack {
              Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
              Text("Due date: " + assignment.duedate.description).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
              Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
              Text("Time left:  " + String(assignment.timeleft)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
              Text("Progress: " + String(assignment.progress)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
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
//    var selectedFilter: String
    

    
    var assignmentlistrequest: FetchRequest<Assignment>
    var assignmentlist: FetchedResults<Assignment>{assignmentlistrequest.wrappedValue}
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    
//    @FetchRequest(entity: Assignment.entity(),
//    sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
//
//    var assignmentlist: FetchedResults<Assignment>
    
    

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
        else if (selectedFilter == "Assignment name")
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.name, ascending: true)])
        }
        else
        {
            self.assignmentlistrequest = FetchRequest(entity: Assignment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.timeleft, ascending: true)])
        }


    }
    var body: some View {
        VStack {
            
            List {
                ForEach(self.assignmentlist) {
                    assignment in
                    IndividualAssignmentFilterView(assignment: assignment)

                   
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
         GeometryReader { geometry in
             NavigationView{
                
                
                VStack {
                        DropDown()

                    }
                 .navigationBarItems(
                    leading:
                        HStack(spacing: geometry.size.width / 4.2) {
                            Button(action: {print("settings button clicked")}) {
                                Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }.padding(.leading, 2.0);
                        
                            Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                            Button(action: {print("add button clicked")}) {
                                Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }
                    }.padding(.top, -11.0)).navigationBarTitle("Assignment List")
                    
             }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return FilterView().environment(\.managedObjectContext, context)
    }
}


