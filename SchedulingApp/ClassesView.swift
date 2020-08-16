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
    @Binding var startedToDelete: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        ZStack {
            if (classcool.color != "") {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(classcool.color), getNextColor(currentColor: classcool.color)]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (120)).shadow(radius: 5)
            }

            HStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold).frame(width: classcool.assignmentnumber == 0 ? UIScreen.main.bounds.size.width/2 - 20 : UIScreen.main.bounds.size.width/2 + 40, height: 120, alignment: .leading)
                Spacer()
                if classcool.assignmentnumber == 0 && !self.startedToDelete {
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
                                        if (assignment.subject == classity.originalname) {
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
            if (color == currentColor) {
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
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
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
                    if (self.classcool.assignmentnumber != 0 && assignment.subject == self.classcool.originalname && assignment.completed == false) {
                        IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: false, assignment2: assignment).shadow(radius: 10).onTapGesture {
                            self.selectDeselect(assignment)
                        }
                    }
                    }.animation(.spring())
                if (getCompletedAssignmentNumber() > 0)
                {
                    HStack {
                        VStack {
                            Divider()
                        }
                        Text("Completed Assignments").frame(width: 200)
                        VStack {
                            Divider()
                        }
                    }.animation(.spring())
                    ForEach(assignmentlist) {
                        assignment in
                        if (self.classcool.assignmentnumber != -1 && assignment.subject == self.classcool.originalname && assignment.completed == true) {
                            IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment).shadow(radius: 10).onTapGesture {
                                self.selectDeselect(assignment)
                            }
                        }
                    }.animation(.spring())
                }
            }
        }.navigationBarItems(trailing: Button(action: {
            self.EditClassPresenting = true
        })
        { Text("Edit").frame(height: 100, alignment: .trailing) }
        ).sheet(isPresented: $EditClassPresenting, content: {EditClassModalView(currentclassname: self.classcool.name, classnamechanged: self.classcool.name, EditClassPresenting: self.$EditClassPresenting, classtolerancedouble: Double(self.classcool.tolerance) + 0.5, classassignmentnumber: Int(self.classcool.assignmentnumber)).environment(\.managedObjectContext, self.managedObjectContext)})
    }
    
    
    func getCompletedAssignmentNumber() -> Int {
        
        
        var ans: Int = 0
        for assignment in assignmentlist {
            if (assignment.subject == self.classcool.originalname && assignment.completed == true)
            {
                ans += 1
            }
        }
        return ans
    }
}

