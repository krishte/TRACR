//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct NewAssignmentModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    @Binding var NewAssignmentPresenting: Bool
    
    @State var nameofassignment: String = ""
    @State private var selectedclass = 0
    @State private var assignmenttype = 0
    @State private var hours = 0
    @State private var minutes = 0
    @State var selectedDate = Date()
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation", "Exam"]
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
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
                    Picker(selection: $assignmenttype, label: Text("Type"))
                    {
                        ForEach(0 ..< assignmenttypes.count)
                        {
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
                    DatePicker("Select due date and time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
                Section {
                    Button(action: {
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
                    }) {
                        Text("Add Assignment")
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
    
    let groups = [["English A: Literature", "English A: Language and Literatue"], ["German B", "French B", "German A: Literature", "German A: Language and Literatue", "French A: Literature", "French A: Language and Literatue"], ["Geography", "History", "Economics", "Psychology", "Global Politics"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Environmental Systems and Societies", "Sport Science"], ["Mathematics: Analysis and Approaches", "Mathematics: Applications and Interpretation"], ["Music", "Visual Arts", "Theatre" ], ["Extended Essay"], ["Theory of Knowledge"]]
    
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
                    
                    if classgroupnameindex != 6 && classgroupnameindex != 7 {
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
                        let testname = self.classgroupnameindex != 6 && self.classgroupnameindex != 7 ? "\(self.groups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.classnameindex])"
                        
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
                            newClass.attentionspan = Int64(Int.random(in: 1...10))
                            newClass.tolerance = Int64(self.classtolerancedouble.rounded(.down))
                            newClass.name = testname
                            newClass.assignmentnumber = 0
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
                            Text(self.classgroupnameindex != 6 && self.classgroupnameindex != 7 ? "\(self.groups[self.classgroupnameindex][self.groups[self.classgroupnameindex].count > self.classnameindex ? self.classnameindex : 0]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.groups[self.classgroupnameindex].count > self.classnameindex ? self.classnameindex : 0])").font(.system(size: 22)).fontWeight(.bold)
                            
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

struct NewFreetimeModalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var repeatlist: [String] = ["Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday", "Every Sunday"]
    @State private var selection: Set<String> = ["None"]
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [])
    var freetimelist: FetchedResults<Freetime>
    @Binding var NewFreetimePresenting: Bool
    @State private var selectedstartdatetime = Date()
    @State private var selectedenddatetime = Date()
    @State private var selectedDate = Date()
    let repeats = ["None", "Daily", "Weekly"]
    @State private var selectedrepeat = 0
    var formatter: DateFormatter
    var formatter2: DateFormatter
    
    init(NewFreetimePresenting: Binding<Bool>) {
        self._NewFreetimePresenting = NewFreetimePresenting
        formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
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
        if (self.selection.contains("None"))
        {
            repetitionText = "None"
            return repetitionText
        }
        if (self.selection.contains("Every Monday")) {
            repetitionText += "Monday, "
        }
        if (self.selection.contains("Every Tuesday")) {
            repetitionText += "Tuesday, "
        }
        if (self.selection.contains("Every Wednesday")) {
            repetitionText += "Wednesday, "
        }
        if (self.selection.contains("Every Thursday")) {
            repetitionText += "Thursday, "
        }
        if (self.selection.contains("Every Friday")) {
            repetitionText += "Friday, "
        }
        if (self.selection.contains("Every Saturday")) {
            repetitionText += "Saturday, "
        }
        if (self.selection.contains("Every Sunday")) {
            repetitionText += "Sunday, "
        }
        
        if repetitionText.contains("Monday, Tuesday, Wednesday, Thursday, Friday") {
            weekdays = true
        }
        
        if repetitionText.contains("Saturday, Sunday") {
            weekends = true
        }
                
        if weekdays || weekends {
            if weekdays && weekends {
                repetitionText = "Daily  "
            }
            
            else if weekdays {
                repetitionText = repetitionText.replacingOccurrences(of: "Monday, Tuesday, Wednesday, Thursday, Friday", with: "Weekdays")
            }
            
            else if weekends {
                repetitionText = repetitionText.replacingOccurrences(of: "Saturday, Sunday", with: "Weekends")
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
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        DatePicker("Select start time", selection: $selectedstartdatetime, in: Date()..., displayedComponents:  .hourAndMinute)
                    }
                    Section {
                        DatePicker("Select end time", selection: $selectedenddatetime, in: selectedstartdatetime..., displayedComponents: .hourAndMinute)
                    }
                    Section {
                        NavigationLink(destination:
                            List {
                                HStack {
                                     Button(action: {
                                         
                                        if (self.selection.count != 1)
                                        {
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
                                ForEach(self.repeatlist,  id: \.self) {
                                    repeatoption in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Button(action: {self.selectDeselect(repeatoption)
                                                
                                                if (self.selection.count==0)
                                                {
                                                    self.selectDeselect("None")
                                                }
                                                else if (self.selection.contains("None"))
                                                {
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
            Text(String(freetimelist.count))
            Group {
                Button(action: {self.selectDeselect("Monday")}) {
                    HStack {
                        Text("Monday").foregroundColor(.black).fontWeight(.bold)
                        Spacer()
                        Image(systemName: selection.contains("Monday") ? "chevron.down" : "chevron.up")
                    }.padding(10).background(Color("one")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10).offset(x: -10)
                }
                if (selection.contains("Monday"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (freetime.monday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                            self.freetimelist[index].monday = false
                            if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                            {
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
                if (selection.contains("Tuesday"))
                {
                    ForEach(freetimelist)
                     {
                         freetime in
                         if (freetime.tuesday)
                         {
                             Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                         }
                     }
                     .onDelete { indexSet in
                          for index in indexSet {
                              self.freetimelist[index].tuesday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                              {
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
                if (selection.contains("Wednesday"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (freetime.wednesday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].wednesday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                              {
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
                if (selection.contains("Thursday"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (freetime.thursday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].thursday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                              {
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
                if (selection.contains("Friday"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (freetime.friday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].friday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                              {
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
                if (selection.contains("Saturday"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (freetime.saturday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].saturday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                              {
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
                if (selection.contains("Sunday"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (freetime.sunday)
                        {
                            Text(self.formatter.string(from: freetime.startdatetime) + " - " + self.formatter.string(from: freetime.enddatetime))
                        }
                    }
                    .onDelete { indexSet in
                         for index in indexSet {
                              self.freetimelist[index].sunday = false
                              if (!self.freetimelist[index].monday && !self.freetimelist[index].tuesday && !self.freetimelist[index].wednesday && !self.freetimelist[index].thursday && !self.freetimelist[index].friday && !self.freetimelist[index].saturday && !self.freetimelist[index].sunday)
                              {
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
                if (selection.contains("One-off Dates"))
                {
                    ForEach(freetimelist)
                    {
                        freetime in
                        if (!freetime.monday && !freetime.tuesday && !freetime.wednesday && !freetime.thursday && !freetime.friday && !freetime.saturday && !freetime.sunday)
                        {
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
        }
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

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}

struct PageViewControllerWeeks: UIViewControllerRepresentable {
    @Binding var nthdayfromnow: Int

    var viewControllers: [UIViewController]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        pageViewController.dataSource = context.coordinator
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([viewControllers[Int(Double(self.nthdayfromnow / 7).rounded(.down))]], direction: .forward, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewControllerWeeks

        init(_ pageViewController: PageViewControllerWeeks) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                 return nil
            }
            
            if index == 0 {
                return nil
            }
 
            return parent.viewControllers[index - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            if index + 1 == parent.viewControllers.count {
                return nil
            }
            
            return parent.viewControllers[index + 1]
        }
    }
}

struct WeeklyBlockView: View {
    @Binding var nthdayfromnow: Int
    
    let datenumberindices: [Int]
    let datenumbersfromlastmonday: [String]
    
    var body: some View {
        ZStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.datenumberindices.indices) { index in
                    ZStack {
                        Circle().fill(self.datenumberindices[index] == self.nthdayfromnow ? Color("datenumberred") : Color.white).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3)
                        Text(self.datenumbersfromlastmonday[self.datenumberindices[index]]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(.regular)
                    }.onTapGesture {
                        self.nthdayfromnow = self.datenumberindices[index]
                    }
                }
                
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))

//            HStack {
//                Rectangle().frame(width: 5).foregroundColor(Color("datenumberred"))
//                Spacer()
//            }
        }
    }
}

struct SubassignmentAddTimeAction: View {
    var subassignment: Subassignmentnew
    //do stuff
    var body: some View {
        Text("sdfdsf")
    }
}


struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var datesfromlastmonday: [Date] = []
    var daytitlesfromlastmonday: [String] = []
    var datenumbersfromlastmonday: [String] = []
    
    var daytitleformatter: DateFormatter
    var datenumberformatter: DateFormatter
    var formatteryear: DateFormatter
    var formattermonth: DateFormatter
    var formatterday: DateFormatter
    
    let daysoftheweekabr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State var nthdayfromnow: Int = Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day!
    var hourformatter: DateFormatter
    var minuteformatter: DateFormatter
    
    init() {
        daytitleformatter = DateFormatter()
        daytitleformatter.dateFormat = "EEEE, d MMMM"
        
        datenumberformatter = DateFormatter()
        datenumberformatter.dateFormat = "d"
        
        formatteryear = DateFormatter()
        formatteryear.dateFormat = "yyyy"
        
        formattermonth = DateFormatter()
        formattermonth.dateFormat = "MM"
        
        formatterday = DateFormatter()
        formatterday.dateFormat = "dd"
        hourformatter = DateFormatter()
        minuteformatter = DateFormatter()
        self.hourformatter.dateFormat = "HH"
        self.minuteformatter.dateFormat = "mm"
        
        let lastmondaydate = Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!)
        
        
        for eachdayfromlastmonday in 0...27 {
            self.datesfromlastmonday.append(Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate))
            
            self.daytitlesfromlastmonday.append(daytitleformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
            
            self.datenumbersfromlastmonday.append(datenumberformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.daysoftheweekabr.indices) { dayofthweekabrindex in
                    Text(self.daysoftheweekabr[dayofthweekabrindex]).font(.system(size: (UIScreen.main.bounds.size.width / 25))).fontWeight(.light).frame(width: (UIScreen.main.bounds.size.width / 29) * 3)
                }
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))
            
            PageViewControllerWeeks(nthdayfromnow: $nthdayfromnow, viewControllers: [UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday))]).id(UUID()).frame(height: 50)
            
            Text(daytitlesfromlastmonday[self.nthdayfromnow]).font(.title).fontWeight(.medium)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color("one"))//replace color with subassignment color (gradient of subassignment colors, maybe)
                HStack {
                    Text("The Preview p.1 Goes Here")
                    Spacer()
                    Text("The Preview p.2 Goes Here")
                }
            }.frame(width: UIScreen.main.bounds.size.width-50, height: 100)
            
            VStack {
                ScrollView {
                    ZStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                ForEach((0...24), id: \.self) { hour in
                                    HStack {
                                        Text(String(format: "%02d", hour)).font(.footnote).frame(width: 20, height: 20)
                                        Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-50, height: 0.5)
                                    }
                                }.frame(height: 50)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Spacer()
                            VStack {
                                Spacer().frame(height: 25)

                                ZStack(alignment: .topTrailing) {
                                    ForEach(subassignmentlist) { subassignment in
                                        if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: subassignment.startdatetime, toGranularity: .day)) {
                                                IndividualSubassignmentView(subassignment2: subassignment).padding(.top, CGFloat(subassignment.startdatetime.timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 60.35 + 1.3)
                                                //was +122 but had to subtract 2*60.35 to account for GMT + 2
                                            }
                                    }.animation(.spring())
                                }
                                Spacer()
                            }
                        }
                        
                        if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: Date(), toGranularity: .day)) {
                            HStack(spacing: 0) {
                                Circle().fill(Color("datenumberred")).frame(width: 12, height: 12)
                                Rectangle().fill(Color("datenumberred")).frame(width: UIScreen.main.bounds.size.width-36, height: 2)
                            }.padding(.top, CGFloat(Date().timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 120.7 - 1207)
                        }
                    }.animation(.spring())
                }
            }
        }
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
}

struct IndividualSubassignmentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    var starttime, endtime, color, name, duedate: String
    var actualstartdatetime, actualenddatetime, actualduedate: Date
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @State var dragoffset = CGSize.zero
    var subassignmentlength: Int
    var subassignment: Subassignmentnew
    
    init(subassignment2: Subassignmentnew) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.starttime = formatter.string(from: subassignment2.startdatetime)
        self.endtime = formatter.string(from: subassignment2.enddatetime)
//        print(starttime)
//        print(endtime)
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .short
        formatter2.timeStyle = .none
        self.color = subassignment2.color
        self.name = subassignment2.assignmentname
        self.actualstartdatetime = subassignment2.startdatetime
        self.actualenddatetime = subassignment2.enddatetime
        self.actualduedate = subassignment2.assignmentduedate
        self.duedate = formatter2.string(from: subassignment2.assignmentduedate)
        let diffComponents = Calendar.current.dateComponents([.minute], from: self.actualstartdatetime, to: self.actualenddatetime)
        subassignmentlength = diffComponents.minute!
        subassignment = subassignment2
        //print(subassignmentlength)
    }
        
    var body: some View {
        ZStack {
            VStack {
               if (isDragged) {
                   ZStack {
                        HStack {
                            Rectangle().fill(Color.green) .frame(width: UIScreen.main.bounds.size.width-20, height: 58 +    CGFloat(Double(((subassignmentlength-60)/60))*60.35)).offset(x: UIScreen.main.bounds.size.width-30+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
                            if (self.dragoffset.width < -110) {
                                Text("Complete").foregroundColor(Color.white).frame(width:120)
                            }
                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width + 110)
                            }
                        }
                    }
                }
                if (isDraggedleft) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20, height: 58 +  CGFloat(Double(((subassignmentlength-60)/60))*60.35)).offset(x: -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
                        }
                        
                        HStack {
                            if (self.dragoffset.width > 150) {
                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: -150)
                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: -190)
                            }
                            else {
                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width-300)
                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: self.dragoffset.width-340)
                            }
                        }
                    }
                }
            }
            VStack {
                Text(self.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                Text(self.starttime + " - " + self.endtime).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                Spacer()
//                Text("Due Date: " + self.duedate).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
               // Text(self.actualstartdatetime.description)
//                Text(self.actualenddatetime.description)
            }.frame(height: 38 + CGFloat(Double(((subassignmentlength-60)/60))*60.35)).padding(12).background(Color(color)).cornerRadius(20).offset(x: self.dragoffset.width).gesture(DragGesture(minimumDistance: 25, coordinateSpace: .local)
                .onChanged { value in
                    self.dragoffset = value.translation
                    //self.isDragged = true

                    if (self.dragoffset.width < 0) {
                        self.isDraggedleft = false
                        self.isDragged = true
                    }
                    else if (self.dragoffset.width > 0) {
                        self.isDragged = false
                        self.isDraggedleft = true
                    }
                                        
                    if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 3/4) {
                        self.deleted = true
                    }
                    else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 3/4) {
                        self.incompleted = true
                    }
                }
                .onEnded { value in
                    self.dragoffset = .zero
                    //self.isDragged = false
                    //self.isDraggedleft = false
                    if (self.incompleted == true) {
                        if (self.incompletedonce == true) {
                            self.incompletedonce = false
                            print("incompleted")
                            SubassignmentAddTimeAction(subassignment: self.subassignment)
                        }
                    }
                        
                    else if (self.deleted == true) {
                        if (self.deleteonce == true) {
                            self.deleteonce = false
                            
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name) {
                                    let diffComponents = Calendar.current.dateComponents([.hour], from: self.actualstartdatetime, to: self.actualenddatetime)
                                    let hours = diffComponents.hour!
                                    element.timeleft -= Int64(hours)
                                    element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                    if (element.timeleft == 0)
                                    {
                                        element.completed = true
                                        for classity in self.classlist {
                                            if (classity.name == element.subject)
                                            {
                                                classity.assignmentnumber -= 1
                                            }
                                        }
                                    }
                                }
                            }
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                    self.managedObjectContext.delete(self.subassignmentlist[index])
                                }
                            }
                            do {
                                try self.managedObjectContext.save()
                                print("Subassignment completed")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-40)
    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @State var noClassesAlert = false
    
    var body: some View {
        VStack {
            HStack(spacing: UIScreen.main.bounds.size.width / 4.2) {
                Button(action: {print("settings button clicked")}) {
                    Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                }
            
                Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4)

                Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
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
            }.padding(.bottom, 18)
            HomeBodyView()
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
             let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return HomeView().environment(\.managedObjectContext, context)
    }
}
