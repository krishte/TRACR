//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI


struct AssignmentPeakView: View {
    let datedisplay, color, name: String
    

    init(assignment: Assignment) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        self.datedisplay = formatter.string(from: assignment.duedate)
        self.color = assignment.color
        self.name = assignment.name
    }
    
    var body: some View {
        HStack {
            Text(self.name).fontWeight(.medium)
            Spacer()
            Text(self.datedisplay).fontWeight(.light)
        }.padding(.horizontal, 25).padding(.top, 15)
    }
}

struct ClassView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color(classcool.color))
                .frame(width: UIScreen.main.bounds.size.width - 40, height: (80 + (35 * CGFloat(classcool.assignmentnumber))))
            VStack {
                HStack {
                    Text(classcool.name).font(.title).fontWeight(.bold)
                    Spacer()
                    if classcool.assignmentnumber == 0 {
                        Text("No Assignments").font(.body).fontWeight(.light)
                    }
                }.padding(.horizontal, 25)
                
                VStack {
                    ForEach(assignmentlist) {
                        assignment in
                            if (assignment.subject == self.classcool.name) {
                                AssignmentPeakView(assignment: assignment)
                            }
                    }
                }
            }
        }
    }
}

struct IndividualAssignmentView: View {
    var assignment: Assignment
    var body: some View {
        VStack {
              Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
              Text("Type: " + assignment.type).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
              Text("Due date: " + assignment.duedate.description).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
              Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                Text("Time left:  " + String(assignment.timeleft)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                Text("Progress: " + String(assignment.progress)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  UIScreen.main.bounds.size.width-50, height: 20)
                    HStack {
                        RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.green).frame(width:  CGFloat(CGFloat(assignment.progress)/100*(UIScreen.main.bounds.size.width-50)), alignment: .leading)
                        Spacer()
                    }
                   
                    
                }
            }.padding(10).background(Color(assignment.color)).cornerRadius(20)

        }

}


struct DetailView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.title).fontWeight(.bold)
            Spacer()
            Text("Tolerance: " + String(classcool.tolerance))
            Spacer()
            
            List {
                ForEach(assignmentlist) {
                    assignment in
                    if (assignment.subject == self.classcool.name)
                    {
                        IndividualAssignmentView(assignment: assignment)
                    }
                }.onDelete { indexSet in
                    for index in indexSet {
                        self.managedObjectContext.delete(self.assignmentlist[index])
                    }
                    self.classcool.assignmentnumber -= 1
                    
                      do {
                       try self.managedObjectContext.save()
                      } catch {
                       print(error.localizedDescription)
                       }
                    print("Assignment has been deleted")
                }
            }
        }
    }
}

struct ClassesView: View {

    
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    
    var assignmentlist: FetchedResults<Assignment>

    var body: some View {
         NavigationView{
            List {
                ForEach(self.classlist) {
                  classcool in
                  NavigationLink(destination: DetailView(classcool: classcool )) {
                    ClassView(classcool:classcool )
                  }
                }.onDelete { indexSet in
                for index in indexSet {
                    for (index2, element) in self.assignmentlist.enumerated() {
                        if (element.subject == self.classlist[index].name)
                        {
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
                }
             .navigationBarItems(
                leading:
                    HStack(spacing: UIScreen.main.bounds.size.width / 4.2) {
                        Button(action: {
                            
                            let classnames = ["German", "Math", "English", "Music", "History"]
                            let assignmenttypes = ["exam", "essay", "presentation", "test"]
            
            
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
                                let randomint = Int.random(in: 1...5)
                                for i in 0..<randomint {
                                    let newAssignment = Assignment(context: self.managedObjectContext)
                                    newAssignment.name = classname + " assignment " + String(i)
                                    newAssignment.duedate = Date(timeIntervalSinceNow: Double.random(in: 100000 ... 1000000))
                                    newAssignment.totaltime = Int64.random(in: 5...20)
                                    newAssignment.subject = classname
                                    newAssignment.timeleft = Int64.random(in: 1 ... newAssignment.totaltime)
                                    newAssignment.progress = Int64((Double(newAssignment.totaltime - newAssignment.timeleft)/Double(newAssignment.totaltime)) * 100)
                                    newAssignment.grade = 0
                                    newAssignment.completed = false
                                    newAssignment.type = assignmenttypes.randomElement()!

                                    for classity in self.classlist {
                                        if (classity.name == newAssignment.subject)
                                        {
                                            classity.assignmentnumber += 1
                                            newAssignment.color = classity.color
                                            do {
                                             try self.managedObjectContext.save()
                                             print("Class made")
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
                           
                            
                        }) {
                            Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }.padding(.leading, 2.0);
                    
                        Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4);

                        Button(action: {print("add button clicked")}) {
                            Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                        }
                }.padding(.top, -11.0)).navigationBarTitle(Text("Classes"))
                
         }
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)

    }
}
