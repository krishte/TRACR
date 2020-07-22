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
            if (assignment.subject == classcool.name && assignment.completed == true && assignment.grade != 0)
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
    var formatter: DateFormatter
    var assignmentdate: String
    
    init (assignment2: Assignment)
    {
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        assignment = assignment2
        assignmentdate = formatter.string(from: assignment2.duedate)
    }
    var body: some View {
        VStack {
            Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
            Text("Type: " + assignment.type).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
            Text("Due date: " + self.assignmentdate).frame(width:  UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
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
    @State var selectedtimeframe = 0
    let screensize = UIScreen.main.bounds.size.width-20
    var formatter: DateFormatter
    
    init(classcool2: Classcool)
    {
        classcool = classcool2
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
    }
    var body: some View {
        VStack {
            Text(classcool.name).font(.title).fontWeight(.bold)
            Spacer()
            Text("Average grade: \(getAverageGrade(), specifier: "%.1f")")
            Spacer()
            ScrollView {
                if (getAverageGrade() != 0)
                 {
                    VStack {
                        Picker(selection: $selectedtimeframe, label: Text(""))
                        {
                            Text("Auto").tag(0)
                            Text("Week").tag(1)
                            Text("Month").tag(2)
                            Text("Year").tag(3)
                        }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 24)
                        ZStack {
                            Rectangle().fill(Color.gray).frame(width:UIScreen.main.bounds.size.width, height: 300)
                            
                            VStack(spacing: 0) {
                               Spacer()
    //                            Rectangle().fill(Color.green).frame(width: screensize, height: 60).overlay(Rectangle().stroke(Color.black, lineWidth: 2))
    //                            Rectangle().fill(Color.green).frame(width: screensize, height: 60).overlay(Rectangle().stroke(Color.black, lineWidth: 2))
    //                            Rectangle().fill(Color.green).frame(width: screensize, height: 60).overlay(Rectangle().stroke(Color.black, lineWidth: 2))
    //                            Rectangle().fill(Color.green).frame(width: screensize, height: 80).overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                            }
                            HStack {
                                ForEach(assignmentlist) {
                                    assignment in
                                    
                                    if (self.graphableAssignment(assignment: assignment))
                                    {

                                        VStack {
                                            Spacer()
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(Color.blue)
                                                .frame(width: self.getCompletedNumber(), height: CGFloat(assignment.grade) * 30)
                                            //Text( self.formatter.string(from: assignment.duedate))
                                              //  .font(.footnote)
                                               // .frame(width: self.getCompletedNumber(),height: 20)
                                        }

                                    }
                                }
                            }

                        }
                    }

                 }
//                ForEach(assignmentlist) {
//                    assignment in
//                    if (assignment.subject == self.classcool.name && assignment.completed == true)
//                    {
//                        IndividualAssignemntProgressView(assignment2: assignment)
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
            if (assignment.subject == classcool.name && assignment.completed == true && assignment.grade != 0)
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
    func getCompletedNumber() -> CGFloat
    {
        var numberofcompleted: Double = 0
        
        for assignment in assignmentlist {
            if (assignment.subject == classcool.name && assignment.completed == true && assignment.grade != 0)
            {
                numberofcompleted += 1
            }
        }
        return CGFloat(CGFloat((screensize-30)/CGFloat(numberofcompleted)) - 10)
    }
    func graphableAssignment(assignment: Assignment) -> Bool
    {
        if (assignment.subject == self.classcool.name && assignment.completed == true && assignment.grade != 0)
        {
            return true;
        }
        return false;
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
                    NavigationLink(destination: DetailProgressView(classcool2: classcool )) {
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
