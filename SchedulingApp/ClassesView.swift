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
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    var body: some View {
        ZStack {
            if (classcool.color != "") {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [getcurrentolor(currentColor: classcool.color), getNextColor(currentColor: classcool.color)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    //.fill(getcurrentolor(currentColor: classcool.color))
                    .frame(width: UIScreen.main.bounds.size.width - 20, height: (120)).shadow(radius: 5)
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
            }.padding(.horizontal, 40)
        }
    }
    func getcurrentolor(currentColor: String) -> Color {
        return Color(currentColor)
    }
    func getNextColor(currentColor: String) -> Color {

        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "one"]
        let existinggradients = ["one", "two", "three", "five", "six", "eleven","thirteen", "fourteen", "fifteen"]
        if (existinggradients.contains(currentColor))
        {
            return Color(currentColor + "-b")
        }
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
    
    @Binding var showeditclass: Bool
    @State var currentclassname: String
    @State var classnamechanged: String
    @Binding var EditClassPresenting: Bool
    @State var classtolerancedouble: Double
    @State var classassignmentnumber: Int
    
    let colorsa = ["one", "two", "three", "four", "five"]
    let colorsb = ["six", "seven", "eight", "nine", "ten"]
    let colorsc = ["eleven", "twelve", "thirteen", "fourteen", "fifteen"]
    
    @State private var coloraselectedindex: Int
    @State private var colorbselectedindex: Int
    @State private var colorcselectedindex: Int
    
    @State private var createclassallowed = true
    @State private var showingAlert = false
    
    init(showeditclass: Binding<Bool>, currentclassname: String, classnamechanged: String, EditClassPresenting: Binding<Bool>, classtolerancedouble: Double, classassignmentnumber: Int, classcolor: String)
    {
        self._showeditclass = showeditclass
        self._currentclassname = State(initialValue: currentclassname)
        self._classnamechanged = State(initialValue: classnamechanged)
        self._EditClassPresenting = EditClassPresenting
        self._classtolerancedouble = State(initialValue: classtolerancedouble)
        self._classassignmentnumber = State(initialValue: classassignmentnumber)
        
        self._coloraselectedindex = State(initialValue: -1)
        self._colorbselectedindex = State(initialValue: -1)
        self._colorcselectedindex = State(initialValue: -1)
        if (colorsa.contains(classcolor))
        {
            self._coloraselectedindex = State(initialValue: colorsa.firstIndex(of: classcolor)!)

            //print(1)
        }
        else if (colorsb.contains(classcolor))
        {
            self._colorbselectedindex = State(initialValue: colorsb.firstIndex(of: classcolor)!)

           // print(colorsb.firstIndex(of: classcolor)!)
            //print(2)
        }
        else
        {
            self._colorcselectedindex = State(initialValue: colorsc.firstIndex(of: classcolor)!)

           // print(3)
        }
        //print(coloraselectedindex!, colorbselectedindex!, colorcselectedindex!)
        print(classcolor)
        
    }
    

    
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
                        Slider(value: $classtolerancedouble, in: 1...5)
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
                                        self.colorbselectedindex = -1
                                        self.colorcselectedindex = -1
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
                                        self.coloraselectedindex = -1
                                        self.colorbselectedindex = colorindexb
                                        self.colorcselectedindex = -1
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
                                        self.coloraselectedindex = -1
                                        self.colorbselectedindex = -1
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
                                    if self.coloraselectedindex != -1 {
                                        classity.color = self.colorsa[self.coloraselectedindex]
                                    }
                                    else if self.colorbselectedindex != -1 {
                                        classity.color = self.colorsb[self.colorbselectedindex]
                                    }
                                    else if self.colorcselectedindex != -1 {
                                        classity.color = self.colorsc[self.colorcselectedindex]
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
                            self.showeditclass = false
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
                        if self.coloraselectedindex != -1 {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsa[self.coloraselectedindex]), getNextColor(currentColor: self.colorsa[self.coloraselectedindex])]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.size.width - 80, height: (120 ))
                            
                        }
                        else if self.colorbselectedindex != -1 {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsb[self.colorbselectedindex]), getNextColor(currentColor: self.colorsb[self.colorbselectedindex])]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.size.width - 80, height: (120 ))
                            
                        }
                        else if self.colorcselectedindex != -1 {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(self.colorsc[self.colorcselectedindex]), getNextColor(currentColor: self.colorsc[self.colorcselectedindex])]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: UIScreen.main.bounds.size.width - 80, height: (120 ))
                            
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
            }.navigationBarItems(trailing: Button(action: {
                                                    self.showeditclass = false
                                                    self.EditClassPresenting = false
                
            }, label: {Text("Cancel")})).navigationBarTitle("Edit Class", displayMode: .inline)
        }
    }
    
    func getNextColor(currentColor: String) -> Color {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "one"]
        let existinggradients = ["one", "two", "three", "five", "six", "eleven","thirteen", "fourteen", "fifteen"]
        if (existinggradients.contains(currentColor))
        {
            return Color(currentColor + "-b")
        }
        for color in colorlist {
            if (color == currentColor)
            {
                return Color(colorlist[colorlist.firstIndex(of: color)! + 1])
            }
        }
        return Color("one")
    }
}
class SheetNavigatorEditClass: ObservableObject {
    @Published var showeditclass: Bool = false
    @Published var selectededitassignment: String = ""
}
struct DetailView: View {
    @State var EditClassPresenting = false
    @ObservedObject var classcool: Classcool
    @State private var selection: Set<Assignment> = []
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @State var NewAssignmentPresenting: Bool = false
    @State var noClassesAlert: Bool = false
    @State var scalevalue: CGFloat = 1
    @State private var ocolor = Color.blue
    @State var showeditassignment: Bool = false
    @State var selectededitassignment: String = ""
    @State var NewSheetPresenting: Bool = false
    @ObservedObject var sheetnavigator: SheetNavigatorEditClass = SheetNavigatorEditClass()
    
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    func getclassindex(classcool: Classcool) -> Int {
        for (index, element) in classlist.enumerated()
        {
            if (element == classcool)
            {
                return index
            }
        }
        return 0
    }
    
