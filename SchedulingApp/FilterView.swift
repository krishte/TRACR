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
    
    var filters = ["Class", "Due date", "Total time", "Time left", "Assignment name", "Class"]
    var body: some View {
        VStack {
//            Text("Sort By: ")
//                .contextMenu {
//                Button(action: {
//
//                           }) {
//                               Text("Class name")
//                               Image(systemName: "list.dash")
//                           }
//
//                           Button(action: {
//
//                           }) {
//                               Text("Due date")
//                               Image(systemName: "calendar")
//                           }
//
//            }
            Form {
                Section {
                    Picker(selection: $selectedFilter, label: Text("Sort by: ")) {
                       ForEach(0 ..< filters.count) {
                          Text(self.filters[$0])
                       }
                    }
                }
            }.frame(height: 50)

            
        }
    }

}



struct FilterView: View {
    

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    
    
    
    var body: some View {
         GeometryReader { geometry in
             NavigationView{
                
                
                VStack {
                        DropDown()
                        List {
                            ForEach(self.assignmentlist) {
                                assignment in
                                IndividualAssignmentView(assignment: assignment)

                               
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


