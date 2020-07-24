//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI


//struct AssignmentPeakView: View {
//    let datedisplay, color, name: String
//
//    init(assignment: Assignment) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yy"
//        self.datedisplay = formatter.string(from: assignment.duedate)
//        self.color = assignment.color
//        self.name = assignment.name
//    }
//
//    var body: some View {
//        HStack {
//            Text(self.name).fontWeight(.medium)
//            Spacer()
//            Text(self.datedisplay).fontWeight(.light)
//        }.padding(.horizontal, 25).padding(.top, 15)
//    }
//}

struct ClassView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
//    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
//
//    var assignmentlist: FetchedResults<Assignment>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color(classcool.color))
                .frame(width: UIScreen.main.bounds.size.width - 40, height: (120))
            VStack {
                HStack {
                    Text(classcool.name).font(.system(size: 22 + CGFloat(50 / classcool.name.count))).fontWeight(.bold)
                    Spacer()
                    if classcool.assignmentnumber == 0 {
                        Text("No Assignments").font(.body).fontWeight(.light)
                    }
                    else {
                        Text(String(classcool.assignmentnumber)).font(.title).fontWeight(.bold)
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
}

struct IndividualAssignmentView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    var formatter: DateFormatter
    var assignmentdate: String
    
    
    @State var isDragged: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    init(assignment2: Assignment)
    {
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        assignment = assignment2
        assignmentdate = formatter.string(from: assignment2.duedate)
        
    }

    var body: some View {
        ZStack {
            VStack {
                if (isDragged) {
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

                Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                Text("Type: " + assignment.type).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                Text("Due date: "  + assignmentdate).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
                Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                Text("Time left:  " + String(assignment.timeleft)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                

                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                    HStack {
                        RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)), alignment: .leading)
                        Spacer()
                    }
                }
            }.padding(10).background( Color(assignment.color)).cornerRadius(20).offset(x: self.dragoffset.width).gesture(DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onChanged { value in
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
                .onEnded { value in
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
                                print("Class made")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }).animation(.spring())
        }.padding(10)
    }
}


struct DetailView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.system(size: 22 + CGFloat(50 / classcool.name.count))).fontWeight(.bold)
            Spacer()
            Text("Tolerance: " + String(classcool.tolerance))
            Spacer()
            
            ScrollView {
                ForEach(assignmentlist) { assignment in
                    if (self.classcool.assignmentnumber != 0 && assignment.subject == self.classcool.name && assignment.completed == false) {
                        IndividualAssignmentView(assignment2: assignment)
                    }
                }.animation(.spring())
//                .onDelete { indexSet in
//                    for index in indexSet {
//                        self.managedObjectContext.delete(self.assignmentlist[index])
//                    }
//
//                    self.classcool.assignmentnumber -= 1
//
//                    do {
//                        try self.managedObjectContext.save()
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                    print("Assignment has been deleted")
//                }
            }
        }
    }
}