struct ClassesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
        @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])
    
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noClassesAlert = false
    @State var stored: Double = 0
    @State var noAssignmentsAlert = false
    @State var startedToDelete = false

    let types = ["Test", "Homework", "Presentation/Oral", "Essay", "Study", "Exam", "Report/Paper", "Essay", "Presentation/Oral", "Essay"]
    let duedays = [7, 2, 3, 8, 180, 14, 1, 4 , 300, 150]
    let duetimes = ["day", "day", "day", "night", "day", "day", "day", "day", "day", "day"]
    let totaltimes = [600, 90, 240, 210, 4620, 840, 120, 300, 720, 240]
    let names = ["Trigonometry Test", "Trigonometry Packet", "German Oral 2", "Othello Essay", "Physics Studying", "Final Exam", "Chemistry IA Final", "McDonalds Macroeconomics Essay", "ToK Final Presentation", "Extended Essay Final Essay"]
    let classnames = ["Math", "Math", "German", "English", "Physics" , "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let colors = ["one", "one", "two", "three" , "four", "four", "five", "six", "seven", "eight"]
    let assignmentoriginalclassnames = ["Mathematics: Analysis and Approaches SL","Mathematics: Analysis and Approaches SL","German B: SL", "English A: Language and Literature SL","Physics: HL","Physics: HL","Chemistry: HL", "Economics: HL","Theory of Knowledge",  "Extended Essay"]
    
    let bulks = [true, true, true, false, false, false, false, false]
    let classnameactual = ["Math", "German", "English", "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let originalclassnames = ["Mathematics: Analysis and Approaches SL", "German B: SL","English A: Language and Literature SL",  "Physics: HL","Chemistry: HL", "Economics: HL", "Theory of Knowledge",  "Extended Essay"]
    let tolerances = [4, 1, 2, 4, 3, 4, 1, 5]
    let assignmentnumbers = [2, 1, 1, 2, 1, 1, 1, 1]
    let classcolors = ["one", "two", "three", "four", "five", "six", "seven", "eight"]
    
    var startOfDay: Date {
        return Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0)))
        //may need to be changed to timeintervalsincenow: 0 because startOfDay automatically adds 2 hours to input date before calculating start of day
    }

    func bulk(assignment: Assignment, daystilldue: Int, totaltime: Int, bulk: Bool, dateFreeTimeDict: [Date: Int]) -> ([(Int, Int)], Int)
    {
        let safetyfraction:Double = daystilldue > 20 ? (daystilldue > 100 ? 0.95 : 0.9) : (daystilldue > 7 ? 0.75 : 1)
        var tempsubassignmentlist: [(Int, Int)] = []
        let newd = Int(ceil(Double(daystilldue)*Double(safetyfraction)))
        var totaltime = totaltime
        //let rangeoflengths = [30, 300]
        var approxlength = 0
        if (bulk) {
            for classity in classlist {
                if (classity.originalname == assignment.subject)
                {
                    for assignmenttype in assignmenttypeslist {
                        if (assignmenttype.type == assignment.type)
                        {
                            approxlength = Int(assignmenttype.rangemin + ((assignmenttype.rangemax - assignmenttype.rangemin)/5) * classity.tolerance)
                            print(approxlength)
                        }
                    }
                }
            }
            approxlength = Int(ceil(CGFloat(approxlength)/CGFloat(15))*15)
           // print(approxlength)
        }
        else {
            approxlength = max(Int(Double(totaltime)/Double(newd)), 30)
            approxlength = Int(ceil(CGFloat(approxlength)/CGFloat(15))*15)
        }
       // print(totaltime, approxlength, daystilldue)
        //possibly 0...newd or 0..<newd
        var possibledays = 0
        var possibledayslist: [Int] = []
        var notpossibledayslist: [Int] = []

        for i in 0..<newd {
            if ( dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]! >= approxlength) {
                possibledays += 1
                possibledayslist.append(i)
            }
        }
        print(totaltime, approxlength)
        let ntotal = Int(ceil(CGFloat(totaltime)/CGFloat(approxlength)))
     //   print(totaltime, approxlength)
        if (ntotal <= possibledays)
        {
            var sumsy = 0
            for i in 0..<ntotal-1 {
                tempsubassignmentlist.append((possibledayslist[i], approxlength))
                sumsy += approxlength
            }
            tempsubassignmentlist.append((possibledayslist[ntotal-1], totaltime-sumsy))
        }
        else {
            var extratime = totaltime - approxlength*possibledays
           // print(totaltime, possibledays, approxlength, extratime)
            for i in 0..<newd {
                if ( dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]! < approxlength) {
                    notpossibledayslist.append(i)
                }
            }
            //print(tempsubassignmentlist)
            //print(notpossibledayslist)
            for value in notpossibledayslist {
                //print(dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]!)
               // print(possibledays)
                //print(extratime)
                if (dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]! >= 30) // could be a different more dynamic bound
                {

                    if (extratime > dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]!) {
                        tempsubassignmentlist.append((value,dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]! ))
                       // print(dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]!)
                        extratime -= dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]!
                    }
                    else {
                        // print(extratime)

                        tempsubassignmentlist.append((value, extratime))
                        extratime = 0
                    }
                    //totaltime -= dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*value), since: startOfDay)]!
                    if (extratime == 0) {
                        break;
                    }
                }
            }
            if (extratime == 0) {
                for day in possibledayslist {
                    tempsubassignmentlist.append((day, approxlength))
                }
            }
            else{
                for day in possibledayslist {
                    tempsubassignmentlist.append((day, approxlength))
                }
                if (extratime <= 15)
                {
                    for i in 0..<tempsubassignmentlist.count {
                        if (dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*tempsubassignmentlist[i].0), since: startOfDay)]! >= tempsubassignmentlist[i].1 + extratime)
                        {
                            tempsubassignmentlist[i].1 += extratime
                            extratime = 0;
                        }
                    }
                }
                if (extratime != 0)
                {
                    print(extratime)
                    print("epic fail")
                    
                }

            }
        }
        
        return (tempsubassignmentlist, newd)
    }
    
    func master() -> Void {
            let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]

        for assignmenttype in assignmenttypes {
            let newType = AssignmentTypes(context: self.managedObjectContext)
            newType.type = assignmenttype
            newType.rangemin = 30
            newType.rangemax = 300
            print(newType.type, newType.rangemin, newType.rangemax)
            do {
                try self.managedObjectContext.save()
                print("new Subassignment")
            } catch {
                print(error.localizedDescription)


            }
        }


        for i in (0...7) {
            let newClass = Classcool(context: self.managedObjectContext)
            newClass.originalname = originalclassnames[i]
            newClass.tolerance = Int64(tolerances[i])
            newClass.name = classnameactual[i]
            newClass.assignmentnumber = 0
            newClass.color = classcolors[i]

            do {
                try self.managedObjectContext.save()
                print("Class made")
            } catch {
                print(error.localizedDescription)
            }
        }
        for i in (0...9) {
            let newAssignment = Assignment(context: self.managedObjectContext)
            newAssignment.name = String(names[i])
            newAssignment.duedate = startOfDay.addingTimeInterval(TimeInterval(86400*duedays[i]))
            if (duetimes[i] == "night")
            {
                newAssignment.duedate.addTimeInterval(79200)
            }
            else
            {
                newAssignment.duedate.addTimeInterval(28800)
            }

            newAssignment.totaltime = Int64(totaltimes[i])
            newAssignment.subject = assignmentoriginalclassnames[i]
            newAssignment.timeleft = newAssignment.totaltime
            newAssignment.progress = 0
            newAssignment.grade = 0
            newAssignment.completed = false
            newAssignment.type = types[i]

            for classity in self.classlist {
                if (classity.originalname == newAssignment.subject) {
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
        }
        print("epic success")
        
        for (index, _) in subassignmentlist.enumerated() {
             self.managedObjectContext.delete(self.subassignmentlist[index])
        }
        
        var timemonday = 0
        var timetuesday = 0
        var timewednesday = 0
        var timethursday = 0
        var timefriday = 0
        var timesaturday = 0
        var timesunday = 0
        var startoffreetimemonday = Date(timeInterval: 86300, since: startOfDay)
        var startoffreetimetuesday = Date(timeInterval: 86300, since: startOfDay)
        var startoffreetimewednesday = Date(timeInterval: 86300, since: startOfDay)
        var startoffreetimethursday = Date(timeInterval: 86300, since: startOfDay)
        var startoffreetimefriday = Date(timeInterval: 86300, since: startOfDay)
        var startoffreetimesaturday = Date(timeInterval: 86300, since: startOfDay)
        var startoffreetimesunday = Date(timeInterval: 86300, since: startOfDay)

        var monfreetimelist:[(Date, Date)] = [], tuefreetimelist:[(Date, Date)] = [], wedfreetimelist:[(Date, Date)] = [], thufreetimelist:[(Date, Date)] = [], frifreetimelist:[(Date, Date)] = [], satfreetimelist:[(Date, Date)] = [], sunfreetimelist:[(Date, Date)] = []
        var latestDate = Date(timeIntervalSinceNow: 7200)
        var dateFreeTimeDict = [Date: Int]()
        var startoffreetimeDict = [Date: Date]()
        var specificdatefreetimedict = [Date: [(Date,Date)]]()
        //initial subassignment objects are added just as (assignmentname, length of subassignment)
        var subassignmentdict = [Int: [(String, Int)]]()
        print(startOfDay.description)
        
        for freetime in freetimelist {
            if (freetime.monday) {
                timemonday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                monfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
//                print(Calendar.current.dateComponents([.minute], from: Date(timeInterval: 0, since: Calendar.current.startOfDay(for: freetime.startdatetime)), to: freetime.startdatetime).minute!, Calendar.current.dateComponents([.minute], from: Date(timeInterval: 0, since: Calendar.current.startOfDay(for: startoffreetimemonday)), to: startoffreetimemonday).minute!)
//                print(Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: Date(timeInterval: -7200, since: startoffreetimemonday))).description)
//                print(startoffreetimemonday.description)
            }
            if (freetime.tuesday) {
                timetuesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                tuefreetimelist.append((freetime.startdatetime, freetime.enddatetime))

            }
            if (freetime.wednesday) {
                timewednesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                wedfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            if (freetime.thursday) {
                timethursday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                thufreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            if (freetime.friday) {
                timefriday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                frifreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            
            if (freetime.saturday) {
                timesaturday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                satfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
            if (freetime.sunday) {
                timesunday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                sunfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
        }
        var generalfreetimelist = [timesunday, timemonday, timetuesday, timewednesday, timethursday, timefriday, timesaturday]

        var actualfreetimeslist = [sunfreetimelist, monfreetimelist, tuefreetimelist, wedfreetimelist, thufreetimelist, frifreetimelist, satfreetimelist, sunfreetimelist]
        
        for (index, element) in generalfreetimelist.enumerated() {
            if (element % 5 == 4) {
                generalfreetimelist[index] += 1
            }
        //    print(generalfreetimelist[index])
        }
        

        
        for assignment in assignmentlist {
            latestDate = max(latestDate, assignment.duedate)
        }
        
        let daystilllatestdate = Calendar.current.dateComponents([.day], from: Date(timeIntervalSinceNow: 7200), to: latestDate).day!
        
        for i in 0...daystilllatestdate {
            subassignmentdict[i] = []
            dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = generalfreetimelist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
//            startoffreetimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = startoffreetimelist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
            specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = actualfreetimeslist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
            //print( Date(timeInterval: TimeInterval(86400*i), since: startOfDay).description, dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]! )
        }
    
        for freetime in freetimelist {
            if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday)
            {
                dateFreeTimeDict[Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: freetime.startdatetime))]! += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                
                if ( Calendar.current.dateComponents([.minute], from: Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: freetime.startdatetime)), to: freetime.startdatetime).minute! < Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: startoffreetimeDict[Calendar.current.startOfDay(for: freetime.startdatetime)]!), to: startoffreetimeDict[Calendar.current.startOfDay(for: freetime.startdatetime)]!).minute!)
                 {
                    startoffreetimeDict[Calendar.current.startOfDay(for: freetime.startdatetime)] = freetime.startdatetime
                 }
            }
        }
