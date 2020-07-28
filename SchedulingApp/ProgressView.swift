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
                .shadow(radius: 10)
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
   // let gradedict:[String:[Double]]
    init(classcool2: Classcool)
    {
        classcool = classcool2
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
    }
    var body: some View {
        VStack {
            Text(classcool.name).font(.system(size: 24)).fontWeight(.bold) .frame(maxWidth: UIScreen.main.bounds.size.width-50, alignment: .center).multilineTextAlignment(.center)
            Spacer()
            Text("Average grade: \(getAverageGrade(), specifier: "%.1f")")
            Spacer().frame(height: 20)
            Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 4).background(Color("graphbackground"))
            ScrollView(showsIndicators: false) {
                if (getAverageGrade() != 0)
                 {
                    VStack {
//                        Picker(selection: $selectedtimeframe, label: Text(""))
//                        {
//                            Text("Month").tag(0)
//                            Text("Year").tag(1)
//                        }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 24)
                        //Divider()
                        //Spacer()
                        if (getgradenum())
                        {
                            
                            Text(getFirstAssignmentDate() + " - " + getLastAssignmentDate()).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-20, height: 40, alignment: .topLeading).offset(y: 30)
                        }
                        ZStack {
                            VStack {
                                Rectangle().fill(Color("graphbackground")).frame(width:UIScreen.main.bounds.size.width, height: 300)
                            }.offset(y: 20)
                            
                            VStack(alignment: .leading,spacing: 0) {
                                
                                Spacer()
                                Rectangle().fill(Color.black).frame(width: screensize, height: 0.5).padding(.bottom, 59.5)
                                Rectangle().fill(Color.black).frame(width: screensize, height: 0.5).padding(.bottom, 59.5)
                                Rectangle().fill(Color.black).frame(width: screensize, height: 0.5).padding(.bottom, 59.5)
                                Rectangle().fill(Color.black).frame(width: screensize, height: 0.5).padding(.bottom, 59.5)
                                Rectangle().fill(Color.black).frame(width: screensize, height: 1.5)
                            }.offset(x: -10, y: -15)
                            HStack {
                                //Spacer()
                                ScrollView(.horizontal, showsIndicators: false)
                                {
                                    HStack {
                                        Spacer()
                                        ForEach(assignmentlist) {
                                            assignment in
                                            
                                            if (self.graphableAssignment(assignment: assignment))
                                            {

                                                VStack {
                                                    Spacer()
                                                    Rectangle()
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
                                ZStack {
                                    Rectangle().fill(Color.black).frame(width: 1.5, height: 245).offset(x: -10,y:30).padding(0)
                                    VStack {
                                       // Spacer()
                                        Text("8").frame(width: 20).padding(.top, 40)
                                        Text("6").frame(width: 20).padding(.top, 40)
                                        Text("4").frame(width: 20).padding(.top, 40)
                                        Text("2").frame(width: 20).padding(.top, 40)
                                        Text("0").frame(width: 20).padding(.top, 40)
                                    }.offset(y: 10)
                                }
                            }.offset(y: -16)


                        }
                        
                        Spacer().frame(height: 40)
                        if (getgradenum())
                        {
                            HStack {
                                VStack {
                                    Text("Average").padding(10).font(.title).background(Color("four")).frame(width: UIScreen.main.bounds.size.width/2-30 ,height: (UIScreen.main.bounds.size.width/2-30)/2)
                                    Text("\(getAverageGrade(), specifier: "%.2f")").font(.title).frame(width: UIScreen.main.bounds.size.width/2-30 , height: (UIScreen.main.bounds.size.width/2-30)/4)
                                    if (getChangeInAverageGrade() >= 0)
                                    {
                                        Text("+\(getChangeInAverageGrade(), specifier: "%.2f")").foregroundColor(Color.green).font(.title).frame(width: UIScreen.main.bounds.size.width/2-30 , height: (UIScreen.main.bounds.size.width/2-30)/4)
                                    }
                                    else
                                    {
                                        Text("\(getChangeInAverageGrade(), specifier: "%.2f")").foregroundColor(Color.red).font(.title).frame(width: UIScreen.main.bounds.size.width/2-30 , height: (UIScreen.main.bounds.size.width/2-30)/4)
                                    }
                                }.padding(10).background(Color("four")).cornerRadius(20).shadow(radius: 10)
                                VStack {
                                    Text("Last Assignment vs. Average").padding(10).font(.title).background(Color("four")).frame(width: UIScreen.main.bounds.size.width/2-30 ,height: (UIScreen.main.bounds.size.width/2-30)/2)
                                    Text(String(getLastAssignmentGrade())).font(.title).frame(width: UIScreen.main.bounds.size.width/2-30 , height: (UIScreen.main.bounds.size.width/2-30)/4)
                                    if (Double(getLastAssignmentGrade()) - getAverageGrade() >= 0.0)
                                    {
                                        Text("+\(Double(getLastAssignmentGrade()) - getAverageGrade(), specifier: "%.2f")").foregroundColor(Color.green).font(.title).frame(width: UIScreen.main.bounds.size.width/2-30 , height: (UIScreen.main.bounds.size.width/2-30)/4)
                                    }
                                    else
                                    {
                                        Text("\(Double(getLastAssignmentGrade()) - getAverageGrade(), specifier: "%.2f")").foregroundColor(Color.red).font(.title).frame(width: UIScreen.main.bounds.size.width/2-30 , height: (UIScreen.main.bounds.size.width/2-30)/4)
                                    }
                                }.padding(10).background(Color("four")).cornerRadius(20).shadow(radius: 10)
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
//                
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
    func getFirstAssignmentDate() -> String
    {
        var formattertitle: DateFormatter
        formattertitle = DateFormatter()
        formattertitle.dateFormat = "MMMM yyyy"
        return formattertitle.string(from: assignmentlist[0].duedate)
    }
    func getLastAssignmentDate() -> String
    {
        var storedDate: Date
        storedDate = Date()
        var formattertitle: DateFormatter
        formattertitle = DateFormatter()
        formattertitle.dateFormat = "MMMM yyyy"
        for assignment in assignmentlist {
            storedDate = assignment.duedate
        }
        return formattertitle.string(from: storedDate)
    }
    func getLastAssignmentGrade() -> Int64
    {
        var gradeval: Int64 = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.name && assignment.completed == true && assignment.grade != 0)
            {
                gradeval = assignment.grade
            }
        }
        print(gradeval)
        return gradeval
    }
    func getgradenum() -> Bool
    {
        var gradenum: Int = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.name && assignment.completed == true && assignment.grade != 0)
            {
                gradenum += 1
            }
        }
        if (gradenum >= 2)
        {
            return true
        }
        return false
    }
    func getChangeInAverageGrade() -> Double
    {
        var gradesum: Double = 0
        var gradenum: Double = 0
        var lastgrade: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.name && assignment.completed == true && assignment.grade != 0)
            {
                gradesum += Double(assignment.grade)
                gradenum += 1
                lastgrade = Double(assignment.grade)
            }
        }
        gradesum -= lastgrade
        gradenum -= 1
        return getAverageGrade() - gradesum/gradenum
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
        if (CGFloat(CGFloat((screensize-30)/CGFloat(numberofcompleted)) - 10) < CGFloat((screensize-30)/40))
        {
            return CGFloat((screensize-30)/40)
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
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentlist: FetchedResults<Assignment>
    
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noClassesAlert = false
    @State var noAssignmentsAlert = false
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

                        Button(action: {
                            self.assignmentlist.count > 0 ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()
                            
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
                            }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noAssignmentsAlert) {
                                Alert(title: Text("No Assignments Added"), message: Text("Add an Assignment First"))
                            }
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
