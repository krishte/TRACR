import SwiftUI

struct IndividualAssignmentFilterView: View {
    @ObservedObject var assignment: Assignment
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var dragoffset = CGSize.zero
    
    
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    var formatter: DateFormatter
    
    let isExpanded: Bool
    
    let isCompleted: Bool
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var assignmentduedate: String
    
    init(isExpanded2: Bool, isCompleted2: Bool, assignment2: Assignment)
    {
        isExpanded = isExpanded2
        isCompleted = isCompleted2
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        assignment = assignment2
        assignmentduedate = formatter.string(from: assignment2.duedate)
    }
    
    var body: some View {
        ZStack {
            VStack {
                if (isDragged && !self.isCompleted) {
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
                if (isDraggedleft)
                {
                       ZStack {
                        HStack {
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: -UIScreen.main.bounds.size.width+10+self.dragoffset.width)
                        }
                        HStack {
                            
                            if (self.dragoffset.width > 150) {
                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: -110)
                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: -150)
                            }
                            else {
                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width-260)
                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: self.dragoffset.width-300)
                            }
                            
                        }
                    }
                    
                }
            }
            
            VStack {
                if (!isExpanded) {
                    Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                    Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading).padding(5)
                }
                    
                else {
                    Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)

                    Text("Due date: " + assignmentduedate).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading).padding(5)
                    Text("Type: " + assignment.type).frame(width: UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading).padding(5)
                    HStack {
                        Text("Total time: " + String(gethourminutestext(minutenumber: Int(assignment.totaltime)))).frame( height: 20, alignment: .topLeading).padding(5)
                        Spacer()
                        Text( gethourminutestext(minutenumber: Int(assignment.timeleft)) + " left").fontWeight(.bold).frame( height: 20, alignment: .topTrailing).padding(5)
                    }
                }
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                    HStack {
                            if (assignment.progress == 100)
                            {

                                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height: 20, alignment: .leading)
                            }
                            else
                            {
                                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)),height:20, alignment: .leading)
                                Spacer()
                            }
                        


                    }
                }
            }.padding(10).background( Color(assignment.color)).cornerRadius(25).offset(x: self.dragoffset.width).opacity(isCompleted ? 0.7 : 1.0).gesture(DragGesture(minimumDistance: 40, coordinateSpace: .local)
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
                    else
                    {
                        self.dragoffset=value.translation
                        if (self.dragoffset.width > 0) {
                            self.isDragged = false
                            self.isDraggedleft = true
                        }
                        else
                        {
                            self.dragoffset = CGSize.zero
                        }
                        if (self.dragoffset.width > UIScreen.main.bounds.size.width * 3/4) {
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
        }.frame(width: UIScreen.main.bounds.size.width-20).padding(10)
    }
    func gethourminutestext(minutenumber: Int) -> String {
        if (minutenumber < 60)
        {
            return String(minutenumber) + " minutes"
        }
        else if (minutenumber % 60 == 0)
        {
            return String(minutenumber/60) + " hours"
        }
        else
        {
            return String(minutenumber/60) + " h " + String(minutenumber%60) + " min"
        }
    }
}
