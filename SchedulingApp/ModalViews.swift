import Foundation
import UIKit
import SwiftUI

struct NewAssignmentModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var changingDate: DisplayedDate
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    @Binding var NewAssignmentPresenting: Bool
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentslist: FetchedResults<Assignment>
    
    @State var nameofassignment: String = ""
    @State private var selectedclass = 0
    @State private var assignmenttype = 0
    @State private var hours = 0
    @State private var minutes = 0
    @State var selectedDate = Date()
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    @State private var createassignmentallowed = true
    @State private var showingAlert = false
    @State private var expandedduedate = false
    @State private var startDate = Date()
    var formatter: DateFormatter
    
    init(NewAssignmentPresenting: Binding<Bool>) {
        self._NewAssignmentPresenting = NewAssignmentPresenting
       // selectedDate = changingDate.displayedDate
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Assignment Name", text: $nameofassignment).keyboardType(.default)
                }
                Section {
                    Picker(selection: $selectedclass, label: Text("Class")) {
                        ForEach(0 ..< classlist.count) {
                            Text(self.classlist[$0].name)
                        }
                    }
                }
                Section {
                    Picker(selection: $assignmenttype, label: Text("Type")) {
                        ForEach(0 ..< assignmenttypes.count) {
                            Text(self.assignmenttypes[$0])
                        }
                    }
                }
                
                Section {
                    Text("Total time")
                    HStack {
                        VStack {
                            Picker(selection: $hours, label: Text("Hour")) {
                                ForEach(hourlist.indices) { hourindex in
                                    Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                                 }
                             }.pickerStyle(WheelPickerStyle())
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                        
                        VStack {
                            if hours == 0 {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist[1...].indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                            
                            else {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist.indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                    }
                }


                Section {
                    Button(action: {
                            self.expandedduedate.toggle()
                        
                    }) {
                        HStack {
                            Text("Select due date and time").foregroundColor(Color.black)
                            Spacer()
                            Text(formatter.string(from: selectedDate)).foregroundColor(expandedduedate ? Color.blue: Color.gray)
                        }
                        
                    }
                    if (expandedduedate)
                    {
                        VStack {
                            MyDatePicker(selection: $selectedDate, starttime: $startDate, dateandtimedisplayed: true).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                        }.animation(nil)
                    }
                    //DatePicker("Select due date and time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    Button(action: {
                        self.createassignmentallowed = true
                        
                        for assignment in self.assignmentslist {
                            if assignment.name == self.nameofassignment {
                                self.createassignmentallowed = false
                            }
                        }

                        if self.createassignmentallowed {
                            let newAssignment = Assignment(context: self.managedObjectContext)
                            newAssignment.completed = false
                            newAssignment.grade = 0
                            newAssignment.subject = self.classlist[self.selectedclass].name
                            newAssignment.name = self.nameofassignment
                            newAssignment.type = self.assignmenttypes[self.assignmenttype]
                            newAssignment.progress = 0
                            newAssignment.duedate = self.selectedDate
    //                        print(self.hours)
    //                        print(self.minutes)
                            newAssignment.totaltime = Int64(60*self.hourlist[self.hours] + self.minutelist[self.minutes])
                            newAssignment.timeleft = newAssignment.totaltime
                            for classity in self.classlist {
                                if (classity.name == newAssignment.subject) {
                                    newAssignment.color = classity.color
                                    classity.assignmentnumber += 1
                                }
                            }
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            self.NewAssignmentPresenting = false
                        }
                     
                        else {
                            print("Assignment with Same Name Exists; Change Name")
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add Assignment")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text("Assignment Already Exists"), message: Text("Change Assignment Name"), dismissButton: .default(Text("Continue")))
                    }
                }
                
            }.navigationBarItems(trailing: Button(action: {self.NewAssignmentPresenting = false}, label: {Text("Cancel")})).navigationBarTitle("Add Assignment", displayMode: .inline)
        }
    }
}