struct ClassesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    
    var assignmentlist: FetchedResults<Assignment>

    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    @State var stored:Double = 0
    var body: some View {
        NavigationView{
            List {
                ForEach(self.classlist) { classcool in
                    NavigationLink(destination: DetailView(classcool: classcool )) {
                        ClassView(classcool: classcool)
                    }
                }.onDelete { indexSet in
                    for index in indexSet {
                        for (index2, element) in self.assignmentlist.enumerated() {
                            if (element.subject == self.classlist[index].name) {
                                for (index3, element2) in self.subassignmentlist.enumerated() {
                                    if (element2.assignmentname == element.name)
                                    {
                                        self.managedObjectContext.delete(self.subassignmentlist[index3])
                                    }
                                }
                                self.managedObjectContext.delete(self.assignmentlist[index2])
                            }

                        }
                    
                        self.managedObjectContext.delete(self.classlist[index])
                    }
                    
                    do {
                        try self.managedObjectContext.save()
                        print("Class made")
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    print("Class deleted")
                }
            }.navigationBarItems(
                leading:
                    HStack(spacing: UIScreen.main.bounds.size.width / 4.2) {
                        Button(action: {
                            let group1 = ["English A: Literature SL", "English A: Literature HL", "English A: Language and Literatue SL", "English A: Language and Literatue HL"]
                            let group2 = ["German B: SL", "German B: HL", "French B: SL", "French B: HL", "German A: Literature SL", "German A: Literature HL", "German A: Language and Literatue SL", "German A: Language and Literatue HL","French A: Literature SL", "French A: Literature HL", "French A: Language and Literatue SL", "French A: Language and Literatue HL" ]
                            let group3 = ["Geography: SL", "Geography: HL", "History: SL", "History: HL", "Economics: SL", "Economics: HL", "Psychology: SL", "Psychology: HL", "Global Politics: SL", "Global Politics: HL"]
                            let group4 = ["Biology: SL", "Biology: HL", "Chemistry: SL", "Chemistry: HL", "Physics: SL", "Physics: HL", "Computer Science: SL", "Computer Science: HL", "Design Technology: SL", "Design Technology: HL", "Environmental Systems and Societies: SL", "Sport Science: SL", "Sport Science: HL"]
                            let group5 = ["Mathematics: Analysis and Approaches SL", "Mathematics: Analysis and Approaches HL", "Mathematics: Applications and Interpretation SL", "Mathematics: Applications and Interpretation HL"]
                            let group6 = ["Music: SL", "Music: HL", "Visual Arts: SL", "Visual Arts: HL", "Theatre: SL" , "Theatre: HL" ]
                            let extendedessay = "Extended Essay"
                            let tok = "Theory of Knowledge"
                            let assignmenttypes = ["exam", "essay", "presentation", "test", "study"]
                            let classnames = [group1.randomElement()!, group2.randomElement()!, group3.randomElement()!, group4.randomElement()!, group5.randomElement()!, group6.randomElement()!, extendedessay, tok ]
            
                            for classname in classnames {
                                let newClass = Classcool(context: self.managedObjectContext)
                                newClass.attentionspan = Int64.random(in: 0 ... 10)
                                newClass.tolerance = Int64.random(in: 0 ... 10)
                                newClass.name = classname
                                newClass.assignmentnumber = 0
                                newClass.color = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].randomElement()!
                                
                                do {
                                    try self.managedObjectContext.save()
                                    print("Class made")
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                            for classname in classnames {
                                let randomint = Int.random(in: 1...10)
                                for i in 0 ..< randomint {
                                    let newAssignment = Assignment(context: self.managedObjectContext)
                                    newAssignment.name = classname + " assignment " + String(i)
                                    newAssignment.duedate = Date(timeIntervalSinceNow: Double.random(in: 100000 ... 1000000))
                                    newAssignment.totaltime = Int64.random(in: 2...10)
                                    newAssignment.subject = classname
                                    newAssignment.timeleft = Int64.random(in: 1 ... newAssignment.totaltime)
                                    newAssignment.progress = Int64((Double(newAssignment.totaltime - newAssignment.timeleft)/Double(newAssignment.totaltime)) * 100)
                                    newAssignment.grade = Int64.random(in: 1...7)
                                    newAssignment.completed = false
                                    newAssignment.type = assignmenttypes.randomElement()!

                                    for classity in self.classlist {
                                        if (classity.name == newAssignment.subject) {
                                            classity.assignmentnumber += 1
                                            newAssignment.color = classity.color
                                            do {
                                                try self.managedObjectContext.save()
                                                print("Class number changed")
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                    let newrandomint = Int.random(in: 2...5)
                                    var hoursleft = newAssignment.timeleft

                                    for j in 0..<newrandomint {
                                        if (hoursleft == 0)
                                        {
                                            break
                                        }
                                        else if (hoursleft == 1 || j == newrandomint-1)
                                        {
                                            let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
                                            newSubassignment.assignmentname = newAssignment.name
                                            let randomDate = Double.random(in:self.stored ... (self.stored+100000))
                                            newSubassignment.startdatetime = Date(timeIntervalSinceNow: randomDate)
                                            newSubassignment.enddatetime = Date(timeIntervalSinceNow: randomDate + Double(3600*hoursleft))
                                            self.stored  += 20000
                                            newSubassignment.color = newAssignment.color
                                            newSubassignment.assignmentduedate = newAssignment.duedate
                                            print(newSubassignment.assignmentduedate.description)
                                            hoursleft = 0
                                            do {
                                                try self.managedObjectContext.save()
                                                print("new Subassignment")
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                        else
                                        {
                                            let thirdrandomint = Int64.random(in: 1...2)
                                            let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
                                            newSubassignment.assignmentname = newAssignment.name
                                            let randomDate = Double.random(in:self.stored ... (self.stored+100000))
                                            newSubassignment.startdatetime = Date(timeIntervalSinceNow: randomDate)
                                            newSubassignment.enddatetime = Date(timeIntervalSinceNow: randomDate + Double(3600*thirdrandomint))
                                            self.stored += 20000
                                            newSubassignment.color = newAssignment.color
                                            newSubassignment.assignmentduedate = newAssignment.duedate
                                            print(newSubassignment.assignmentduedate.description)
                                            hoursleft -= thirdrandomint
                                            do {
                                                try self.managedObjectContext.save()
                                                print("new Subassignment")
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                    
                                    do {
                                        try self.managedObjectContext.save()
                                        print("Class made")
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                                
                            }
//                            for i in (0...4)
//                            {
//                                
//                                let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
//                                newSubassignment.assignmentname = self.assignmentlist[0].name
//                                let randomDate = (i*i) * 3600
//                                print(randomDate)
//                                newSubassignment.startdatetime = Date(timeIntervalSince1970: TimeInterval(1595466000 + randomDate))
//                                newSubassignment.enddatetime = Date(timeIntervalSince1970: TimeInterval(1595466000 + randomDate + (i+1)*3600))
//                            
//                                newSubassignment.color = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].randomElement()!
//                                newSubassignment.assignmentduedate = Date(timeIntervalSince1970: TimeInterval(1595466000 + randomDate + 3600))
//                                do {
//                                    try self.managedObjectContext.save()
//                                    print("new Subassignment")
//                                } catch {
//                                    print(error.localizedDescription)
//                                        }
//                            }
                        })
                        {
                            Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                    
                        Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4)

                        Button(action: {print("add button clicked")}) {
                            Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                    }).navigationBarTitle(Text("Classes"))
         }
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)

    }
}