//        for i in 0...daystilllatestdate {
//
//         //   print( Date(timeInterval: TimeInterval(86400*i), since: startOfDay).description, dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]! ,startoffreetimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]?.description )
//
//        }
        for assignment in assignmentlist {

                let daystilldue = Calendar.current.dateComponents([.day], from: Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0))), to:  Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: Date(timeInterval: -7200, since: assignment.duedate)))).day!
                //print(Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 7200))).description, Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: assignment.duedate)), daystilldue)
               // print(daystilldue)
                
                //print(daystilldue)

                let (subassignments, _) = bulk(assignment: assignment, daystilldue: daystilldue, totaltime: Int(assignment.totaltime), bulk: true, dateFreeTimeDict: dateFreeTimeDict)

                print(assignment.name, daystilldue)
               // print(daystilldue)
                for (daysfromnow, lengthofwork) in subassignments {
                    dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*daysfromnow), since: startOfDay)]! -= lengthofwork
                    subassignmentdict[daysfromnow]!.append((assignment.name, lengthofwork))
                    print(daysfromnow, lengthofwork)
                }
        }
        for i in 0...daystilllatestdate {
            if (subassignmentdict[i]!.count > 0)
            {
               // print(i)
                for (name, length) in subassignmentdict[i]!
                {
                   //print(name, length)
                }
            }
        }

    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.classlist) { classcool in
                    NavigationLink(destination: DetailView(classcool: classcool )) {
                        ClassView(classcool: classcool, startedToDelete: self.$startedToDelete)
                    }
                }.onDelete { indexSet in
                    self.startedToDelete = true
                    
                    for index in indexSet {
                        for (index2, element) in self.assignmentlist.enumerated() {
                            if (element.subject == self.classlist[index].originalname) {
                                for (index3, element2) in self.subassignmentlist.enumerated() {
                                    if (element2.assignmentname == element.name) {
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
                    
                    self.startedToDelete = false
                }
            }.navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 3.7) {
                        Button(action: {
                            
                             self.master()
                          //  MasterStruct().master()
//                            let group1 = ["English A: Literature SL", "English A: Literature HL", "English A: Language and Literature SL", "English A: Language and Literatue HL"]
//                            let group2 = ["German B: SL", "German B: HL", "French B: SL", "French B: HL", "German A: Literature SL", "German A: Literature HL", "German A: Language and Literatue SL", "German A: Language and Literatue HL","French A: Literature SL", "French A: Literature HL", "French A: Language and Literatue SL", "French A: Language and Literatue HL" ]
//                            let group3 = ["Geography: SL", "Geography: HL", "History: SL", "History: HL", "Economics: SL", "Economics: HL", "Psychology: SL", "Psychology: HL", "Global Politics: SL", "Global Politics: HL"]
//                            let group4 = ["Biology: SL", "Biology: HL", "Chemistry: SL", "Chemistry: HL", "Physics: SL", "Physics: HL", "Computer Science: SL", "Computer Science: HL", "Design Technology: SL", "Design Technology: HL", "Environmental Systems and Societies: SL", "Sport Science: SL", "Sport Science: HL"]
//                            let group5 = ["Mathematics: Analysis and Approaches SL", "Mathematics: Analysis and Approaches HL", "Mathematics: Applications and Interpretation SL", "Mathematics: Applications and Interpretation HL"]
//                            let group6 = ["Music: SL", "Music: HL", "Visual Arts: SL", "Visual Arts: HL", "Theatre: SL" , "Theatre: HL" ]
//                            let extendedessay = "Extended Essay"
//                            let tok = "Theory of Knowledge"
//                            let classnames = [group1.randomElement()!, group2.randomElement()!, group3.randomElement()!, group4.randomElement()!, group5.randomElement()!, group6.randomElement()!, extendedessay, tok ]
//                               let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
//
//                            for assignmenttype in assignmenttypes {
//                                let newType = AssignmentTypes(context: self.managedObjectContext)
//                                newType.type = assignmenttype
//                                newType.rangemin = 30
//                                newType.rangemax = 300
//                                print(newType.type, newType.rangemin, newType.rangemax)
//                                do {
//                                    try self.managedObjectContext.save()
//                                    print("new Subassignment")
//                                } catch {
//                                    print(error.localizedDescription)
//
//
//                                }
//                            }
//                            for classname in classnames {
//                                let newClass = Classcool(context: self.managedObjectContext)
//                                newClass.originalname = classname
//                                newClass.tolerance = Int64.random(in: 0 ... 10)
//                                newClass.name = classname
//                                newClass.assignmentnumber = 0
//                                newClass.color = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].randomElement()!
//
//                                do {
//                                    try self.managedObjectContext.save()
//                                    print("Class made")
//                                } catch {
//                                    print(error.localizedDescription)
//                                }
//                            }
//
//                            for classname in classnames {
//                                let randomint = Int.random(in: 1...10)
//                                for i in 0 ..< randomint {
//                                    let newAssignment = Assignment(context: self.managedObjectContext)
//                                    newAssignment.name = classname + " assignment " + String(i)
//                                    newAssignment.duedate = Date(timeIntervalSinceNow: Double.random(in: 100000 ... 1000000))
//                                    newAssignment.totaltime = Int64.random(in: 2...10)*60
//                                    newAssignment.subject = classname
//                                    newAssignment.timeleft = Int64.random(in: 1 ... newAssignment.totaltime/60)*60
//                                    newAssignment.progress = Int64((Double(newAssignment.totaltime - newAssignment.timeleft)/Double(newAssignment.totaltime)) * 100)
//                                    newAssignment.grade = Int64.random(in: 1...7)
//                                    newAssignment.completed = false
//                                    newAssignment.type = assignmenttypes.randomElement()!
//
//                                    for classity in self.classlist {
//                                        if (classity.name == newAssignment.subject) {
//                                            classity.assignmentnumber += 1
//                                            newAssignment.color = classity.color
//                                            do {
//                                                try self.managedObjectContext.save()
//                                                print("Class number changed")
//                                            } catch {
//                                                print(error.localizedDescription)
//                                            }
//                                        }
//                                    }
//
//                                    let newrandomint = Int.random(in: 2...5)
//                                    var minutesleft = newAssignment.timeleft
//
//                                    for j in 0 ..< newrandomint {
//                                        if (minutesleft == 0) {
//                                            break
//                                        }
//
//                                        else if (minutesleft == 60 || j == (newrandomint - 1)) {
//                                            let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
//                                            newSubassignment.assignmentname = newAssignment.name
//                                            let randomDate = Double.random(in: 10000 ... 1700000)
//                                            newSubassignment.startdatetime = Date(timeIntervalSinceNow: randomDate)
//                                            newSubassignment.enddatetime = Date(timeIntervalSinceNow: randomDate + Double(60*minutesleft))
//                                            self.stored  += 20000
//                                            newSubassignment.color = newAssignment.color
//                                            newSubassignment.assignmentduedate = newAssignment.duedate
//                                            print(newSubassignment.assignmentduedate.description)
//                                            minutesleft = 0
//                                            do {
//                                                try self.managedObjectContext.save()
//                                                print("new Subassignment")
//                                            } catch {
//                                                print(error.localizedDescription)
//                                            }
//                                        }
//
//                                        else {
//                                            let thirdrandomint = Int64.random(in: 1...2)*60
//                                            let newSubassignment = Subassignmentnew(context: self.managedObjectContext)
//                                            newSubassignment.assignmentname = newAssignment.name
//                                            let randomDate = Double.random(in:10000 ... 1700000)
//                                            newSubassignment.startdatetime = Date(timeIntervalSinceNow: randomDate)
//                                            newSubassignment.enddatetime = Date(timeIntervalSinceNow: randomDate + Double(60*thirdrandomint))
//                                            self.stored += 20000
//                                            newSubassignment.color = newAssignment.color
//                                            newSubassignment.assignmentduedate = newAssignment.duedate
//                                            print(newSubassignment.assignmentduedate.description)
//                                            minutesleft -= thirdrandomint
//                                            do {
//                                                try self.managedObjectContext.save()
//                                                print("new Subassignment")
//                                            } catch {
//                                                print(error.localizedDescription)
//                                            }
//                                        }
//                                    }
//
//                                    do {
//                                        try self.managedObjectContext.save()
//                                        print("Class made")
//                                    } catch {
//                                        print(error.localizedDescription)
//                                    }
//                                }
//                            }
                        })
                        {
                            Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                    
                        Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 5)

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
                            Button(action: {self.getcompletedAssignments() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()}) {
                                Text("Grade")
                                Image(systemName: "percent")
                            }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noAssignmentsAlert) {
                                Alert(title: Text("No Assignments Added"), message: Text("Add an Assignment First"))
                            }
                        }
            }).navigationBarTitle(Text("Classes"), displayMode: .large)
        }
    }
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0)
            {
                return true;
            }
        }
        return false
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)
    }
}