    func getassignmentindex() -> Int {
        for (index, assignment) in assignmentlist.enumerated() {
            if (assignment.name == sheetnavigator.selectededitassignment)
            {
                return index
            }
        }
        return 0
    }
    
    
    @ViewBuilder
    private func sheetContent() -> some View {
        
        if (!self.sheetnavigator.showeditclass)
        {
            EditAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext)
            
        }
        else
        {
            EditClassModalView(showeditclass: self.$sheetnavigator.showeditclass , currentclassname: self.classcool.name, classnamechanged: self.classcool.name, EditClassPresenting: self.$NewSheetPresenting, classtolerancedouble: Double(self.classcool.tolerance) + 0.5, classassignmentnumber: Int(self.classcool.assignmentnumber), classcolor: self.classcool.color).environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
    var body: some View {
        ZStack {
            VStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold) .frame(maxWidth: UIScreen.main.bounds.size.width-50, alignment: .center).multilineTextAlignment(.center)
                Spacer()
                Text("Tolerance: " + String(classcool.tolerance))
                Spacer()
                
                ScrollView {
                    ForEach(assignmentlist) { assignment in
                        if (self.classcool.assignmentnumber != 0 && assignment.subject == self.classcool.originalname && assignment.completed == false) {
                            IndividualAssignmentFilterView(isExpanded2: self.selection.contains(assignment), isCompleted2: false, assignment2: assignment, selectededit: self.$sheetnavigator.selectededitassignment, showedit: self.$NewSheetPresenting).shadow(radius: 10).onTapGesture {
                                self.selectDeselect(assignment)
                            }
                        }
                    }.sheet(isPresented: $showeditassignment, content: {
                        EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext)}).animation(.spring())
                    if (!getexistingassignments())
                    {
                        Spacer().frame(height: 100)
                        Image("emptyassignment").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)//.frame(width: UIScreen.main.bounds.size.width, alignment: .center)//.offset(x: -20)
                        Text("No Assignments").font(.system(size: 40)).frame(width: UIScreen.main.bounds.size.width - 40, height: 100, alignment: .center).multilineTextAlignment(.center)
                        
                    }
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
                                GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment, selectededit: self.$sheetnavigator.selectededitassignment, showedit: self.$NewSheetPresenting).shadow(radius: 10).onTapGesture {
                                    self.selectDeselect(assignment)
                                }
                            }
                        }
