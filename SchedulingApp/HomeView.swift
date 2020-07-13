//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

func NewAssignment() {
    print("new assignment")
}

func NewClass() {
    print("new class")
}

func NewOccupiedTime() {
    print("new occupied time")
}

func NewFreeTime() {
    print("new free time")
}

func NewGrade() {
    print("new grade")
}

struct AddOptionsSubView: View {
    var assignmentFunc: () -> ()
    var systemImageName: String
    var addText: String
        
    var body: some View {
        Button(action: {self.assignmentFunc()}) {
            Text(addText)
            Image(systemName: self.systemImageName)
        }
    }
}

struct AddOptionsView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            VStack(alignment: .trailing, spacing: 10) {
                AddOptionsSubView(assignmentFunc: {
                    NewAssignment()
                }, systemImageName: "paperclip", addText: "Assignment")

                AddOptionsSubView(assignmentFunc: {
                    NewClass()
                }, systemImageName: "list.bullet", addText: "Class")

                AddOptionsSubView(assignmentFunc: {
                    NewOccupiedTime()
                }, systemImageName: "clock.fill", addText: "Occupied Time")

                AddOptionsSubView(assignmentFunc: {
                    NewFreeTime()
                }, systemImageName: "clock", addText: "Free Time")

                AddOptionsSubView(assignmentFunc: {
                    NewGrade()
                }, systemImageName: "percent", addText: "Grade")
                
            }.padding().background(Color("add_overlay_bg")).overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("add_overlay_border"), lineWidth: 1)
            ).shadow(color: Color.black.opacity(0.1), radius: 20, x: -7, y: 7).padding(.leading, 61)
            
            Spacer()
        }
    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Subassignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignment.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignment>
    
    var body: some View {
             GeometryReader { geometry in
                 NavigationView{
                     Text("Schedule")
                     .navigationBarItems(
                        leading:
                            HStack(spacing: geometry.size.width / 4.2) {
                                Button(action: {print("settings button clickedd")}) {
                                    Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                                }.padding(.leading, 2.0);
                            
                                Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                                Button(action: {NewAssignment()}){
                                    Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                                }.contextMenu{
                                    AddOptionsView()
                                }
                            }.padding(.top, -5.0))
                 }
            }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
             let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return HomeView().environment(\.managedObjectContext, context)
    }
}
