//
//  ProgressView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct ClassProgressView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>

    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color(classcool.color))
                .frame(width: UIScreen.main.bounds.size.width - 40, height: (120 ))
            VStack {
                HStack {
                    Text(classcool.name).font(.title).fontWeight(.bold)
                    Spacer()
                   if getAverageGrade() == 0 {
                       Text("No Grades").font(.body).fontWeight(.light)
                   }
                   else
                   {
                       Text("\(getAverageGrade(), specifier: "%.1f")").font(.title).fontWeight(.bold)
                   }
                }.padding(.horizontal, 25)
                
//                VStack {
//                    ForEach(assignmentlist) {
//                        assignment in
//                            if (assignment.subject == self.classcool.name) {
//                                AssignmentPeakView(assignment: assignment)
//                            }
//                    }
//                }
            }
        }
    }
    
    func getAverageGrade() -> Double
    {
        var gradesum: Double = 0
        var gradenum: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.name && assignment.completed == true)
            {
                gradesum += Double(assignment.grade)
                gradenum += 1
            }
        }
        if (gradesum == 0)
        {
            return 0;
        }
        return (gradesum/gradenum)
    }
}

struct IndividualAssignemntProgressView: View {
    var assignment: Assignment
    
    var body: some View {
        VStack {
            Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
            Text("Type: " + assignment.type).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
            Text("Due date: " + assignment.duedate.description).frame(width:  UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
            Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
            Text("Grade: " + String(assignment.grade)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)

            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                
                HStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.green).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)), alignment: .leading)
                }
            }
        }.padding(10).background(Color(assignment.color)).cornerRadius(20)
    }
}

struct DetailProgressView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.title).fontWeight(.bold)
            Spacer()
            Text("Average grade: \(getAverageGrade(), specifier: "%.1f")")
            Spacer()
            if (getAverageGrade() != 0)
            {
                
            }
            List {
                ForEach(assignmentlist) {
                    assignment in
                    if (assignment.subject == self.classcool.name && assignment.completed == true)
                    {
                        IndividualAssignemntProgressView(assignment: assignment)
                    }
                }
            }
        }
    }
    func getAverageGrade() -> Double
    {
        var gradesum: Double = 0
        var gradenum: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.name && assignment.completed == true)
            {
                gradesum += Double(assignment.grade)
                gradenum += 1
            }
        }
        if (gradesum == 0)
        {
            return 0;
        }
        return (gradesum/gradenum)
    }
}

struct ProgressView: View {
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    var body: some View {
         NavigationView{
            List {
                ForEach(classlist) {
                    classcool in
                    NavigationLink(destination: DetailProgressView(classcool: classcool )) {
                      ClassProgressView(classcool:classcool )
                    }
                }
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
                }.padding(.top, -11.0)).navigationBarTitle("Progress")
         }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
          let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ProgressView().environment(\.managedObjectContext, context)
    }
}
