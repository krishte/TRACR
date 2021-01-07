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
 
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
               // .fill(LinearGradient(gradient: Gradient(colors: [Color(classcool.color), getNextColor(currentColor: classcool.color)]), startPoint: .leading, endPoint: .trailing))
                .fill(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color))
                .frame(width: (UIScreen.main.bounds.size.width - 40)/2, height: (100 ))
               // .shadow(radius: 10)
            VStack {
               // HStack {
                Text(classcool.name).font(.system(size: 20)).fontWeight(.bold).multilineTextAlignment(.center).frame(width: (UIScreen.main.bounds.size.width-60)/2)
               //     Spacer()
//                   if getAverageGrade() == 0 {
//                    Text("No Grades").font(.system(size: 20)).fontWeight(.light)
//                   }
//                   else
//                   {
//                    Text("\(getAverageGrade(), specifier: "%.1f")").font(.system(size: 20)).fontWeight(.bold)
//                   }
                //}.padding(.horizontal, 20)
                
//                VStack {
//                    ForEach(assignmentlist) {
//                        assignment in
//                            if (assignment.subject == self.classcool.name) {
//                                AssignmentPeakView(assignment: assignment)
//                            }
//                    }
//                }
            }.frame(height: 100).padding(.horizontal, 10).padding(.vertical, 5)
        }.frame(width: (UIScreen.main.bounds.size.width-20)/2).shadow(radius: 5)
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
    func getAverageGrade() -> Double
    {
        var gradesum: Double = 0
        var gradenum: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0)
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
 