struct NewClassModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>

    @Binding var NewClassPresenting: Bool
    @State private var classgroupnameindex = 0
    @State private var classnameindex = 0
    @State private var classlevelindex = 0
    @State private var classtolerancedouble: Double = 5.5

    let subjectgroups = ["Group 1: Language and Literature", "Group 2: Language Acquisition", "Group 3: Individuals and Societies", "Group 4: Sciences", "Group 5: Mathematics", "Group 6: The Arts", "Extended Essay", "Theory of Knowledge"]
    
    let groups = [["English A: Literature", "English A: Language and Literatue", "English B"], ["German B", "French B", "Spanish B", "German A: Literature", "French A: Literature", "Spanish A: Literature", "German A: Language and Literatue", "French A: Language and Literatue", "Spanish A: Language and Literatue", "German Ab Initio", "French Ab Initio", "Spanish Ab Initio"], ["Geography", "History", "Economics", "Psychology", "Global Politics", "Environmental Systems and Societies SL"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Sport Science", "Environmental Systems and Societies SL"], ["Mathematics: Analysis and Approaches", "Mathematics: Applications and Interpretation"], ["Music", "Visual Arts", "Theatre", "Economics", "Psychology", "Biology", "Chemistry", "Physics"], ["Extended Essay"], ["Theory of Knowledge"]]
    
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
                    Picker(selection: $classgroupnameindex, label: Text("Subject Group: ")) {
                        ForEach(0 ..< subjectgroups.count, id: \.self) { indexg in
                            Text(self.subjectgroups[indexg]).tag(indexg)
                        }
                    }
                    
                        if classgroupnameindex == 0 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[0].count, id: \.self) { index in
                                    Text(self.groups[0][index]).tag(index)
                                }
                            }
                        }

                        else if classgroupnameindex == 1 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[1].count, id: \.self) { index in
                                    Text(self.groups[1][index]).tag(index)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 2 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[2].count, id: \.self) { index in
                                    Text(self.groups[2][index]).tag(index)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 3 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[3].count, id: \.self) { index in
                                    Text(self.groups[3][index]).tag(index)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 4 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[4].count, id: \.self) { index in
                                    Text(self.groups[4][index]).tag(index)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 5 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[5].count, id: \.self) { index in
                                    Text(self.groups[5][index]).tag(index)
                                }
                            }
                        }
                    
                    if !(classgroupnameindex == 6 || classgroupnameindex == 7 || (classgroupnameindex == 3 && classnameindex == 6) || (classgroupnameindex == 2 && classnameindex == 5) || (classgroupnameindex == 1 && classnameindex > 8)) {
                        Picker(selection: $classlevelindex, label: Text("Level")) {
                            Text("SL").tag(0)
                            Text("HL").tag(1)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
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
                        let testname = !(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.groups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.classnameindex])"
                        
                        self.createclassallowed = true
                        
                        for classity in self.classlist {
                            if classity.name == testname {
                                // print("sdfds")
                                self.createclassallowed = false
                            }
                        }

                        if self.createclassallowed {
                            let newClass = Classcool(context: self.managedObjectContext)
                            //print(Int(self.classtolerancedouble))
                            //print(self.classnameindex)
                            newClass.tolerance = Int64(self.classtolerancedouble.rounded(.down))
                            newClass.name = testname
                            newClass.assignmentnumber = 0
                            newClass.originalname = testname
                            if self.coloraselectedindex != nil {
                                newClass.color = self.colorsa[self.coloraselectedindex!]
                            }
                            else if self.colorbselectedindex != nil {
                                newClass.color = self.colorsb[self.colorbselectedindex!]
                            }
                            else if self.colorcselectedindex != nil {
                                newClass.color = self.colorsc[self.colorcselectedindex!]
                            }

                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            self.NewClassPresenting = false
                        }
                            
                        else {
                            print("Class with Same Name Exists; Change Name")
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add Class")
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
                            Text(!(self.classgroupnameindex == 6 || self.classgroupnameindex == 7 || (self.classgroupnameindex == 3 && self.classnameindex == 6) || (self.classgroupnameindex == 2 && self.classnameindex == 5) || (self.classgroupnameindex == 1 && self.classnameindex > 8)) ? "\(self.groups[self.classgroupnameindex][self.groups[self.classgroupnameindex].count > self.classnameindex ? self.classnameindex : 0]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.groups[self.classgroupnameindex].count > self.classnameindex ? self.classnameindex : 0])").font(.system(size: 22)).fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("No Assignments").font(.body).fontWeight(.light)
                            }
                        }.padding(.horizontal, 25)
                        
                    }
                }
            }.navigationBarItems(trailing: Button(action: {self.NewClassPresenting = false}, label: {Text("Cancel")})).navigationBarTitle("Add Class", displayMode: .inline)
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

