//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI


struct ClassView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    

    var assignmentlist: FetchedResults<Assignment>
    

    var body: some View {
        ZStack {
  

            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill( Color(UIColor(red: CGFloat(classcool.red), green: CGFloat(classcool.green), blue: CGFloat(classcool.blue), alpha: 0.8)))
                .frame(width: UIScreen.main.bounds.size.width-40, height: 100 , alignment: .center)
            VStack {
                
                
                HStack {
                    
                    
                    VStack(alignment: .leading) {
                        Text(classcool.name).font(.title).fontWeight(.bold)
                        
                    }.padding(20)
                    Spacer()
                    Text(String(classcool.assignmentnumber)).font(.title).padding(20)
                }
//
//                if (classcool.assignmentnumber > 0)
//                {
//                    List {
//                        ForEach(assignmentlist) {
//                            assignment in
//                            if (assignment.subject == self.classcool.name)
//                            {
//                                HStack {
//                                        Text(assignment.name)
//                                }.frame(height: 20)
//
//
//
//                            }
//                        }.listRowBackground(Color(UIColor(red: CGFloat(classcool.red), green: CGFloat(classcool.green), blue: CGFloat(classcool.blue), alpha: 0.8)))
//                    }.environment(\.defaultMinListRowHeight, 20)
//                }
        
            }
          
        
        }
    }
}

struct IndividualAssignmentView: View {
    var assignment: Assignment
    var body: some View {

        
        VStack {
              Text(assignment.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
              Text("Due date: " + assignment.duedate.description).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
              Text("Total time: " + String(assignment.totaltime)).frame(width:UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
        }.padding(10).background( Color(UIColor(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue), alpha: 0.8))).cornerRadius(20)
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
                        
//                        Text(assignment.name)
//                        Text("Due date " + assignment.duedate.description)
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
                    print("Assignment deleted")
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
         GeometryReader { geometry in
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
                        HStack(spacing: geometry.size.width / 4.2) {
                            Button(action: {
                                
                                let classnames = ["German", "Math", "English", "Music", "History"]
                                
                
                
                                for classname in classnames {
                                    let newClass = Classcool(context: self.managedObjectContext)
                                    newClass.attentionspan = Int64.random(in: 0 ... 10)
                                    newClass.tolerance = Int64.random(in: 0 ... 10)
                                    newClass.name = classname
                                    newClass.assignmentnumber = 0
                                    newClass.red = Float.random(in: 0 ... 1)
                                    newClass.blue = Float.random(in: 0 ... 1)
                                    newClass.green = Float.random(in: 0 ... 1)
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
                                        newAssignment.progress = ((newAssignment.totaltime - newAssignment.timeleft)/newAssignment.totaltime) * 100
                                        for classity in self.classlist {
                                            if (classity.name == newAssignment.subject)
                                            {
                                                classity.assignmentnumber += 1
                                                newAssignment.red = classity.red
                                                newAssignment.blue = classity.blue
                                                newAssignment.green = classity.green
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
                                Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }.padding(.leading, 2.0);
                        
                            Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                            Button(action: {print("add button clicked")}) {
                                Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }
                    }.padding(.top, -11.0)).navigationBarTitle(Text("Classes"))
                    
             }
        }

    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)

    }
}