struct DetailProgressView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    var classlist: FetchedResults<Classcool>
    @State var selectedtimeframe = 0
    let screensize = UIScreen.main.bounds.size.width-20
    var formatter: DateFormatter
    @ObservedObject var sheetnavigator: SheetNavigatorFilterView = SheetNavigatorFilterView()
   // let gradedict:[String:[Double]]
    init(classcool2: Classcool) {
        classcool = classcool2
        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
    }
    
    let subjectgroups = ["Group 1: Language and Literature", "Group 2: Language Acquisition", "Group 3: Individuals and Societies", "Group 4: Sciences", "Group 5: Mathematics", "Group 6: The Arts", "Extended Essay", "Theory of Knowledge"]
 
    let groups = [["English A: Literature", "English A: Language and Literatue"], ["German B", "French B", "German A: Literature", "German A: Language and Literatue", "French A: Literature", "French A: Language and Literatue"], ["Geography", "History", "Economics", "Psychology", "Global Politics"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Environmental Systems and Societies", "Sport Science"], ["Mathematics: Analysis and Approaches", "Mathematics: Applications and Interpretation"], ["Music", "Visual Arts", "Theatre" ], ["Extended Essay"], ["Theory of Knowledge"]]
    var group1_averages = ["English A: Literature SL" : 5.02, "English A: Literature HL" : 4.68, "English A: Language and Literature SL" :5.10, "English A: Language and Literature HL" :4.98, "English B SL" :5.76, "English B HL" :5.73]
 
    var group2_averages = ["French B SL" :5.04, "French B HL" :5.15, "German B SL" :5.10, "German B HL" :5.68, "Spanish B SL" :5.03, "German Ab Initio" :5.00, "Spanish Ab Initio":4.97, "French Ab Initio" :4.90, "French A: Literature SL" :5.10, "French A: Literature HL" :5.21, "French A: Language and Literature SL" :5.33, "French A: Language and Literature HL" :5.11, "German A: Literature SL" :4.96, "German A: Literature HL" : 5.07, "German A: Language and Literature SL" :5.25, "German A: Language and Literature HL" :5.34, "Spanish A: Language and Literature SL" :4.76, "Spanish A: Language and Literature HL" :4.87]
 
    var group3_averages = ["Economics: SL" :4.67, "Economics HL" :5.10, "Geography: SL" :4.80, "Geography: HL" :5.19, "Global Politics: SL" :4.77, "Global Politics: HL" :5.09, "History: SL" :4.46, "History: HL" :4.29, "Psychology: SL" :4.39, "Psychology: HL" :4.71, "Environmental Systems and Societies SL" :4.17]
 
    var group4_averages = ["Biology: SL" :4.18, "Biology: HL" :4.34, "Chemistry: SL" :4.02, "Chemistry: HL" :4.51, "Computer Science: SL" :3.85, "Computer Science: HL" :4.22, "Design Technology: SL" :3.97, "Design Technology: HL" :4.47, "Physics: SL" :4.04, "Physics: HL" :4.65, "Sport, Exercise and Health Science: SL" :3.95, "Sport, Exercise and Health Science: HL" :4.90, "Environmental Systems and Societies SL" :4.17]
 
    var group5_averages = ["Mathematics: Analysis and Approaches SL" :4.19, "Mathematics: Analysis and Approaches HL" :4.69, "Mathematics: Applications and Interpretation SL" :4.19, "Mathematics: Applications and Interpretation HL" :4.69]
 
    var group6_averages = ["Music SL" :4.66, "Music HL" :4.71, "Theatre SL" :4.46, "Theatre HL" :4.88, "Visual Art SL" :3.77, "Visual Art HL" :4.27, "Economics SL" :4.67, "Economics HL" :5.10, "Psychology SL" :4.39, "Psychology HL" :4.71, "Biology SL" :4.18, "Biology HL" :4.34, "Chemistry SL" :4.02, "Chemistry HL" :4.51, "Physics SL" :4.04, "Physics HL" :4.65]
    
    var group1_percentages = ["English A: Literature SL" : [0.00, 0.80, 5.80, 22.80, 38.10, 26.40, 6.20], "English A: Literature HL" : [0.00, 1.50, 8.90, 31.40, 39.40, 16.20, 2.60], "English A: Language and Literature SL" : [0.00, 0.30, 4.00, 20.90, 39.10, 31.50, 4.10], "English A: Language and Literature HL" : [0.00, 0.50, 5.80, 25.50, 37.50, 25.40, 5.30], "English B: SL" : [0.00, 0.20, 1.90, 7.60, 21.80, 48.80, 19.70], "English B: HL" : [0.00, 0.00, 0.60, 5.70, 25.50, 56.10, 12.10]]
    var group2_percentages = ["French B: SL" : [0.10, 1.80, 8.20, 22.90, 27.40, 30.50, 9.10], "French B: HL" : [0.10, 2.3, 10.7, 17.7, 23.5, 29.5, 16.20], "German B: SL" : [0.00, 0.90, 9.30, 21.40, 27.30, 28.80, 12.20], "German B: HL" : [0.00, 0.00, 2.20, 10.00, 24.60, 43.80, 19.40], "Spanish B: SL" : [0.00, 0.70, 9.20, 23.50, 28.50, 28.90, 9.20], "German Ab Initio: SL": [0.00, 1.00, 11.10, 23.10, 25.70, 29.40, 9.60], "Spanish Ab Initio: SL": [0.10, 2.80, 9.40, 24.10, 25.60, 27.30, 10.70], "French Ab Initio: SL" : [0.20, 3.30, 11.30, 23.30, 26.10, 24.50, 11.20], "French A: Literature SL" : [0.00, 0.40, 4.50, 22.70, 37.90, 26.80, 7.80], "French A: Literature HL" : [0.00, 0.00, 4.20, 19.60, 37.40, 28.80, 10.00], "French A: Language and Literature SL" : [0.00, 0.00, 1.00, 17.50, 36.50, 37.60, 7.50], "French A: Language and Literature HL" : [0.00, 0.00, 2.00, 23.30, 41.70, 27.10, 5.80], "German A: Literature SL" : [0.00, 2.30, 6.50, 26.00, 33.10, 22.40, 9.70], "German A: Literature HL" : [0.00, 0.00, 3.0, 23.30, 42.70, 25.90, 5.20], "German A: Language and Literature SL" : [0.00, 0.00, 2.30, 21.10, 32.90, 36.10, 7.40], "German A: Language and Literature HL" : [0.00, 0.00, 3.10, 19.10, 29.40, 37.50, 10.80], "Spanish A: Language and Literature SL" : [0.00, 2.80, 12.90, 24.50, 30.60, 23.50, 5.70], "Spanish A: Language and Literature HL" : [0.00, 1.10, 7.50, 24.10, 42.90, 20.10, 4.40]]
    var group3_percentages = ["Economics: SL" : [1.00, 5.50, 16.30, 20.80, 24.80, 21.80, 9.80], "Economics HL" : [0.40, 2.50, 8.00, 18.00, 30.50, 27.90, 13.10], "Geography: SL" : [0.20, 2.90, 13.90, 22.00, 30.80, 20.90, 9.20], "Geography: HL" : [0.00, 0.60, 6.60, 17.70, 36.20, 25.40, 13.40], "Global Politics: SL" : [0.10, 2.90, 10.80, 24.90, 35.50, 18.80, 7.10], "Global Politics: HL" : [0.10, 1.00, 5.40, 20.80, 37.10, 27.60, 8.00], "History: SL" : [0.10, 4.00, 10.90, 35.90, 34.80, 11.90, 2.20], "History: HL" : [0.20, 4.60, 15.50, 38.50, 29.10, 10.00, 2.00], "Psychology: SL" : [0.80, 8.60, 14.30, 27.60, 27.90, 17.20, 3.50], "Psychology: HL" : [0.20, 3.20, 12.20, 25.70, 31.10, 23.70, 3.90], "Environmental Systems and Societies: SL" : [1.80, 8.00, 24.20, 25.50, 23.60, 11.90, 5.00]]
    var group4_percentages = ["Biology: SL" : [0.90, 10.80, 21.80, 26.60, 20.50, 14.40, 5.0], "Biology: HL" : [1.20, 8.30, 18.50, 26.90, 23.00, 16.10, 5.90], "Chemistry: SL" : [2.90, 15.60, 22.50, 21.30, 17.00, 15.10, 5.50], "Chemistry: HL" : [1.10, 8.80, 17.90, 20.10, 23.00, 20.20, 8.80], "Computer Science: SL" : [2.30, 17.10, 24.70, 24.10, 16.40, 11.50, 3.90], "Computer Science: HL" : [2.00, 11.60, 17.90, 24.20, 25.30, 13.30, 5.70], "Design Technology: SL" : [0.00, 8.50, 28.10, 32.40, 21.80, 7.50, 1.70], "Design Technology: HL" : [0.30, 4.90, 15.70, 30.70, 27.50, 17.20, 3.80], "Physics: SL" : [1.70, 13.10, 26.70, 23.10, 17.20, 10.00, 8.10], "Physics: HL" : [0.70, 6.40, 18.60, 20.80, 22.20, 17.40, 14.00], "Sport, Exercise and Health Science: SL" : [0.90, 13.90, 27.10, 23.40, 20.80, 10.20, 3.70], "Sport, Exercise and Health Science: HL" : [0.00, 3.90, 12.70, 21.00, 26.70, 23.60, 12.20], "Environmental Systems and Societies: SL" : [1.80, 8.00, 24.20, 25.50, 23.60, 11.90, 5.00]]
    var group5_percentages = ["Mathematics: Analysis and Approaches SL" : [2.00, 12.40, 19.90, 23.30, 21.20, 14.90, 6.20], "Mathematics: Analysis and Approaches HL" : [1.10, 7.20, 13.50, 21.90, 24.80, 18.60, 12.80], "Mathematics: Applications and Interpretation SL" : [2.00, 12.40, 19.90, 23.30, 21.20, 14.90, 6.20], "Mathematics: Applications and Interpretation HL" : [1.10, 7.20, 13.50, 21.90, 24.80, 18.60, 12.80]]
    var group6_percentages = ["Music: SL" : [0.30, 1.60, 13.80, 30.90, 27.50, 21.90, 4.10], "Music: HL" : [0.10, 3.20, 17.30, 22.20, 28.50, 19.90, 8.70], "Theatre: SL" : [0.80, 7.40, 14.50, 29.30, 25.80, 14.50, 7.70], "Theatre: HL" : [0.30, 3.00, 10.60, 24.30, 27.60, 24.60, 9.40], "Visual Art: SL" : [0.30, 10.50, 35.20, 28.30, 19.20, 5.60, 1.10], "Visual Art: HL" : [0.10, 4.80, 23.80, 29.50, 26.20, 12.90, 2.70], "Economics: SL" : [1.00, 5.50, 16.30, 20.80, 24.80, 21.80, 9.80], "Economics HL" : [0.40, 2.50, 8.00, 18.00, 30.50, 27.90, 13.10], "Psychology: SL" : [0.80, 8.60, 14.30, 27.60, 27.90, 17.20, 3.50], "Psychology: HL" : [0.20, 3.20, 12.20, 25.70, 31.10, 23.70, 3.90], "Biology: SL" : [0.90, 10.80, 21.80, 26.60, 20.50, 14.40, 5.0], "Biology: HL" : [1.20, 8.30, 18.50, 26.90, 23.00, 16.10, 5.90], "Chemistry: SL" : [2.90, 15.60, 22.50, 21.30, 17.00, 15.10, 5.50], "Chemistry: HL" : [1.10, 8.80, 17.90, 20.10, 23.00, 20.20, 8.80], "Physics: SL" : [1.70, 13.10, 26.70, 23.10, 17.20, 10.00, 8.10], "Physics: HL" : [0.70, 6.40, 18.60, 20.80, 22.20, 17.40, 14.00]]
    var group7_percentages = ["Extended Essay": [10.90, 23.54, 37.99, 25.06, 1.53, 0.99], "Theory of Knowledge": [5.57, 25.54, 48.36, 18.94, 0.68, 0.91]]
    @State var showassignmentedit: Bool = false
    @State var selectedassignmentedit: String = ""
    let minussize: CGFloat = 45
    let squarecolor: String = "graphbackgroundtop"
    @State var NewGradePresenting = false
    @State var storedindex = -1
    @State var noAssignmentsAlert = false
    @State private var selection: Set<Assignment> = []
    func getgradingscheme() -> String
    {
        return classcool.gradingscheme
    }
    func getnumberoflines() -> Int
    {
        if (getgradingscheme()[0..<1] == "P")
        {
            return 10
        }
        else if (getgradingscheme()[0..<1] == "N")
        {
            return Int(getgradingscheme()[3..<getgradingscheme().count]) ?? 10
        }
        else
        {
            if (getgradingscheme()[3..<4] == "F")
            {
                return 6
            }
            return 5
        }
    //    return 10
    }
    func getlinepadding(value: Int) -> CGFloat
    {
        return 270/CGFloat(getnumberoflines())*CGFloat(value+1)
       // return 0
    }
    func gettextvalue(value: Int) -> String
    {
        let aflist = ["F", "E" , "D", "C", "B", "A"]
        let aelist = ["E" , "D", "C", "B", "A"]
        if (getgradingscheme()[0..<1] == "N")
        {
            return String(value+1)
        }
        else if (getgradingscheme()[0..<1] == "P")
        {
            return String((value+1)*10)
        }
        else
        {
            if (getgradingscheme()[3..<4] == "F")
            {
                return aflist[value]
            }
            return aelist[value]
        }
    }

    @EnvironmentObject var masterRunning: MasterRunning
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    var body: some View {
        ZStack {
            VStack {
                Text(classcool.name).font(.system(size: 24)).fontWeight(.bold) .frame(maxWidth: UIScreen.main.bounds.size.width-50, alignment: .center).multilineTextAlignment(.center)
                Spacer()
                Text("Average Grade: \(getAverageGrade(), specifier: "%.1f")")
                Spacer().frame(height: 20)
                Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 4).background(Color("graphbackground"))
                ScrollView(showsIndicators: false) {
                    if (getAverageGrade() != 0) {
                        VStack {
    //                        Picker(selection: $selectedtimeframe, label: Text(""))
    //                        {
    //                            Text("Month").tag(0)
    //                            Text("Year").tag(1)
    //                        }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal, 24)
                            //Divider()
                            //Spacer()
                            if (getgradenum()) {
                                
                                Text(getFirstAssignmentDate() + " - " + getLastAssignmentDate()).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-20, height: 40, alignment: .topLeading).offset(y: 30)
                            }
                            ZStack {
                                VStack {
                                    Rectangle().fill(Color("graphbackground")).frame(width:UIScreen.main.bounds.size.width, height: 300)
                                }.offset(y: 20)
                                HStack
                                {
                                    Spacer()
                                    VStack(alignment: .leading,spacing: 0) {
                                        
                                        Spacer()
                                        ZStack(alignment: .bottom)
                                        {
                                            ForEach(0..<getnumberoflines())
                                            {
                                                value in
                                                HStack
                                                {
                                                    Spacer()
                                                    Rectangle().fill(Color.black).frame(width: screensize, height: 0.5)
                                                    Text(gettextvalue(value: value)).frame(width: 20).font(.system(size: 10))
                                                    Spacer().frame(width: 20)
                                                }.frame(height: 5).padding(.bottom, getlinepadding(value: value)-3)
                                            }
                                            HStack
                                            {
                                                Spacer()
                                                VStack
                                                {
                                                    Spacer()
                                                
                                                    Rectangle().fill(Color.black).frame(width: screensize, height: 1.5)
                                                }
                                                Text("0").frame(width: 20).font(.system(size: 10))
                                                Spacer().frame(width: 20)
                                            }.frame(height: 5).padding(.bottom, 0)
                                            
                                            HStack
                                            {
                                                Spacer()
                                                Rectangle().fill(Color.black).frame(width: 1.5, height: 271)
                                                Text("").frame(width: 20).font(.system(size: 10))
                                                Spacer().frame(width: 20)
                                            }.padding(.bottom, 0)
                                        }
                                        
                                        
                                        
                                    }//.offset(x: -10, y: -15)
                                 //   Spacer()
                                    
                                
                                }
                                HStack {
                                    Spacer()
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
                                                                .frame(width: self.getCompletedNumber(), height: getgradingscheme()[0..<1] == "P" ? CGFloat(assignment.grade)*270/100 : CGFloat(assignment.grade)*getlinepadding(value: 0))

                                                    }
 
                                                }
                                            }
                                        }
                                        
                                    }.frame(width: UIScreen.main.bounds.size.width-30)
                                    Spacer().frame(width: 50)


                                }

                            }
                            
                        }
                        VStack
                        {
                            
                            Spacer().frame(height: 40)
                            HStack {
                                Text("Additional Insights").font(.headline)
                                Spacer()
                            }.padding(.leading, 15)
                            Spacer().frame(height: 20)
 
                            if (getgradenum())
                            {

                                HStack {
                                    VStack {
                                        Text("Average").font(.system(size: 18)).padding(10).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                        Text("\(getAverageGrade(), specifier: "%.2f")").font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        if (getChangeInAverageGrade() >= 0)
                                        {
                                            Text("+\(getChangeInAverageGrade(), specifier: "%.2f")").foregroundColor(Color.green).font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                        else
                                        {
                                            Text("\(getChangeInAverageGrade(), specifier: "%.2f")").foregroundColor(Color.red).font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                    }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                    Spacer().frame(width: 20)
                                    VStack {
                                        Text("Last Assignment vs. Average").font(.system(size: 18)).multilineTextAlignment(.center).padding(10).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                        Text(String(getLastAssignmentGrade())).font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        if (Double(getLastAssignmentGrade()) - getAverageGrade() >= 0.0)
                                        {
                                            Text("+\(Double(getLastAssignmentGrade()) - getAverageGrade(), specifier: "%.2f")").foregroundColor(Color.green).font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                        else
                                        {
                                            Text("\(Double(getLastAssignmentGrade()) - getAverageGrade(), specifier: "%.2f")").foregroundColor(Color.red).font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }
                                    }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                }
                                if (getgradingscheme() == "N1-7")
                                {
                                    
                                    Spacer().frame(height: 20)
                                    HStack {
                                        VStack {
                                            Text("Class Average").padding(10).font(.system(size: 18)).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                            Text(getGlobalAverageI() == 0 ? "No Data": String(getGlobalAverageI())).font(.system(size: 25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                            Text("").font(.system(size: 20)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
     
                                        }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                        Spacer().frame(width: 20)
                                        VStack {
                                            Text("Percentile").padding(10).font(.system(size: 18)).background(Color(squarecolor)).frame(width: UIScreen.main.bounds.size.width/2-minussize ,height: (UIScreen.main.bounds.size.width/2-minussize)/2)
                                            Text(getPercentile() == 0 ? "No Data": String(getPercentile()) + "%").font(.system(size:  25)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                            Text("").font(.system(size: 20)).frame(width: UIScreen.main.bounds.size.width/2-minussize , height: (UIScreen.main.bounds.size.width/2-minussize)/4)
                                        }.padding(10).background(Color(squarecolor)).cornerRadius(25)//.shadow(radius: 10)
                                    }
                                }
 
                            }
                            
                        }.frame(width: UIScreen.main.bounds.size.width)
 
                    }
                    
                    Spacer().frame(height: 20)
  //                  HStack {
                        Text("Completed Assignments").font(.headline)
//                        Spacer()
//                    }.padding(.leading, 15)
                    Spacer().frame(height: 20)
                    
                    ForEach(assignmentlist)
                    {
                        assignment in
                        if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade != 0)
                        {
                            GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment, selectededit: self.$sheetnavigator.selectedassignmentedit, showedit: self.$showassignmentedit).environment(\.managedObjectContext, self.managedObjectContext).onTapGesture {
                                    self.selectDeselect(assignment)
                                }.padding(-5).animation(.spring()).shadow(radius: 10)
                            
                        }
                    }.sheet(isPresented: $showassignmentedit, content: {
                    EditAssignmentModalView(NewAssignmentPresenting: self.$showassignmentedit, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).animation(.spring())
                    if (getUngradedAssignments() > 0)
                    {
                        Spacer().frame(height:10)
                        HStack {
                            VStack {
                                Divider()
                            }
                            Text("Ungraded Assignments").frame(width: 200)
                            VStack {
                                Divider()
                            }
                        }.animation(.spring())
                        ForEach(assignmentlist) {
                            assignment in
                            if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade == 0) {
                                GradedAssignmentsView(isExpanded2: self.selection.contains(assignment), isCompleted2: true, assignment2: assignment, selectededit: self.$sheetnavigator.selectedassignmentedit, showedit: self.$showassignmentedit).shadow(radius: 10).onTapGesture {
                                    self.selectDeselect(assignment)
                                }.padding(-5).animation(.spring())
                            }
                        }.sheet(isPresented: $showassignmentedit, content: {
                            EditAssignmentModalView(NewAssignmentPresenting: self.$showassignmentedit, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).animation(.spring())
                    }
                }.animation(.spring())
                
            }.animation(.spring())
            VStack {
                Spacer()
                HStack {
                    Spacer()
 
                    Button(action: {
                        self.storedindex = self.getactualclassnumber(classcool: self.classcool)
                        self.getcompletedassignmentsbyclass() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()
//                        self.scalevalue = self.scalevalue == 1.5 ? 1 : 1.5
//                        self.ocolor = self.ocolor == Color.blue ? Color.green : Color.blue
                        
                    }) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).padding(20).overlay(
                            ZStack {
                                //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30)
                            }
                        ).shadow(radius: 50)
                    }.animation(.spring()).sheet(isPresented: self.$NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting, classfilter: self.storedindex).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: self.$noAssignmentsAlert) {
                        Alert(title: Text("No Completed Assignments for this Class"), message: Text("Complete an Assignment First"))
                    }
                }
            }
        }
    }
    func getUngradedAssignments() -> Int {
        for assignment in assignmentlist {
            if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade == 0)
            {
                return 1
            }
        }
        return 0
    }
    private func selectDeselect(_ singularassignment: Assignment) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    func getassignmentindex() -> Int {
        print(sheetnavigator.selectedassignmentedit)
        for (index, assignment) in assignmentlist.enumerated() {
            if (assignment.name == sheetnavigator.selectedassignmentedit)
            {
                print(assignment.name)
                return index
            }
        }
        return 0
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
    func getcompletedassignmentsbyclass() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0 && assignment.subject == self.classlist[self.storedindex].originalname)
            {
                return true;
            }
        }
        return false
    }
    func createDict() -> [Assignment: Int] {
        var assignmentgradetonumberdict = [Assignment: Int]()
        var counter = 1
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                assignmentgradetonumberdict[assignment] = counter
                counter += 1
            }
        }
        return assignmentgradetonumberdict
    }
    func getGlobalAverageI() -> Double {
        let allaverages = [group1_averages, group2_averages, group3_averages, group4_averages, group5_averages, group6_averages]
        var _: Double = 0
        for group in allaverages {
            for (name, grade) in group {
                if (name == classcool.originalname)
                {
                    return grade
                }
            }
        }
        return 0
    }
    func getPercentile() -> Int {
        let allpercentages = [group1_percentages, group2_percentages, group3_percentages, group4_percentages, group5_percentages, group6_percentages]
        var percentile: Double = 0
        for group in allpercentages {
            for (name, percentilelist) in group {
                if (name == classcool.originalname)
                {
                    for i in 0...(Int(getAverageGrade()+0.99)-1) {
                        percentile += percentilelist[i]
                    }
                    return Int(percentile+0.5)
                }
            }
        }
        return 0
    }
    func getAverageGrade() -> Double {
        var gradesum: Double = 0
        var gradenum: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                gradesum += Double(assignment.grade)
                gradenum += 1
            }
        }
        if (gradesum == 0) {
            return 0;
        }
        return (gradesum/gradenum)
    }
    func getFirstAssignmentDate() -> String {
        var formattertitle: DateFormatter
        formattertitle = DateFormatter()
        formattertitle.dateFormat = "MMMM yyyy"
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname)
            {
                return formattertitle.string(from: assignment.duedate)
            }
        }
        return formattertitle.string(from: assignmentlist[0].duedate)
    }
    func getLastAssignmentDate() -> String {
        var storedDate: Date
        storedDate = Date()
        var formattertitle: DateFormatter
        formattertitle = DateFormatter()
        formattertitle.dateFormat = "MMMM yyyy"
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname)
            {
                storedDate = assignment.duedate
            }
            
        }
        return formattertitle.string(from: storedDate)
    }
    
    func getLastAssignmentGrade() -> Int64 {
        var gradeval: Int64 = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                gradeval = assignment.grade
            }
        }
      //  print(gradeval)
        return gradeval
    }
    
    func getgradenum() -> Bool {
        var gradenum: Int = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                gradenum += 1
            }
        }
        if (gradenum >= 2) {
            return true
        }
        return false
    }
    
    func getChangeInAverageGrade() -> Double{
        var gradesum: Double = 0
        var gradenum: Double = 0
        var lastgrade: Double = 0
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0)
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
    func getCompletedNumber() -> CGFloat {
        var numberofcompleted: Double = 0
        
        for assignment in assignmentlist {
            if (assignment.subject == classcool.originalname && assignment.completed == true && assignment.grade != 0) {
                numberofcompleted += 1
            }
        }
        if (CGFloat(CGFloat((screensize-30)/CGFloat(numberofcompleted)) - 10) < CGFloat((screensize-30)/40)){
            return CGFloat((screensize-30)/40)
        }
        return CGFloat(CGFloat((screensize-30)/CGFloat(numberofcompleted)) - 10)
    }
    
    func graphableAssignment(assignment: Assignment) -> Bool{
        if (assignment.subject == self.classcool.originalname && assignment.completed == true && assignment.grade != 0) {
            return true;
        }
        return false;
    }
}
 
