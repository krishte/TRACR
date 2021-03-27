import SwiftUI

struct IndividualAssignmentFilterView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @Binding var selectededitassignment: String
    @Binding var showeditassignment: Bool
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    var formatter: DateFormatter
    
    let isExpanded: Bool
    
    let isCompleted: Bool
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var assignmentduedate: String
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    init(isExpanded2: Bool, isCompleted2: Bool, assignment2: Assignment, selectededit: Binding<String>, showedit: Binding<Bool>)
    {
        isExpanded = isExpanded2
        isCompleted = isCompleted2
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
       // formatter.timeZone = TimeZone(secondsFromGMT: 0)
        assignment = assignment2
        assignmentduedate = formatter.string(from: assignment2.duedate)
        self._selectededitassignment = selectededit
        self._showeditassignment = showedit
        
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    var body: some View {
        ZStack {
            VStack {
                if (isDragged && !self.isCompleted) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: UIScreen.main.bounds.size.width-10+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
//                            if (self.dragoffset.width < -110) {
//                                Text("Complete").foregroundColor(Color.white).frame(width:100)
//                            }
//                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width < -110 ? 0: self.dragoffset.width + 110)
                                //Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width + 110)
                         //   }
                        }
                    }
                }

            }
            
            VStack {
                if (!isExpanded) {
                    HStack {
                        Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                        Spacer()
                    }
                    Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                }
                    
                else {
                    ZStack {
                        VStack {
                            HStack {
                                Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                                Spacer()

                            }

                            Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                            Text("Type: " + assignment.type).frame(width: UIScreen.main.bounds.size.width-50, height: 20, alignment: .topLeading).padding(5)
                            HStack {
                                Text("Length: " + String(gethourminutestext(minutenumber: Int(assignment.totaltime)))).frame( height: 20, alignment: .topLeading).padding(5)
                                Spacer()
                                Text( gethourminutestext(minutenumber: Int(assignment.timeleft)) + " left").fontWeight(.bold).frame( height: 20, alignment: .topTrailing).padding(5)
                            }
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Button(action:{
                                    self.selectededitassignment = self.assignment.name
                                    self.showeditassignment = true
                                }) {
                                    Image(systemName: "pencil.circle").resizable().frame(width: 30, height: 30).padding(.top, 10).padding(.trailing, 10).foregroundColor(colorScheme == .light ? Color.black : Color.white)//.foregroundColor(Color.black)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                    HStack {
                            if (assignment.progress == 100) {
                                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height: 20, alignment: .leading)
                            }
                            else {
                                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height:20, alignment: .leading)
                                Spacer()
                            }
                    }
                }
            }.padding(10).background(assignment.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: assignment.color) : Color(assignment.color)).cornerRadius(14).offset(x: self.dragoffset.width).opacity(isCompleted ? 0.7 : 1.0).gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged { value in
                    //self.dragoffset = value.translation
                    if (!self.isCompleted) {
                        self.dragoffset = value.translation
                        if (self.dragoffset.width < 0) {
                            self.isDraggedleft = false
                            self.isDragged = true
                        }
                        else if (self.dragoffset.width > 0) {
                            self.dragoffset = .zero
                        }
                                            
                        if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 1/2) {
                            self.deleted = true
                        }
                        else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 1/2) {
                            self.incompleted = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                            self.dragoffset = .zero
                        }
                    }



                }
                .onEnded { value in
                    if (!self.isCompleted)
                    {
                        self.dragoffset = .zero
                        // self.isDragged = false
                        if (self.incompleted == true) {
                            if (self.incompletedonce == true) {
                                self.incompletedonce = false;
                                print("incompleted")
                            }
                        }
                         if (self.deleted == true) {
                             if (self.deleteonce == true) {
                                 self.deleteonce = false
                                 self.assignment.completed = true
                                self.assignment.totaltime -= self.assignment.timeleft
                                 self.assignment.timeleft = 0
                                 self.assignment.progress = 100
                                 

                                 for classity in self.classlist {
                                     if (classity.originalname == self.assignment.subject) {
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
                                     print("Assignment completed")
                                 } catch {
                                     print(error.localizedDescription)
                                 }
                                
                                simpleSuccess()
                                
                                masterRunning.masterRunningNow = true
                             }
                         }
                    }
                    else
                    {
                        self.dragoffset = .zero
                        if (self.incompleted == true)
                        {
                            if (self.incompletedonce == true)
                            {
                                self.incompletedonce = false;
                                print("incompleted")
                            }
                        }
                    }
 
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-20).padding(.horizontal, 10)
    }
    func gethourminutestext(minutenumber: Int) -> String {
        if (minutenumber < 60)
        {
            return String(minutenumber) + " minutes"
        }
        else if (minutenumber % 60 == 0)
        {
            return (minutenumber/60 == 1 ? String(minutenumber/60) + " hour" : String(minutenumber/60) + " hours")
        }
        else
        {
            return String(minutenumber/60) + " h " + String(minutenumber%60) + " min"
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("phone vibrated")
    }
}