struct NewOccupiedtimeModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        Text("new occupied time")
    }
}

//struct RepeatView: View {
//    var isChecked: Bool
//    var body: some View {
//        Text("hello")
//    }
//}
struct MyDatePicker: UIViewRepresentable {
    @Binding var selection: Date
    @Binding var starttime: Date
    var dateandtimedisplayed: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MyDatePicker>) -> UIDatePicker {
        let picker = UIDatePicker()
        // listen to changes coming from the date picker, and use them to update the state variable
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
        picker.minuteInterval = 5
        picker.datePickerMode = dateandtimedisplayed ? .dateAndTime : .time
        picker.minimumDate = starttime
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: UIViewRepresentableContext<MyDatePicker>) {
        picker.date = selection
        picker.minimumDate = starttime

    }

    class Coordinator {
        let datePicker: MyDatePicker
        init(_ datePicker: MyDatePicker) {
            self.datePicker = datePicker
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            datePicker.selection = sender.date
        }
    }
}

struct NewFreetimeModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var repeatlist: [String] = ["Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday", "Every Sunday"]
    @State private var selection: Set<String> = ["None"]
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [])
    var freetimelist: FetchedResults<Freetime>
    @Binding var NewFreetimePresenting: Bool
    @State private var selectedstartdatetime = Date()
    @State private var selectedenddatetime = Date()
    @State private var expandedstart = false
    @State private var expandedend = false
    @State private var selectedDate = Date()
    let repeats = ["None", "Daily", "Weekly"]
    @State private var selectedrepeat = 0
    var formatter: DateFormatter
    @State var daysNum: [Int] = []
    @State private var starttime = Date(timeIntervalSince1970: 0)
    
    init(NewFreetimePresenting: Binding<Bool>) {
        self._NewFreetimePresenting = NewFreetimePresenting
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
    }
    
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    private func repetitionTextCreator(_ selections: Set<String>) -> String {
        var repetitionText = ""
        var weekdays = false
        var weekends = false
        if (self.selection.contains("None")) {
            repetitionText = "None"
            return repetitionText
        }
        if (self.selection.contains("Every Monday")) {
            repetitionText += "Mondays, "
        }
        if (self.selection.contains("Every Tuesday")) {
            repetitionText += "Tuesdays, "
        }
        if (self.selection.contains("Every Wednesday")) {
            repetitionText += "Wednesdays, "
        }
        if (self.selection.contains("Every Thursday")) {
            repetitionText += "Thursdays, "
        }
        if (self.selection.contains("Every Friday")) {
            repetitionText += "Fridays, "
        }
        if (self.selection.contains("Every Saturday")) {
            repetitionText += "Saturdays, "
        }
        if (self.selection.contains("Every Sunday")) {
            repetitionText += "Sundays, "
        }
        
        if repetitionText.contains("Mondays, Tuesdays, Wednesdays, Thursdays, Fridays") {
            weekdays = true
        }
        
        if repetitionText.contains("Saturdays, Sundays") {
            weekends = true
        }
                
        if weekdays || weekends {
            if weekdays && weekends {
                repetitionText = "Daily  "
            }
            
            else if weekdays {
                repetitionText = repetitionText.replacingOccurrences(of: "Mondays, Tuesdays, Wednesdays, Thursdays, Fridays", with: "Weekdays")
            }
            
            else if weekends {
                repetitionText = repetitionText.replacingOccurrences(of: "Saturdays, Sundays", with: "Weekends")
            }
        }
            
        if repetitionText == "" {
            repetitionText = "Never"
        }
            
        else {
            repetitionText = String(repetitionText.dropLast().dropLast())
        }
        
        return repetitionText
    }
    
    @State private var hour = 1
    @State private var minute = 0

    let minutes = [0, 15, 30, 45]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        
                        
                        Button(action: {
                            
                            self.expandedstart.toggle()
                            
                        }) {
                            HStack {
                                Text("Select start time").foregroundColor(Color.black)
                                Spacer()
                                Text(formatter.string(from: selectedstartdatetime)).foregroundColor(expandedstart ? Color.blue: Color.gray)
                            }
                            
                        }
                        if (expandedstart)
                        {
                            VStack {
                                MyDatePicker(selection: $selectedstartdatetime, starttime: $starttime, dateandtimedisplayed: false).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                            }.animation(nil)
                        }

                   //    DatePicker("Select start time", selection: $selectedstartdatetime, in: Date(timeIntervalSince1970: 0)..., displayedComponents:  .hourAndMinute)//.pickerStyle(WheelPickerStyle())
                    }
                    
                    Section {
                        Button(action: {
                                self.expandedend.toggle()
                            
                        }) {
                            HStack {
                                Text("Select end time").foregroundColor(Color.black)
                                Spacer()
                                Text(formatter.string(from: selectedenddatetime)).foregroundColor(expandedend ? Color.blue: Color.gray)
                            }
                            
                        }
                        if (expandedend)
                        {
                            VStack {
                                MyDatePicker(selection: $selectedenddatetime, starttime: $selectedstartdatetime, dateandtimedisplayed: false).frame(width: UIScreen.main.bounds.size.width-40, height: 200, alignment: .center).animation(nil)
                            }.animation(nil)
                        }
                        
//                        DatePicker("Select end time", selection: $selectedenddatetime, in: selectedstartdatetime..., displayedComponents: .hourAndMinute).pickerStyle(WheelPickerStyle())
                    }

                    Section {
                        NavigationLink(destination:
                            List {
                                HStack {
                                     Button(action: {
                                        if (self.selection.count != 1) {
                                            self.selection.removeAll()
                                            self.selectDeselect("None")
                                        }
                                         
                                     }) {
                                         Text("None").foregroundColor(.black)
                                     }
                                    
                                     if (self.selection.contains("None")) {
                                         Spacer()
                                         Image(systemName: "checkmark").foregroundColor(.blue)
                                     }
                                 }
                                ForEach(self.repeatlist,  id: \.self) { repeatoption in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Button(action: {self.selectDeselect(repeatoption)
                                                if (self.selection.count==0) {
                                                    self.selectDeselect("None")
                                                }
                                                else if (self.selection.contains("None")) {
                                                    self.selectDeselect("None")
                                                }
                                                
                                            }) {
                                                Text(repeatoption).foregroundColor(.black)
                                            }
                                            if (self.selection.contains(repeatoption)) {
                                                Spacer()
                                                Image(systemName: "checkmark").foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            }) {
                                Text("Repeat")
                                Spacer()
                                
                                Text(repetitionTextCreator(self.selection)).foregroundColor(.gray)
                        }
                    }
                    Section {
                        if (selection.contains("None"))
                        {
                            DatePicker("Select date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                        }
                    }
                    Section {
                        Button(action: {
                            let newFreetime = Freetime(context: self.managedObjectContext)

                            if (self.selection.contains("None"))
                            {
                                let calendar = Calendar.current
                                 let dateComponents = calendar.dateComponents([.day, .month, .year], from: self.selectedDate)
                                 let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self.selectedstartdatetime)
                                 
                                 var newComponents = DateComponents()
                                 newComponents.timeZone = .current
                                 newComponents.day = dateComponents.day
                                 newComponents.month = dateComponents.month
                                 newComponents.year = dateComponents.year
                                 newComponents.hour = timeComponents.hour
                                 newComponents.minute = timeComponents.minute
                                 newComponents.second = timeComponents.second
                                 
                                newFreetime.startdatetime = calendar.date(from: newComponents)!
                                
                                
                                let timeComponents2 = calendar.dateComponents([.hour, .minute, .second], from: self.selectedenddatetime)
                                
                                var newComponents2 = DateComponents()
                                newComponents.day = dateComponents.day
                                newComponents.month = dateComponents.month
                                newComponents.year = dateComponents.year
                                newComponents2.hour = timeComponents2.hour
                                newComponents2.minute = timeComponents2.minute
                                newComponents2.second = timeComponents2.second
                                
                                newFreetime.enddatetime = calendar.date(from: newComponents2)!
                            }
 
                            else {
                                newFreetime.startdatetime = self.selectedstartdatetime
                                newFreetime.enddatetime = self.selectedenddatetime
                            }
                            newFreetime.monday = false
                            newFreetime.tuesday = false
                            newFreetime.wednesday = false
                            newFreetime.thursday = false
                            newFreetime.friday = false
                            newFreetime.saturday = false
                            newFreetime.sunday = false
                            
                            if (self.selection.contains("Every Monday")) {
                                newFreetime.monday = true
                            }
                            if (self.selection.contains("Every Tuesday"))
                            {
                                newFreetime.tuesday = true
                            }
                            if (self.selection.contains("Every Wednesday"))
                            {
                                newFreetime.wednesday = true
                            }
                            if (self.selection.contains("Every Thursday"))
                            {
                                newFreetime.thursday = true
                            }
                            if (self.selection.contains("Every Friday"))
                            {
                                newFreetime.friday = true
                            }
                            if (self.selection.contains("Every Saturday"))
                            {
                                newFreetime.saturday = true
                            }
                            if (self.selection.contains("Every Sunday"))
                            {
                                newFreetime.sunday = true
                            }

                            do {
                                try self.managedObjectContext.save()
                                print("object saved")
                                print(newFreetime.monday)
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            self.NewFreetimePresenting = false
                            


                        }) {
                            Text("Add Free Time")
                        }
                    }
                }.frame(height: 700)
                List {
                    NavigationLink(destination: FreetimeDetailView()) {
                        Text("View Free times")
                    }
                }

                
            }.navigationBarItems(trailing: Button(action: {self.NewFreetimePresenting = false}, label: {Text("Cancel")})).navigationBarTitle("Add Free Time", displayMode: .inline)
            
        }
    }

}