struct Line: View {
    var classcool: Classcool
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentlist: FetchedResults<Assignment>
    
 
    var data: [Double] {
        var listofassignments: [Double] = []
        for (_, assignment) in assignmentlist.enumerated() {
            if (assignment.completed == true && assignment.grade != 0 && assignment.subject == classcool.originalname)
            {
                listofassignments.append(Double(assignment.grade))
            }
        }
        print(listofassignments)
        return listofassignments
        
    }
    var stepWidth: CGFloat {
        if data.count < 2 {
            return 0
        }
     //   print(CGFloat(UIScreen.main.bounds.size.width-80)/CGFloat(data.count-1))
        return CGFloat(UIScreen.main.bounds.size.width-80)/CGFloat(data.count-1)
        
    }
    var stepHeight: CGFloat {

        if (classcool.gradingscheme[0..<1] == "N")
        {
            let value = classcool.gradingscheme[3..<classcool.gradingscheme.count]
            let intvalue = Int(value) ?? 8
            if (intvalue%2==0)
            {
                return 220/CGFloat(intvalue)
            }
            else
            {
                return 220/CGFloat(intvalue+1)
            }
        }
        else if (classcool.gradingscheme[0..<1] == "L")
        {
            if (classcool.gradingscheme[3..<4] == "F")
            {
                return 220/CGFloat(6)
            }
            else
            {
                return 220/CGFloat(5)
            }
        }
        else
        {
            return 220/CGFloat(100)
        }
                
    }
    var path: Path {
        let points = self.data
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    public var body: some View {
        
   //     ZStack {
 
            self.path
                .stroke(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color) ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
           
      //  }
    }
}
extension Path {
    
