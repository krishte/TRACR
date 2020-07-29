//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct ClassView: View {
    @ObservedObject var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        ZStack {
            if (classcool.color != "") {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(classcool.color), getNextColor(currentColor: classcool.color)]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (120)).shadow(radius: 10)
            }

            HStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold).frame(height: 120)
                Spacer()
                if classcool.assignmentnumber == 0 {
                    Text("No Assignments").font(.body).fontWeight(.light)
                }
                else {
                    Text(String(classcool.assignmentnumber)).font(.title).fontWeight(.bold)
                }
            }.padding(.horizontal, 25)
        }
    }
    
    func getNextColor(currentColor: String) -> Color {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "one"]
        for color in colorlist {
            if (color == currentColor)
            {
                return Color(colorlist[colorlist.firstIndex(of: color)! + 1])
            }
        }
        return Color("one")
    }
}

struct EditClassModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @State var currentclassname: String
    @State var classnamechanged: String
    @Binding var EditClassPresenting: Bool
    @State var classtolerancedouble: Double
    var classassignmentnumber: Int
    
    let colorsa = ["one", "two", "three", "four", "five"]
    let colorsb = ["six", "seven", "eight", "nine", "ten"]
    let colorsc = ["eleven", "twelve", "thirteen", "fourteen", "fifteen"]
    
    @State private var coloraselectedindex: Int? = 0
    @State private var colorbselectedindex: Int?
    @State private var colorcselectedindex: Int?
    
    @State private var createclassallowed = true
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Class Name", text: $classnamechanged)
                }
                
                Section {
                    VStack {
                        HStack {
                            Text("Tolerance: \(classtolerancedouble.rounded(.down), specifier: "%.0f")")
                            Spacer()
                        }.frame(height: 30)
                        Slider(value: $classtolerancedouble, in: 1...10)
                    }
                }
                
                Section {
                    HStack {
                        Text("Color:")
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexa in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsa[colorindexa])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                            , lineWidth: (self.coloraselectedindex == colorindexa ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = colorindexa
                                        self.colorbselectedindex = nil
                                        self.colorcselectedindex = nil
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexb in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsb[colorindexb])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                        , lineWidth: (self.colorbselectedindex == colorindexb ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = nil
                                        self.colorbselectedindex = colorindexb
                                        self.colorcselectedindex = nil
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexc in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsc[colorindexc])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                    , lineWidth: (self.colorcselectedindex == colorindexc ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = nil
                                        self.colorbselectedindex = nil
                                        self.colorcselectedindex = colorindexc
                                    }
                                }
                            }
                        }
                    }.padding(.vertical, 10)
                }
                
                Section {
                    Button(action: {
                        let testname = self.classnamechanged
                        
                        self.createclassallowed = true
                        
                        for classity in self.classlist {
                            if classity.name == testname && classity.name != self.currentclassname {
                                print("sdfds")
                                self.createclassallowed = false
                            }
                        }

                        if self.createclassallowed {
                            for classity in self.classlist {
                                if (classity.name == self.currentclassname) {
                                    classity.name = testname
                                    classity.tolerance  = Int64(self.classtolerancedouble.rounded(.down))
                                    if self.coloraselectedindex != nil {
                                        classity.color = self.colorsa[self.coloraselectedindex!]
                                    }
                                    else if self.colorbselectedindex != nil {
                                        classity.color = self.colorsb[self.colorbselectedindex!]
                                    }
                                    else if self.colorcselectedindex != nil {
                                        classity.color = self.colorsc[self.colorcselectedindex!]
                                    }
                                    
                                    for assignment in self.assignmentlist {
                                        if (assignment.subject == self.currentclassname) {
                                            assignment.subject = testname
                                            assignment.color = classity.color
                                            for subassignment in self.subassignmentlist {
                                                if (subassignment.assignmentname == assignment.name) {
                                                    subassignment.color = classity.color
                                                }
                                            }
                                        }
                                    }
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            self.EditClassPresenting = false
                        }
                            
                        else {
                            print("Class with Same Name Exists; Change Name")
                            self.showingAlert = true
                        }
                    }) {
                        Text("Save Changes")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text("Class Already Exists"), message: Text("Change Class"), dismissButton: .default(Text("Continue")))
                    }
                }
                Section {
                    Text("Preview")
                    ZStack {
                        if self.coloraselectedindex != nil {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsa[self.coloraselectedindex!]), getNextColor(currentColor: self.colorsa[self.coloraselectedindex!])]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: (120 ))
                            
                        }
                        else if self.colorbselectedindex != nil {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsb[self.colorbselectedindex!]), getNextColor(currentColor: self.colorsb[self.colorbselectedindex!])]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: (120 ))
                            
                        }
                        else if self.colorcselectedindex != nil {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsc[self.colorcselectedindex!]), getNextColor(currentColor: self.colorsc[self.colorcselectedindex!])]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: (120 ))
                        }

                        VStack {
                            HStack {
                                Text(self.classnamechanged).font(.system(size: 22)).fontWeight(.bold)
                                
                                Spacer()
                                
                                if classassignmentnumber == 0 {
                                    Text("No Assignments").font(.body).fontWeight(.light)
                                }
                                    
                                else {
                                    Text(String(classassignmentnumber)).font(.title).fontWeight(.bold)
                                }
                            }
                        }.padding(.horizontal, 25)
                    }
                }
            }.navigationBarItems(trailing: Button(action: {self.EditClassPresenting = false}, label: {Text("Cancel")})).navigationBarTitle("Edit Class", displayMode: .inline)
        }
    }
    
    func getNextColor(currentColor: String) -> Color {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "one"]
        for color in colorlist {
            if (color == currentColor)
            {
                return Color(colorlist[colorlist.firstIndex(of: color)! + 1])
            }
        }
        return Color("one")
    }
}