struct GradedAssignmentsView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @Binding var selectededitassignment: String
    @Binding var showeditassignment: Bool
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    var formatter: DateFormatter
    
    let isExpanded: Bool
    
    let isCompleted: Bool
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var assignmentduedate: String
    let lettergrades = ["E", "D", "C", "B", "A"]
    
    init(isExpanded2: Bool, isCompleted2: Bool, assignment2: Assignment, selectededit: Binding<String>, showedit: Binding<Bool>)
    {
        isExpanded = isExpanded2
        isCompleted = isCompleted2
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
    //    formatter.timeZone = TimeZone(secondsFromGMT: 0)
        assignment = assignment2
        assignmentduedate = formatter.string(from: assignment2.duedate)
        self._selectededitassignment = selectededit
        self._showeditassignment = showedit
        
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    func getdisplaygrade() -> String
    {
        let aflist = ["F", "E", "D", "C", "B", "A"]
        let aelist = ["E", "D", "C", "B", "A"]
        
        for classity in classlist
        {
            if (assignment.subject == classity.originalname)
            {
                if (classity.gradingscheme[0..<1] != "L")
                {
                    return String(assignment.grade)
                }
                else
                {
                    if (classity.gradingscheme[3..<4] == "F")
                    {
                        return aflist[Int(assignment.grade)-1]
                    }
                    else
                    {
                        return aelist[Int(assignment.grade)-1]
                    }
                }
            }
        }
        return "NA";
    }
    
    var body: some View {
        ZStack {
            VStack {
                if (isDragged && !self.isCompleted) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: UIScreen.main.bounds.size.width-10+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
//                            if (self.dragoffset.width < -110) {
//                                Text("Complete").foregroundColor(Color.white).frame(width:100)
//                            }
//                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width < -110 ? 0: self.dragoffset.width + 110)
                                //Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width + 110)
                         //   }
                        }
                    }
                }

            }
            
            VStack {
                if (!isExpanded) {
                    HStack {
                        Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                        Spacer()
                    }
       

                    if (assignment.grade == 0)
                    {
                        Text("Grade: NA").frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                        
                    }
                    else
                    {
                        Text("Grade: " + getdisplaygrade()).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                    }
                    
                }
                    
                else {
                    ZStack {
                        VStack {
                            HStack {
                                Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-100, height: 30, alignment: .topLeading).padding(.leading, 5)
                                Spacer()

                            }

                            if (assignment.grade == 0)
                            {
                                Text("Grade: NA").frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                                
                            }
                            else
                            {
                                Text("Grade: " + getdisplaygrade()).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                            }
                            
                            

                            Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                            Text("Type: " + assignment.type).frame(width: UIScreen.main.bounds.size.width-50, height: 20, alignment: .topLeading).padding(5)
                                Text("Assignment Length: " + String(gethourminutestext(minutenumber: Int(assignment.totaltime)))).frame(width: UIScreen.main.bounds.size.width-50,height: 20, alignment: .topLeading).padding(5)
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Button(action:{
                                    self.selectededitassignment = self.assignment.name
                                    self.showeditassignment = true
                                }) {
                                    Image(systemName: "pencil.circle").resizable().frame(width: 30, height: 30).padding(.top, 10).padding(.trailing, 10).foregroundColor(colorScheme == .light ? Color.black : Color.white)//.foregroundColor(Color.black)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }.padding(10).background(assignment.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: assignment.color) : Color(assignment.color)).cornerRadius(14).offset(x: self.dragoffset.width).opacity(isCompleted ? 0.7 : 1.0).gesture(DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onChanged { value in
                    //self.dragoffset = value.translation

                    if (!self.isCompleted)
                    {
                        self.dragoffset = value.translation
                        if (self.dragoffset.width < 0) {
                            self.isDraggedleft = false
                            self.isDragged = true
                        }
                        else if (self.dragoffset.width > 0) {
                            self.dragoffset = .zero
                        }
                                            
                        if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 1/2) {
                            self.deleted = true
                        }
                        else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 1/2) {
                            self.incompleted = true
                        }
                    }



                }
                .onEnded { value in
                    if (!self.isCompleted)
                    {
                        self.dragoffset = .zero
                        // self.isDragged = false
                        if (self.incompleted == true)
                        {
                            if (self.incompletedonce == true)
                            {
                                self.incompletedonce = false;
                                print("incompleted")
                            }
                        }
                         if (self.deleted == true) {
                             if (self.deleteonce == true) {
                                 self.deleteonce = false
                                 self.assignment.completed = true
                                self.assignment.totaltime -= self.assignment.timeleft
                                 self.assignment.timeleft = 0
                                 self.assignment.progress = 100
                                 
                                 for classity in self.classlist {
                                     if (classity.originalname == self.assignment.subject) {
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
                                     print("Assignment completed")
                                 } catch {
                                     print(error.localizedDescription)
                                 }
                             }
                         }
                    }
                    else {
                        self.dragoffset = .zero
                        if (self.incompleted == true) {
                            if (self.incompletedonce == true) {
                                self.incompletedonce = false;
                                print("incompleted")
                            }
                        }
                    }
 
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-20).padding(.horizontal, 10)
    }
    func gethourminutestext(minutenumber: Int) -> String {
        if (minutenumber < 60)
        {
            return String(minutenumber) + " minutes"
        }
        else if (minutenumber % 60 == 0)
        {
            return (minutenumber/60 == 1 ? String(minutenumber/60) + " hour" : String(minutenumber/60) + " hours")
        }
        else
        {
            return String(minutenumber/60) + " h " + String(minutenumber%60) + " min"
        }
    }
}