    static func lineChart(points:[Double], step:CGPoint) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        let p1 = CGPoint(x: 20, y: 235 - CGFloat(points[0]) * step.y)
     //   print(points[0], step.y)
     //   print( 235 - CGFloat(points[0]) * step.y)
        path.move(to: p1)
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: 20 + step.x * CGFloat(pointIndex), y: 235 - step.y*CGFloat(points[pointIndex]))
          //  print(points[pointIndex], step.y)
         //   print(235 - step.y*CGFloat(points[pointIndex]))
            path.addLine(to: p2)
        }
        return path
    }
}

class SheetNavigatorProgressView: ObservableObject {
    @Published var storedindex: Int = -1
}
 
struct ProgressView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    var assignmentlist: FetchedResults<Assignment>
    
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var NewGradePresenting2 = false
    @State var NewGradePresenting3 = false
    @State var noClassesAlert = false
    @State var noAssignmentsAlert = false
    @State var noAssignmentsAlert2 = false
    @State var storedindex = 0
    @ObservedObject var sheetnavigator: SheetNavigatorProgressView = SheetNavigatorProgressView()
    @State var showingSettingsView = false
    @State private var selectedClass: Int? = 0
    @State private var selection: Set<String> = []
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    
    
    
    private func selectDeselect(_ singularassignment: String) {
        selection.removeAll()
        selection.insert(singularassignment)
        
    }
    
    func getclassnumber(classcool: Classcool) -> Int
    {
        for (index, element) in classlist.enumerated() {
            if (element.name == classcool.name)
            {
                return index+1
            }
        }
        return 1
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
    func getdivisiblebytwo(value: Int) -> Bool {
        if (value % 2 == 0)
        {
            return true
        }
        return false
    }
    func getlastclass(value: Int) -> Bool {
        if (self.classlist.count % 2 == 1 && value == self.classlist.count-1)
        {
            return true
        }
        return false
        
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @ViewBuilder
    private func sheetContent() -> some View {
        
        if (self.sheetNavigator.modalView == .freetime)
        {
            
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
            NewAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
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
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    func getloopnumber() -> Int
    {
        for classity in classlist
        {
            if (self.selection.contains(classity.name))
            {
                
                if (classity.gradingscheme[0..<1] == "N")
                {
                    let value = classity.gradingscheme[3..<classity.gradingscheme.count]
                    let intvalue = Int(value) ?? 8
                    if (intvalue%2==0)
                    {
                        return intvalue/2
                    }
                    else
                    {
                        return (intvalue+1)/2
                    }
                }
                else if (classity.gradingscheme[0..<1] == "L")
                {
                    if (classity.gradingscheme[3..<4] == "F")
                    {
                        return 6
                    }
                    else
                    {
                        return 5
                    }
                }
                else
                {
                    return 5
                }
            }
        }
        return 0
    }
    func gettextval(value2: Int) -> String
    {
        let aflist = ["F", "E", "D", "C", "B", "A"]
        let aelist = ["E", "D", "C", "B", "A"]
        for classity in classlist
        {
            if (self.selection.contains(classity.name))
            {
                
                if (classity.gradingscheme[0..<1] == "N")
                {
                    let value = classity.gradingscheme[3..<classity.gradingscheme.count]
                    let intvalue = Int(value) ?? 8
                    if (intvalue%2==0)
                    {
                        return String(2*(value2+1))
                    }
                    else
                    {
                        return String(2*(value2+1))
                    }
                }
                else if (classity.gradingscheme[0..<1] == "L")
                {
                    if (classity.gradingscheme[3..<4] == "F")
                    {
                        return aflist[value2]
                    }
                    else
                    {
                        return aelist[value2]
                    }
                }
                else
                {
                    return String(20*(value2+1))
                }
            }
        }
        return ""
        
    }
    func getrightpadding() -> CGFloat
    {
        for classity in classlist
        {
            if (self.selection.contains(classity.name))
            {
                
                if (classity.gradingscheme[0..<1] == "N")
                {
                    return CGFloat(20)
                }
                else if (classity.gradingscheme[0..<1] == "L")
                {
                    return CGFloat(20)
                }
                else
                {
                   return CGFloat(15)
                }
            }
        }
        return CGFloat(20)
    }
    
    @State private var refreshID = UUID()
 
    
    var body: some View {
         NavigationView {
            VStack {
            HStack {
                Text("Progress").font(.largeTitle).bold().frame(height:40)
                Spacer()
            }.padding(.all, 10).padding(.top, -60).padding(.leading, 10)
            ZStack {

                NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                { EmptyView() }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center )
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(LinearGradient(gradient: Gradient(colors: [ Color("graphbackgroundtop"), Color("graphbackgroundbottom")]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                .frame(width: (UIScreen.main.bounds.size.width-20), height: (250 ))
                                //.padding(5)
                            
                            VStack {
                                HStack {
                                    Rectangle().frame(width:(UIScreen.main.bounds.size.width-40), height: 1).padding(.top, 15).padding(.leading, 20)
                                    Spacer()
                                }
                                Spacer()
                                HStack {
                                    Rectangle().frame(width: (UIScreen.main.bounds.size.width-40), height: 1).padding(.bottom, 15).padding(.leading, 20)
                                    Spacer()
                                }
 
                            }
 
                            HStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    Rectangle().frame(width: 1, height: 220).padding(.bottom, 15).padding(.trailing, 40)
                                }
                            }
                            ForEach(0..<getloopnumber()) {
                                value in
                                VStack {
                                    Spacer()
                                    HStack {
                                        Rectangle().fill(Color.black).frame(width: (UIScreen.main.bounds.size.width-40), height: 1).padding(.leading, 20).padding(.bottom, 15 + (220/CGFloat(getloopnumber()))*CGFloat(value+1)).opacity(0.3)
                                        Spacer()
                                    }
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text(gettextval(value2: value)).font(.system(size: 12)).padding(.trailing, getrightpadding()).padding(.bottom, (220/CGFloat(getloopnumber()))*CGFloat(value+1) - 5)
                                    }
                                }
                            }.id(refreshID)

                            ForEach(classlist) {
                                classcool in
                                if (self.selection.contains(classcool.name))
                                {
                                    Line(classcool: classcool)
                                }
                                        
                                    
                                
                            }
//                            Path { path in
//                                path.move(to: CGPoint(x: 20, y: 235))
//                                path.addLine(to: CGPoint(x: 50, y: 15))
//                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.size.width-60, y: 235))
//                            }.fill(Color.green)
 
                        }
                        HStack(alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("thirteen"))
                                    .frame(width: (UIScreen.main.bounds.size.width-30)*2/3, height: (200 ))
                                VStack {
                                    Text("Textual Insights").font(.headline).foregroundColor(Color.black)
                                    Text("Coming Soon").fontWeight(.light).foregroundColor(Color.black)
                                }
 
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(LinearGradient(gradient: Gradient(colors: [ Color("graphbackgroundtop"), Color("graphbackgroundbottom")]), startPoint: .bottomTrailing, endPoint: .topLeading))
//                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                    .frame(width: (UIScreen.main.bounds.size.width-30)*1/3, height: (200 ))
                                ScrollView(showsIndicators: false) {
 
 
                                        VStack(alignment: .leading,spacing:10) {
                                            
                                            ForEach(classlist) {
                                                classcool in
                                                if (!classcool.isTrash)
                                                {

                                                    HStack {
                                                        
                                                        Rectangle().fill(classcool.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classcool.color) : Color(classcool.color)).frame(width: 20, height: 4).padding(.leading, 10).opacity(self.selection.contains(classcool.name) ? 1.0 : 0.5)
                                                        Spacer()
                                                        Button(action: {
                                                            self.selectDeselect(classcool.name)
                                                            self.refreshID = UUID()
                                                        })
                                                        {
                                                          
                                                            Text(classcool.name).font(.system(size: 15)).frame(width:(UIScreen.main.bounds.size.width-30)*1/3-50, alignment: .topLeading).foregroundColor(Color("selectedcolor")).opacity(self.selection.contains(classcool.name) ? 1.0 : 0.5)
                                                        }
        //                                                Spacer()
        //                                                if (self.selection.contains(classcool.name)) {
        //
        //                                                    Image(systemName: "checkmark").foregroundColor(.blue)
        //                                                }
                                                        Spacer()
                                                    }
                                                    
                                                }
                                                
                                            }
                                    }
                                    
                                }.frame(height: 180)//.padding(10)
                                //Text("Key").font(.title)
                            }
                        }.padding(.horizontal, 10)
 
                       // Text("Classes").font(.system(size: 35)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-20, alignment: .leading)
                        Spacer().frame(height: 10)

                            ForEach(0..<classlist.count, id: \.self) {
                                value in
//                                if (self.classlist[value].isTrash)
//                                {
                                    NavigationLink(destination: DetailProgressView(classcool2: self.classlist[value]), tag: self.getclassnumber(classcool: self.classlist[value]), selection: self.$selectedClass) {
                                        EmptyView()
                                    }
                                    HStack {
                                        
                                        Button(action: {
                                            self.selectedClass = self.getclassnumber(classcool: self.classlist[value])
                                        }) {
                                            if (self.getlastclass(value: value))
                                            {
                                                ClassProgressView(classcool: self.classlist[value]).frame(alignment: .leading).padding(.leading, 5)
                                            }
                                            else if (self.getdivisiblebytwo(value: value))
                                            {
                                                
                                                ClassProgressView(classcool: self.classlist[value])
                                                
                                            }
     
                                        }.buttonStyle(PlainButtonStyle()).contextMenu {
                                            Button (action: {
     
                                                self.sheetnavigator.storedindex = self.getactualclassnumber(classcool: self.classlist[value])
                                                self.getcompletedassignmentsbyclass() ? self.NewGradePresenting2.toggle() : self.noAssignmentsAlert2.toggle()
                                            }) {
                                                Text("Add Grade")
                                            }
                                            
                                        }.padding(0)
                                        
                                        Button(action: {
                                            self.selectedClass = self.getclassnumber(classcool: self.classlist[value+1])
                                        }) {
                                            if (self.getlastclass(value: value))
                                            {
                                            }
                                            else if (self.getdivisiblebytwo(value: value))
                                            {
                                                ClassProgressView(classcool: self.classlist[value+1])
                                            }
                                        }.buttonStyle(PlainButtonStyle()).contextMenu {
                                            Button (action: {
                                                self.sheetnavigator.storedindex = self.getactualclassnumber(classcool: self.classlist[value+1])
                                                self.getcompletedassignmentsbyclass() ? self.NewGradePresenting2.toggle() : self.noAssignmentsAlert2.toggle()
                                            }) {
                                                Text("Add Grade")
                                            }
                                        }.padding(0)
                                        
                                    }
                               // }
                                
                            }.sheet(isPresented: self.$NewGradePresenting2, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting2, classfilter: self.sheetnavigator.storedindex).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: self.$noAssignmentsAlert2) {
                                Alert(title: Text("No Completed Assignments for this Class"), message: Text("Complete an Assignment First"))
                            }
                            
                        
//                        ForEach(classlist) {
//                            classcool in
//                            NavigationLink(destination: DetailProgressView(classcool2: classcool), tag: self.getclassnumber(classcool: classcool), selection: self.$selectedClass) {
//                                EmptyView()
//                            }
//                            Button(action: {
//                                self.selectedClass = self.getclassnumber(classcool: classcool)
//                            }) {
//                                ClassProgressView(classcool: classcool)
//
//                            }
//
//
//
//                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            // RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("fifteen")).frame(width: 70, height: 70).opacity(1).padding(20)
                            Button(action: {                                
////                                if freetimelist.isEmpty {
////                                    self.sheetNavigator.modalView = .freetime
////                                    self.NewSheetPresenting = true
////                                }
////
////                                else {
//                                    if (classlist.count > 0) {
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
//                                    }
//                                    else {
//                                        self.sheetNavigator.modalView = .classity
//                                        self.NewSheetPresenting = true
//                                        self.NewClassPresenting = true
//                                    }
//                                }
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
            }
            .navigationBarItems(
                leading:
                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                    Button(action: {self.showingSettingsView = true}) {
 
                        Image(systemName:"gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                            
                        
 
 
                    }.padding(.leading, 2.0)
                
                    Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5)
                    Text("").frame(width: UIScreen.main.bounds.size.width/11, height: 20)
//                    Button(action: {
//                        self.getcompletedAssignments() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()
//
//                    }) {
//                        Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
//                    }
                }.padding(.top, 0))//.navigationBarTitle("Progress")
         }.onDisappear {
            self.showingSettingsView = false
            self.selectedClass = 0
         }.onAppear {
//            var found = true
//            while (found == true)
//            {
//                found = false
//                for (index, classity) in classlist.enumerated() {
//                    if (classity.isTrash)
//                    {
//                        self.managedObjectContext.delete(self.classlist[index])
//                        found = true
//                           do {
//                               try self.managedObjectContext.save()
//                               print("AddTime logged")
//                           } catch {
//                               print(error.localizedDescription)
//                           }
//                    }
//                }
//            }
         }
    }
    
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0)
            {
                print(assignment.name)
                return true;
            }
        }
        return false
    }
    func getcompletedassignmentsbyclass() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0 && assignment.subject == self.classlist[self.sheetnavigator.storedindex].originalname)
            {
                return true;
            }
        }
        return false
    }
}
 
struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
          let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ProgressView().environment(\.managedObjectContext, context)
    }
}