//                        .sheet(isPresented: $showeditassignment, content: {
//                            EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext)}).animation(.spring())
                    }
                }
            }.navigationBarItems(trailing: Button(action: {
                self.NewSheetPresenting = true
                sheetnavigator.showeditclass.toggle()
                
            })
            { Text("Edit").frame(height: 100, alignment: .trailing) }
            ).sheet(isPresented: $NewSheetPresenting, content: sheetContent)
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
//                        self.scalevalue = self.scalevalue == 1.5 ? 1 : 1.5
//                        self.ocolor = self.ocolor == Color.blue ? Color.green : Color.blue
                        
                    }) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).scaleEffect(self.scalevalue).padding(20).overlay(
                            ZStack {
                                //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30).scaleEffect(self.scalevalue)
                            }
                        ).shadow(radius: 50)
                    }.animation(.spring()).sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: self.getclassindex(classcool: self.classcool), preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noClassesAlert) {
                        Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                    }
                }
            }
        }
    }
    
    func getexistingassignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname)
            {
                return true
            }
        }
        return false
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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
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
    @State var NewAssignmentPresenting2 = false
    @State var stored: Double = 0
    @State var noAssignmentsAlert = false
    @State var startedToDelete = false
    @State var showingSettingsView = false
    
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
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    var startOfDay: Date {
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        
        return Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0)))
        //may need to be changed to timeintervalsincenow: 0 because startOfDay automatically adds 2 hours to input date before calculating start of day
    }
        func schedulenotifications() {
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
           
            let calendar = Calendar.current
            
            let times = [0, 5, 10, 15, 30]

            // show this notification five seconds from now
         //   print(subassignmentlist.count)
            let defaults = UserDefaults.standard
            let array = defaults.object(forKey: "savedassignmentnotifications") as? [String] ?? ["None"]
            let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
            //let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
            let beforeassignmenttimes = ["At Start", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]


            var listofnotifications: [DateComponents] = []
            for subassignment in subassignmentlist {
                for (index, val) in beforeassignmenttimes.enumerated() {
                    if (array.contains(val))
                    {
                        let content = UNMutableNotificationContent()
                        if (index == 0)
                        {
                            content.title = "Task starting now: "
                        }
                        else{
                            
                            content.title = "Upcoming Task " + "in " + String(times[index]) + " minutes: "
                        }
                        
                           content.body = subassignment.assignmentname
                           content.sound = UNNotificationSound.default

                        let datevalue = Date(timeInterval: TimeInterval(-1*times[index]*60), since: subassignment.startdatetime)
                            let components = calendar.dateComponents([Calendar.Component.minute,Calendar.Component.hour,Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: datevalue)
                            listofnotifications.append(components)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                            // choose a random identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                            // add our notification request
                            UNUserNotificationCenter.current().add(request)

                    }
                        if (array2.contains(val))
                        {
                            let content = UNMutableNotificationContent()
                               content.title = "Task Ending " + "in " + String(times[index]) + " minutes: "
                                  content.body = subassignment.assignmentname
                               content.sound = UNNotificationSound.default

                            let datevalue = Date(timeInterval: TimeInterval(-1*times[index]*60), since: subassignment.enddatetime)
                                let components = calendar.dateComponents([Calendar.Component.minute,Calendar.Component.hour,Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: datevalue)
                            listofnotifications.append(components)
                                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                                // choose a random identifier
                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                                // add our notification request
                                UNUserNotificationCenter.current().add(request)

                        }

                }


            }
//            print(listofnotifications)
//            var datelist: [Date] = []
//            for value in listofnotifications {
//                let date = calendar.date(from: value)!
//                datelist.append(date)
//            }
//            datelist.sort()
//            print("")
//            print(datelist)
//            let content2 = UNMutableNotificationContent()
//            content2.title = "Upcoming Task " + "in " + String(times[1]) + " minutes: "
//               content2.body = subassignmentlist[0].assignmentname
//        //    content2.body = "Text"
//               content2.sound = UNNotificationSound.default
//
//                let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//                // choose a random identifier
//                let request2 = UNNotificationRequest(identifier: UUID().uuidString, content: content2, trigger: trigger2)
//
//                // add our notification request
//                UNUserNotificationCenter.current().add(request2)
            print("success")

            
        }
    func bulk(assignment: Assignment, daystilldue: Int, totaltime: Int, bulk: Bool, dateFreeTimeDict: [Date: Int]) -> ([(Int, Int)], Int)
    {
        let safetyfraction:Double = daystilldue > 20 ? (daystilldue > 100 ? 0.95 : 0.9) : (daystilldue > 7 ? 0.75 : 1)
        var tempsubassignmentlist: [(Int, Int)] = []
        let newd = Int(ceil(Double(daystilldue)*Double(safetyfraction)))
        let totaltime = totaltime
        //let rangeoflengths = [30, 300]
      //  print(assignment.name)
     //   print(newd, daystilldue)
        var approxlength = 0
        if (bulk) {
            for classity in classlist {
                if (classity.originalname == assignment.subject)
                {
                    for assignmenttype in assignmenttypeslist {
                        if (assignmenttype.type == assignment.type)
                        {
                            approxlength = Int(assignmenttype.rangemin + ((assignmenttype.rangemax - assignmenttype.rangemin)/5) * classity.tolerance)
                          //  print(approxlength)
                        }
                    }
                }
            }
        //    print(approxlength)
            approxlength = Int(ceil(CGFloat(approxlength)/CGFloat(5))*5)
    //        print(approxlength)
           // print(approxlength)
            //check if doable in totaltime and newd assuming 1 subassignment per day
        }
        
        if (Int(ceil(CGFloat(CGFloat(totaltime)/CGFloat(newd))/CGFloat(5))*5) > approxlength)
        {
            approxlength = Int(ceil(CGFloat(CGFloat(totaltime)/CGFloat(newd))/CGFloat(5))*5)
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
      //  print(totaltime, approxlength)
        let ntotal = Int(ceil(CGFloat(totaltime)/CGFloat(approxlength)))
     //   print(totaltime, approxlength)
        if (ntotal <= possibledays)
        {
            
            if (ntotal == possibledays)
            {
                print("exact number of days")
                var sumsy = 0
                for i in 0..<ntotal-1 {
                    tempsubassignmentlist.append((possibledayslist[i], approxlength))
                    sumsy += approxlength
                }
                tempsubassignmentlist.append((possibledayslist[ntotal-1], totaltime-sumsy))
            }
            else
            {
                print("too many days")
                let breaks = possibledays-ntotal
                //print("Breaks: " + String(possibledays-ntotal))
             //   print("Required Days: " + String(ntotal))
               // print("Possible Days: " + String(possibledays))
                var groupslist: [Int] = []
                for _ in 0..<breaks {
                    groupslist.append(ntotal/breaks)
                }
                for i in 0..<(ntotal%breaks)
                {
                    groupslist[i] += 1
                }
                var counter = 0
                var sumsy = 0
                for (_, val) in groupslist.enumerated() {
                    for _ in 0..<val {
                        tempsubassignmentlist.append((possibledayslist[counter], approxlength))
                        sumsy += approxlength
                        counter += 1
                    }
                    counter += 1
                }
                tempsubassignmentlist[tempsubassignmentlist.count-1].1 -= (sumsy-totaltime)
            }
        }
        else {
            print("not enought time")
            var extratime = totaltime - approxlength*possibledays
            print(totaltime, possibledays, approxlength, extratime, newd)
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
                else
                {
                    for i in 0..<possibledayslist.count {
                        for j in 0..<tempsubassignmentlist.count {
                            if (tempsubassignmentlist[j].0 == possibledayslist[i])
                            {
                                print("kewl")
                                let value = min(extratime, dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*tempsubassignmentlist[j].0), since: startOfDay)]! - tempsubassignmentlist[j].1, 90 )
                                print(value)
                                tempsubassignmentlist[j].1 += value
                                extratime -= value
                                if (extratime == 0)
                                {
                                    break
                                }
                            }
                            
                        }
                        if (extratime == 0)
                        {
                            break
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
        for (daysfromnow, lengthofwork) in tempsubassignmentlist {
            print(daysfromnow, lengthofwork)
        }
        return (tempsubassignmentlist, newd)
    }

    
    func master() -> Void {
            let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]

//        for assignmenttype in assignmenttypes {
//            let newType = AssignmentTypes(context: self.managedObjectContext)
//            newType.type = assignmenttype
//            newType.rangemin = 30
//            newType.rangemax = 300
//            print(newType.type, newType.rangemin, newType.rangemax)
//            do {
//                try self.managedObjectContext.save()
//                print("new Subassignment")
//            } catch {
//                print(error.localizedDescription)
//
//
//            }
//        }


        for i in (0...7) {
            let newClass = Classcool(context: self.managedObjectContext)
            newClass.originalname = originalclassnames[i]
            newClass.tolerance = Int64(tolerances[i])
            newClass.name = classnameactual[i]
            newClass.assignmentnumber = 0
            newClass.color = classcolors[i]
          //  newClass.isarchived = false

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
      //  print("epic success")
        
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
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)
        _ = Date(timeInterval: 86300, since: startOfDay)

        var monfreetimelist:[(Date, Date)] = [], tuefreetimelist:[(Date, Date)] = [], wedfreetimelist:[(Date, Date)] = [], thufreetimelist:[(Date, Date)] = [], frifreetimelist:[(Date, Date)] = [], satfreetimelist:[(Date, Date)] = [], sunfreetimelist:[(Date, Date)] = []
        
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        
        var latestDate = Date(timeIntervalSinceNow: TimeInterval(0))
        var dateFreeTimeDict = [Date: Int]()
        var startoffreetimeDict = [Date: Date]()
        var specificdatefreetimedict = [Date: [(Date,Date)]]()
        //initial subassignment objects are added just as (assignmentname, length of subassignment)
        var subassignmentdict = [Int: [(String, Int)]]()
       // print(startOfDay.description)
        
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
              //  print( Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!, freetime.startdatetime.description)
                timesunday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                sunfreetimelist.append((freetime.startdatetime, freetime.enddatetime))
            }
        }
       // print("Time Sunday: " + String(timesunday))//
        var generalfreetimelist = [timesunday, timemonday, timetuesday, timewednesday, timethursday, timefriday, timesaturday]

        let actualfreetimeslist = [sunfreetimelist, monfreetimelist, tuefreetimelist, wedfreetimelist, thufreetimelist, frifreetimelist, satfreetimelist, sunfreetimelist]
     //   print(generalfreetimelist)
        for (index, element) in generalfreetimelist.enumerated() {
                generalfreetimelist[index] = Int(Double(generalfreetimelist[index])/Double(5) * 5)
                
        //    print(generalfreetimelist[index])
        }
     //   print(generalfreetimelist)
        

        
        for assignment in assignmentlist {
            latestDate = max(latestDate, assignment.duedate)
        }
        
        let daystilllatestdate = Calendar.current.dateComponents([.day], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: latestDate).day!
        
        for i in 0...daystilllatestdate {
            subassignmentdict[i] = []
            dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = generalfreetimelist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
//            startoffreetimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = startoffreetimelist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
            specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = actualfreetimeslist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
            //print( Date(timeInterval: TimeInterval(86400*i), since: startOfDay).description, dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]! )
           // print(dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)])
        }
    
        for freetime in freetimelist {
            if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday) {
                dateFreeTimeDict[Date(timeInterval: TimeInterval(timezoneOffset), since: Calendar.current.startOfDay(for: freetime.startdatetime))]! += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
                
                if ( Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(timezoneOffset), since: Calendar.current.startOfDay(for: freetime.startdatetime)), to: freetime.startdatetime).minute! < Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: startoffreetimeDict[Calendar.current.startOfDay(for: freetime.startdatetime)]!), to: startoffreetimeDict[Calendar.current.startOfDay(for: freetime.startdatetime)]!).minute!)
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
            let daystilldue = Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 0))), to:  Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: Date(timeInterval: 0, since: assignment.duedate)))).day!
                //print(Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 7200))).description, Date(timeInterval: 7200, since: Calendar.current.startOfDay(for: assignment.duedate)), daystilldue)
               // print(daystilldue)
                
                //print(daystilldue)
            print(assignment.name)
                let (subassignments, _) = bulk(assignment: assignment, daystilldue: daystilldue, totaltime: Int(assignment.timeleft), bulk: true, dateFreeTimeDict: dateFreeTimeDict)

             //   print(assignment.name, daystilldue)
               // print(daystilldue)
            
                for (daysfromnow, lengthofwork) in subassignments {
                    dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*daysfromnow), since: startOfDay)]! -= lengthofwork
                    subassignmentdict[daysfromnow]!.append((assignment.name, lengthofwork))
                 //   print(daysfromnow, lengthofwork)
                }
        }
        for i in 0...daystilllatestdate {
            if (subassignmentdict[i]!.count > 0)
            {
                
                if (specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]!.count == 1)
                {
                   // print("Days from now: " + String(i))
                    let startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].0)), to:  specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].0).minute!*60), since: Date(timeInterval: TimeInterval(86400*i), since: startOfDay))
                   // let startime = specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].0
                 //   print("Start time: " + startime.description)
                    var timeoffset = 0
                    for (name, lengthofwork) in subassignmentdict[i]! {
                        let newSubassignment4 = Subassignmentnew(context: self.managedObjectContext)
                           newSubassignment4.assignmentname = name
                        for assignment in assignmentlist {
                            if (assignment.name == name)
                            {
                                newSubassignment4.color = assignment.color
                                newSubassignment4.assignmentduedate = assignment.duedate
                            }
                        }
                         //  let randomDate = Double.random(in: 10000 ... 1700000)
                        newSubassignment4.startdatetime = Date(timeInterval:     TimeInterval(timeoffset), since: startime)
                      //  print(newSubassignment4.startdatetime.description)
                        newSubassignment4.enddatetime = Date(timeInterval: TimeInterval(timeoffset+lengthofwork*60), since: startime)
                        timeoffset += lengthofwork*60
                        do {
                            try self.managedObjectContext.save()
                           // print("Subassignments made")
                        } catch {
                         //å   print(error.localizedDescription)
                        }
                           
                    }
                }
                else
                {
                    var startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].0)), to:  specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].0).minute!*60), since: Date(timeInterval: TimeInterval(86400*i), since: startOfDay))
                    var endtime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].1)), to:  specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![0].1).minute!*60), since: Date(timeInterval: TimeInterval(86400*i), since: startOfDay))
                    var counter = 1
                    var timeoffset = 0
                    for (name, lengthofwork) in subassignmentdict[i]! {
                        var lengthofwork2 = lengthofwork
                        while (lengthofwork2 > 0)
                        {
                            let newSubassignment4 = Subassignmentnew(context: self.managedObjectContext)
                               newSubassignment4.assignmentname = name
                            for assignment in assignmentlist {
                                if (assignment.name == name)
                                {
                                    newSubassignment4.color = assignment.color
                                    newSubassignment4.assignmentduedate = assignment.duedate
                                }
                            }

                            newSubassignment4.startdatetime = Date(timeInterval: TimeInterval(timeoffset), since: startime)
                            if (Date(timeInterval: TimeInterval(timeoffset+lengthofwork2*60), since: startime) > endtime)
                            {
                                newSubassignment4.enddatetime = endtime
                                var subtractionval = Calendar.current.dateComponents([.minute], from:Date(timeInterval: TimeInterval(timeoffset), since: startime), to:  endtime).minute!
                                if (subtractionval % 5 == 4)
                                {
                                    subtractionval += 1
                                }
                                if (subtractionval % 5 == 1)
                                {
                                    subtractionval -= 1
                                }
                                lengthofwork2 -= subtractionval
                                timeoffset = 0
                                startime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![counter].0)), to:  specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![counter].0).minute!*60), since: Date(timeInterval: TimeInterval(86400*i), since: startOfDay))
                                endtime = Date(timeInterval: TimeInterval(Calendar.current.dateComponents([.minute], from: Date(timeInterval: TimeInterval(0), since: Calendar.current.startOfDay(for: specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![counter].1)), to:  specificdatefreetimedict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)]![counter].1).minute!*60), since: Date(timeInterval: TimeInterval(86400*i), since: startOfDay))
                                counter += 1
                            }
                            else
                            {
                                newSubassignment4.enddatetime = Date(timeInterval: TimeInterval(timeoffset+lengthofwork2*60), since: startime)
                                timeoffset += lengthofwork2*60
                                lengthofwork2 = 0
                            }
                           
                            do {
                                try self.managedObjectContext.save()
                                print("Subassignments made")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
        

    }
    
    func getclassindex(classcool: Classcool) -> Int {
        for (index, element) in classlist.enumerated()
        {
            if (element == classcool)
            {
                return index
            }
        }
        return 0
    }
    func getnumofclasses() -> Bool {
        var count = 0
        for clasity in classlist {
            count += 1
        }
        if (count > 0)
        {
            return true
        }
        return false
    }
    func getactualclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index
            }
        }
        return 0
    }
    func getclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index+1
            }
        }
        return 0
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        
        if (self.sheetNavigator.modalView == .freetime)
        {
            
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
            NewAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .classity)
        {
            NewClassModalView(NewClassPresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .grade)
        {
            NewGradeModalView(NewGradePresenting: self.$NewSheetPresenting, classfilter: -1).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else
        {
            Button(action: {
                print(self.modalView)
            }) {
                Text("click me")
            }
        }
    }
    @State var selectedClass: Int? = 0
    @State var storedindex = 0
    @State var opacityvalue = 1.0
    @State var deletedclassindex = -1
    @ObservedObject var sheetnavigator: SheetNavigatorClassesView = SheetNavigatorClassesView()
    @ObservedObject var classdeleter: ClassDeleter = ClassDeleter()
    
    var body: some View {
        NavigationView {
            VStack {
            HStack {
                Text("Classes").font(.largeTitle).bold().frame(height:40)
                Spacer()
            }.padding(.all, 10).padding(.top, -60).padding(.leading, 10)
            ZStack {
                NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                 { EmptyView() }
                ScrollView {
                    if (getnumofclasses())
                    {
                        ForEach(self.classlist) { classcool in
                        //    if (!classcool.isarchived)
                          //  {
                                
                                
                                NavigationLink(destination: DetailView(classcool: classcool), tag: self.getclassnumber(classcool: classcool), selection: self.$selectedClass) {
                                    EmptyView()
                                }
                                Button(action: {
                                    self.selectedClass = self.getclassnumber(classcool: classcool)
                                }) {
                                    ClassView(classcool: classcool, startedToDelete: self.$startedToDelete).padding(.vertical, 10)

                                }.buttonStyle(PlainButtonStyle()).contextMenu {
                                    Button (action: {

                                        self.sheetnavigator.storedindex = self.getactualclassnumber(classcool: classcool)
                                        NewAssignmentPresenting2.toggle()
                                    }) {
                                        HStack {
                                            Text("Add Assignment")
                                            Spacer()
                                            Image(systemName: "paperclip")
                                        }
                                    }
                                    Divider()
                                    Button(action: {
                                        self.classdeleter.isdeleting = true
                                        deletedclassindex = getactualclassnumber(classcool: classcool)
                                        for (_, element) in self.assignmentlist.enumerated() {
                                                if (element.subject == self.classlist[deletedclassindex].originalname) {
                                                    for (index3, element2) in self.subassignmentlist.enumerated() {
                                                        if (element2.assignmentname == element.name) {
                                                            self.managedObjectContext.delete(self.subassignmentlist[index3])
                                                        }
                                                    }

                                                }
                                            }
                                        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                                            self.managedObjectContext.delete(self.classlist[deletedclassindex])
                                      
                                       // }
                                     //   self.classlist[deletedclassindex].isarchived = true
                                        self.classdeleter.isdeleting = false
                                        
                                        do {
                                            try self.managedObjectContext.save()
                                            print("Class deleted")
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        
                                     //   print("Class deleted")
                                        deletedclassindex = -1
                                        
                                    }) {
                                        HStack {
                                            Text("Archive Class")
                                            Spacer()
                                            Image(systemName: "trash").foregroundColor(Color.red)
                                        }
                                    }.foregroundColor(.red)
                                    
                                }//.animation(.spring())
    //                            NavigationLink(destination: DetailView(classcool: classcool )) {
    //                                ClassView(classcool: classcool, startedToDelete: self.$startedToDelete).contextMenu {
    //                                    Button(action: {
    //                                        self.classlist.count > 0 ? self.NewAssignmentPresenting2.toggle() : self.noClassesAlert.toggle()
    //                                        self.storedindex = self.getactualclassnumber(classcool: classcool)
    //                                    }) {
    //                                        Text("Add Assignment")
    //                                        Image(systemName: "paperclip")
    //                                    }
    //                                }
    //                            }.buttonStyle(PlainButtonStyle())
                          //  }
                        }.frame(width: UIScreen.main.bounds.size.width).animation(.spring())
                        
                    }
                    else
                    {
    //                    Image("emptyclass").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width, alignment: .center).offset(x: -20)
    //                    Text("Click the add button to add a class").font(.system(size: 40)).fontWeight(.light).frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center).multilineTextAlignment(.center)
                        VStack {
                            Spacer().frame(height: 100)
                            ZStack {
    //                            HStack {
    //                                Spacer()
    //                                VStack {
    //                                    ZStack {
    //                                        Image("Arrow").resizable().aspectRatio(contentMode: .fit).frame(width: 80).offset(y: -70)
    //                                        Text("Add class here").offset(x: -40, y: 0)
    //                                    }
    //                                    Spacer()
    //                                }
    //
    //                            }
                                Image(systemName: "moon.zzz").resizable().frame(width: UIScreen.main.bounds.size.width-200, height: 250)
                                Text("No classes created").font(.title).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, height: 30, alignment: .center).offset(y: 175)
                            }
                        }
                    }

                }.frame(width: UIScreen.main.bounds.size.width).sheet(isPresented: self.$NewAssignmentPresenting2, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting2, selectedClass: self.sheetnavigator.storedindex, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: self.$noClassesAlert) {
                    Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            // RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("fifteen")).frame(width: 70, height: 70).opacity(1).padding(20)
                            Button(action: {
                                if (classlist.count > 0)
                                {
                                    self.sheetNavigator.modalView = .assignment
                                    print(self.modalView)
                                    self.NewSheetPresenting = true
                                   // self.NewGradePresenting = true
                                }
                                else
                                {
                                    self.sheetNavigator.alertView = .noclass
                                    self.NewAlertPresenting = true
                                }
                                
                            }) {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).opacity(1).padding(20).overlay(
                                    ZStack {
                                        //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                        Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30)
                                    }
                                )
                            }.buttonStyle(PlainButtonStyle()).contextMenu{
                                Button(action: {
                                    if (classlist.count > 0)
                                    {
                                        self.sheetNavigator.modalView = .assignment
                                        self.NewSheetPresenting = true
                                        self.NewAssignmentPresenting = true
                                    }
                                    else
                                    {
                                        self.sheetNavigator.alertView = .noclass
                                        self.NewAlertPresenting = true
                                    }
                                }) {
                                    Text("Assignment")
                                    Image(systemName: "paperclip")
                                }
                                Button(action: {
                                    self.sheetNavigator.modalView = .classity
                                    self.NewSheetPresenting = true
                                    self.NewClassPresenting = true
                                }) {
                                    Text("Class")
                                    Image(systemName: "list.bullet")
                                }
                                //                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                //                                Text("Occupied Time")
                                //                                Image(systemName: "clock.fill")
                                //                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: { NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                                Button(action: {
                                    self.sheetNavigator.modalView = .freetime
                                    print(self.modalView)
                                    self.NewSheetPresenting = true
                                }) {
                                    Text("Free Time")
                                    Image(systemName: "clock")
                                }
                                Button(action: {
                                    
                                    if (self.getcompletedAssignments())
                                    {
                                        self.sheetNavigator.modalView = .grade
                                        self.NewSheetPresenting = true
                                    }
                                    else
                                    {
                                        self.sheetNavigator.alertView = .noassignment
                                        self.NewAlertPresenting = true
                                    }
                                    //  self.getcompletedAssignments() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()
                                    
                                }) {
                                    Text("Grade")
                                    Image(systemName: "percent")
                                }
                                
                            }//.sheet(isPresented: $NewSheetPresenting, content: sheetContent)
                        }.sheet(isPresented: $NewSheetPresenting, content: sheetContent ).alert(isPresented: $NewAlertPresenting) {
                            Alert(title: self.sheetNavigator.alertView == .noassignment ? Text("No Assignments Completed") : Text("No Classes Added"), message: self.sheetNavigator.alertView == .noassignment ? Text("Complete an Assignment First") : Text("Add a Class First"))
                        }
                        
                        
                        
                        
                    }
                }
            }
            }.navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                        Button(action: {
                            
                            self.showingSettingsView = true
                        })
                        {
                            Image(systemName: "gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }.padding(.leading, 2.0)
                    
                    Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5)                       // Text("").frame(width: UIScreen.main.bounds.size.width/11, height: 20)
                    
                    Button(action: {
                        
                           self.master()
                        //self.createsubassignments()
                        self.schedulenotifications()
                           // MasterStruct().master()
//                            let group1 = ["English A: Literature SL", "English A: Literature HL", "English A: Language and Literature SL", "English A: Language and Literature HL"]
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
////                            for assignmenttype in assignmenttypes {
////                                let newType = AssignmentTypes(context: self.managedObjectContext)
////                                newType.type = assignmenttype
////                                newType.rangemin = 30
////                                newType.rangemax = 300
////                                print(newType.type, newType.rangemin, newType.rangemax)
////                                do {
////                                    try self.managedObjectContext.save()
////                                    print("new Subassignment")
////                                } catch {
////                                    print(error.localizedDescription)
////
////
////                                }
////                            }
//                            for classname in classnames {
//                                let newClass = Classcool(context: self.managedObjectContext)
//                                newClass.originalname = classname
//                                newClass.tolerance = Int64.random(in: 0 ... 10)
//                                newClass.name = classname
//                                newClass.assignmentnumber = 0
//                                newClass.color = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].randomElement()!
//                               // newClass.isarchived = false
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
//                                    newAssignment.grade = Int64.random(in: 2...6)
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


                       // self.schedulenotifications()
                    }
                    )
                    {
                    Image(systemName: "archivebox").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font(Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width/12)
                    }.padding(.trailing, 2.0)

//                        Button(action: {
//                            self.NewClassPresenting.toggle()
//                        }) {
//                            Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
//                        }
            })//.navigationBarTitle(Text("Classes"), displayMode: .large)
        }.onDisappear() {
            self.showingSettingsView = false
            self.selectedClass = 0
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

class SheetNavigatorClassesView: ObservableObject {
    @Published var storedindex: Int = 0
}

class ClassDeleter: ObservableObject {
    @Published var isdeleting: Bool = false
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)
    }
}