struct FreetimeDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    var formatter: DateFormatter
    var formatter2: DateFormatter
    @State private var selection: Set<String> = []
    var daylist = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "One-off Dates"]
    
    init() {
        formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter2 = DateFormatter()
        formatter2.dateStyle = .short
        formatter2.timeStyle = .none
        
    }
    
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    var body: some View {
        List {
            Group {
                Button(action: {self.selectDeselect("Monday")}) {
                    HStack {
                        Text("Monday").foregroundColor(.black).fontWeight(.bold)
                        Spacer()
                        Image(systemName: selection.contains("Monday") ? "chevron.down" : "chevron.up")
                    }.padding(10).background(Color("one")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                }
                if (selection.contains("Monday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.monday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                            self.freetimelist[index].monday = false
                            if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                self.managedObjectContext.delete(self.freetimelist[index])
                            }
                         }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
                Button(action: {self.selectDeselect("Tuesday")}) {
                   HStack {
                       Text("Tuesday").foregroundColor(.black).fontWeight(.bold)
                       Spacer()
                       Image(systemName: selection.contains("Tuesday") ? "chevron.down" : "chevron.up")
                   }.padding(10).background(Color("two")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
               }
                if (selection.contains("Tuesday")) {
                    ForEach(freetimelist) {
                         freetime in
                         if (freetime.tuesday) {
                             Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                         }
                     }
                     .onDelete { indexSet in
                          for index in indexSet {
                              self.freetimelist[index].tuesday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                          do {
                              try self.managedObjectContext.save()
                          } catch {
                              print(error.localizedDescription)
                          }
                          print("Freetime deleted")
                     }
                }
                Button(action: {self.selectDeselect("Wednesday")}) {
                   HStack {
                       Text("Wednesday").foregroundColor(.black).fontWeight(.bold)
                       Spacer()
                       Image(systemName: selection.contains("Wednesday") ? "chevron.down" : "chevron.up")
                   }.padding(10).background(Color("three")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
               }
                if (selection.contains("Wednesday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.wednesday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].wednesday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
                Button(action: {self.selectDeselect("Thursday")}) {
                       HStack {
                           Text("Thursday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Thursday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("four")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Thursday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.thursday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].thursday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                        }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
                Button(action: {self.selectDeselect("Friday")}) {
                       HStack {
                           Text("Friday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Friday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("five")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Friday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.friday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].friday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
            }
            Group {
                Button(action: {self.selectDeselect("Saturday")}) {
                       HStack {
                           Text("Saturday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Saturday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("six")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Saturday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.saturday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].saturday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }
                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
                
                Button(action: {self.selectDeselect("Sunday")}) {
                       HStack {
                           Text("Sunday").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("Sunday") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("seven")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("Sunday")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (freetime.sunday) {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].sunday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday) {
                                  self.managedObjectContext.delete(self.freetimelist[index])
                              }
                            }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
                Spacer()
                Button(action: {self.selectDeselect("One-off Dates")}) {
                       HStack {
                           Text("One-off Dates").foregroundColor(.black).fontWeight(.bold)
                           Spacer()
                           Image(systemName: selection.contains("One-off Dates") ? "chevron.down" : "chevron.up")
                       }.padding(10).background(Color("eight")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                   }
                if (selection.contains("One-off Dates")) {
                    ForEach(freetimelist) {
                        freetime in
                        if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday) {
                            HStack {
                                Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                                Spacer()
                                Text(self.formatter2.string(from: freetime.startdatetime))
                            }
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                             self.managedObjectContext.delete(self.freetimelist[index])
                         }

                         do {
                             try self.managedObjectContext.save()
                         } catch {
                             print(error.localizedDescription)
                         }
                         print("Freetime deleted")
                    }
                }
            }
        }.navigationBarItems(trailing: Button(action: {
            if (self.selection.count < 8) {
                for dayname in self.daylist {
                    if (!self.selection.contains(dayname)) {
                        self.selection.insert(dayname)
                    }
                }
            }
            else {
                self.selection.removeAll()
            }
            
        }, label: {selection.count == 8 ? Text("Collapse All"): Text("Expand All")})).navigationBarTitle("View Free Times", displayMode: .inline)
    }
}

struct NewGradeModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [])
    var assignmentlist: FetchedResults<Assignment>
    @State private var selectedassignment = 0
    @State private var assignmentgrade: Double = 4
    @Binding var NewGradePresenting: Bool
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $selectedassignment, label: Text("Assignment")) {
                        ForEach(0 ..< assignmentlist.count) {
                            if (self.assignmentlist[$0].completed == true && self.assignmentlist[$0].grade == 0)
                            {
                                Text(self.assignmentlist[$0].name)
                            }

                        }
                    }
                }
                Section {
                    VStack {
                        HStack {
                            Text("Grade: \(assignmentgrade.rounded(.down), specifier: "%.0f")")
                            Spacer()
                        }.frame(height: 30)
                        Slider(value: $assignmentgrade, in: 1...7)
                    }

                }
                Section {
                    Button(action: {
                        for assignment in self.assignmentlist {
                            if (assignment.name == self.assignmentlist[self.selectedassignment].name)
                            {
                                assignment.grade =  Int64(self.assignmentgrade.rounded(.down))

                            }
                        }
                     
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        self.NewGradePresenting = false
                    }) {
                        Text("Add Grade")
                    }
                }
            }.navigationBarItems(trailing: Button(action: {self.NewGradePresenting = false}, label: {Text("Cancel")})).navigationBarTitle("Add Grade", displayMode: .inline)
        }
        
    }
}