struct DetailView: View {
    @State var EditClassPresenting = false
    @ObservedObject var classcool: Classcool
    @State private var selection: Set<Assignment> = []
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.system(size: 24)).fontWeight(.bold) .frame(maxWidth: UIScreen.main.bounds.size.width-50, alignment: .center).multilineTextAlignment(.center)
            Spacer()
            Text("Tolerance: " + String(classcool.tolerance))
            Spacer()
            
            ScrollView {
                ForEach(assignmentlist) { assignment in
                    if (self.classcool.assignmentnumber != 0 && assignment.subject == self.classcool.name && assignment.completed == false) {
                        IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: false, assignment2: assignment).shadow(radius: 10).onTapGesture {
                            self.selectDeselect(assignment)
                        }
                    }
                    }.animation(.spring())
            }
        }.navigationBarItems(trailing: Button(action: {
            self.EditClassPresenting = true
        })
        { Text("Edit").frame(height: 100, alignment: .trailing) }
        ).sheet(isPresented: $EditClassPresenting, content: {EditClassModalView(currentclassname: self.classcool.name, classnamechanged: self.classcool.name, EditClassPresenting: self.$EditClassPresenting, classtolerancedouble: Double(self.classcool.tolerance) + 0.5, classassignmentnumber: Int(self.classcool.assignmentnumber)).environment(\.managedObjectContext, self.managedObjectContext)})
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
    
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noClassesAlert = false
    @State var stored: Double = 0
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
                            let group1 = ["English A: Literature SL", "English A: Literature HL", "English A: Language and Literature SL", "English A: Language and Literatue HL"]
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
                                    newAssignment.totaltime = Int64.random(in: 2...10)*60
                                    newAssignment.subject = classname
                                    newAssignment.timeleft = Int64.random(in: 1 ... newAssignment.totaltime/60)*60
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
                                    var minutesleft = newAssignment.timeleft

                                    for j in 0 ..< newrandomint {
                                        if (minutesleft == 0) {
                                            break
                                        }
                                            
                                        else if (minutesleft == 60 || j == (newrandomint - 1)) {
                                            let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
                                            newSubassignment.assignmentname = newAssignment.name
                                            let randomDate = Double.random(in: 100000 ... 1700000)
                                            newSubassignment.startdatetime = Date(timeIntervalSinceNow: randomDate)
                                            newSubassignment.enddatetime = Date(timeIntervalSinceNow: randomDate + Double(60*minutesleft))
                                            self.stored  += 20000
                                            newSubassignment.color = newAssignment.color
                                            newSubassignment.assignmentduedate = newAssignment.duedate
                                            print(newSubassignment.assignmentduedate.description)
                                            minutesleft = 0
                                            do {
                                                try self.managedObjectContext.save()
                                                print("new Subassignment")
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                            
                                        else {
                                            let thirdrandomint = Int64.random(in: 1...2)*60
                                            let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
                                            newSubassignment.assignmentname = newAssignment.name
                                            let randomDate = Double.random(in:100000 ... 1700000)
                                            newSubassignment.startdatetime = Date(timeIntervalSinceNow: randomDate)
                                            newSubassignment.enddatetime = Date(timeIntervalSinceNow: randomDate + Double(60*thirdrandomint))
                                            self.stored += 20000
                                            newSubassignment.color = newAssignment.color
                                            newSubassignment.assignmentduedate = newAssignment.duedate
                                            print(newSubassignment.assignmentduedate.description)
                                            minutesleft -= thirdrandomint
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
                        })
                        {
                            Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                    
                        Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4)

                        Button(action: {
                            self.NewClassPresenting.toggle()
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
                            }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                        }
            }).navigationBarTitle(Text("Classes"), displayMode: .large)
        }
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)
    }
}
