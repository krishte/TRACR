//
//  SettingsView.swift
//  SchedulingApp
//
//  Created by Charan Vadrevu on 06.08.20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct PageViewControllerTutorial: UIViewControllerRepresentable {
    @Binding var tutorialPageNum: Int
    
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
        pageViewController.setViewControllers([viewControllers[self.tutorialPageNum]], direction: .reverse, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewControllerTutorial
 
        init(_ pageViewController: PageViewControllerTutorial) {
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

struct TutorialPageView: View {
    var tutorialScreenshot: String
    var tutorialTitle: String
    var tutorialInstructions1: String
    var tutorialInstructions2: String
    var tutorialInstructions3: String
    var tutorialInstructions4: String
    var tutorialInstructions5: String
    var tutorialposition: [(CGFloat, CGFloat)]
    
    var body: some View {
        VStack {
            ZStack {
                Image(self.tutorialScreenshot).resizable().aspectRatio(contentMode: .fit).frame(height: (UIScreen.main.bounds.size.height / 2) - 20)
//                ForEach(0..<tutorialposition.count)
//                {
//                    coordinatesIndex in
//
//                    Image(systemName: String(coordinatesIndex+1) + ".circle.fill").foregroundColor(Color("thirteen")).position(x: tutorialposition[coordinatesIndex].0, y: tutorialposition[coordinatesIndex].1)
//
//                }
            }
            
            Rectangle().frame(width: UIScreen.main.bounds.size.width - 40, height: 1)
             
            Spacer().frame(height: 15)
            
            HStack {
                Image("TracrIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40).cornerRadius(5)
                Spacer().frame(width: 15)
                Text(self.tutorialTitle).font(.title).fontWeight(.light)
                Spacer()
            }.padding(.leading, 20).padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: false) {
//            VStack(spacing: 5) {
                HStack(alignment: .top) {
                    Image(systemName: "1.circle.fill").foregroundColor(tutorialInstructions1 == "" ? Color.clear : Color("thirteen"))//.frame( alignment: .topLeading)
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions1).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "2.circle.fill").foregroundColor(tutorialInstructions2 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions2).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "3.circle.fill").foregroundColor(tutorialInstructions3 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions3).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "4.circle.fill").foregroundColor(tutorialInstructions4 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions4).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 5)
                HStack(alignment: .top) {
                    Image(systemName: "5.circle.fill").foregroundColor(tutorialInstructions5 == "" ? Color.clear : Color("thirteen"))
                    Spacer().frame(width: 15)
                    Text(tutorialInstructions5).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Spacer().frame(height: 35)
            }.padding(.leading, 35).padding(.trailing, 20).padding(.bottom, 5) // was 120 for bottom
        }//.padding(.top, -100)
    }
}

struct TutorialFirstPageView: View {
    @Binding var tutorialPageSelected: Int
    
    let TutorialTitles: [String] = ["Home Tab", "Tasks", "Add Time to Assignments", "Add Button", "Adding a Class", "Adding Free Time", "Classes Tab", "Inside a Class", "Assignments Tab", "Progress Tab", "Progress of Individual Classes"]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 23) {
                    Image("TracrIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 80, height: 80).cornerRadius(10)
                    
                    Text("Tutorial").font(.largeTitle).fontWeight(.light)
                }
                
                Spacer().frame(height: 20)
                
                ForEach(1..<12) { tag in
                    Button(action: {
                        withAnimation(.spring()) {
                            self.tutorialPageSelected = tag
                        }
                    }) {
                        HStack {
                            Text("\(tag).").font(.system(size: 25)).fontWeight(.bold).frame(width: 45)
                            Text("\(self.TutorialTitles[tag - 1])").font(.system(size: 23)).fontWeight(.light)
                        }.padding(.all, 7)
                    }
                }
            }
        }
    }
}

struct TutorialView: View {
    @State var tutorialPageSelected: Int = 0
    
    var body: some View {
        VStack {
            if #available(iOS 14.0, *) {
                TabView(selection: $tutorialPageSelected) {
                    Group {
                        TutorialFirstPageView(tutorialPageSelected: self.$tutorialPageSelected).tag(0)
                        TutorialPageView(tutorialScreenshot: "Home View 1", tutorialTitle: "Home Tab", tutorialInstructions1: "The left side of the Preview Bar shows next upcoming Task.", tutorialInstructions2: "If you click on a Task, it will divide the Preview Bar into two, and the right side will show a detailed description of the selected Assignment.", tutorialInstructions3: "Holding a date will allow you to add an Assignment that has a due date set to that date.", tutorialInstructions4: "If you have completed a Task, swipe left on it.", tutorialInstructions5: "", tutorialposition: []).tag(1)
                        TutorialPageView(tutorialScreenshot: "Home view 2", tutorialTitle: "Tasks", tutorialInstructions1: "Clicking on the switch indicator on the top-right corner of the Home Tab will give you a diffently structured layout of all of your tasks that doesn't schedule your tasks by time in a given day.", tutorialInstructions2: "", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(2)
                        TutorialPageView(tutorialScreenshot: "Home View 1.1", tutorialTitle: "Add Time to Assignments", tutorialInstructions1: "If you couldn't complete your Task or you weren't available, swipe right and select the percentage of the Task you were able to complete.", tutorialInstructions2: "", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(3)
                        TutorialPageView(tutorialScreenshot: "Add button screenshot", tutorialTitle: "Add Button", tutorialInstructions1: "Click the Add Button to add an Assignment in the Home and Assignments Tabs, a Class in the Classes Tab and a Grade in the Progress Tab.", tutorialInstructions2: "Hold the Add Button to choose to specifically add an Assignment, Class, Free Time or Grade.", tutorialInstructions3: "", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(4)
                        TutorialPageView(tutorialScreenshot: "Adding class", tutorialTitle: "Adding a Class", tutorialInstructions1: "Select your specific Class.", tutorialInstructions2: "Select your Tolerance for this Class, which indicates how much you enjoy working for this Class. The tolerance is used to plan a personalized and appropriate schedule.", tutorialInstructions3: "Choose your preferred colour to be displayed for your Class and its Assignments.", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(5)
                        TutorialPageView(tutorialScreenshot: "Adding free time", tutorialTitle: "Adding Free Time", tutorialInstructions1: "Select the start and end time of your Free Time.", tutorialInstructions2: "Select when the Free Time should repeat, or the specific date for the Free Time if it only takes place once.", tutorialInstructions3: "To view and delete your Free Times, click 'View Free Times'.", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(6)
                    }
                    
                    Group {
                        TutorialPageView(tutorialScreenshot: "Classes view", tutorialTitle: "Classes Tab", tutorialInstructions1: "Hold a Class and click 'Add Assignment' to add an Assignment for that Class.", tutorialInstructions2: "Hold a Class, and click 'Delete Class' to delete it.", tutorialInstructions3: "Click on a Class to see a list of all its Assignments and other details.", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(7)
                        TutorialPageView(tutorialScreenshot: "Inside classes view", tutorialTitle: "Inside a Class", tutorialInstructions1: "Inside a Class, Assignments for that Class are shown.", tutorialInstructions2: "Click on the 'Edit' button (top-right corner) to edit specific Class details.", tutorialInstructions3: "Swipe assignments left to complete them.", tutorialInstructions4: "Click on an Assignment to expand and show detailed information.", tutorialInstructions5: "Click on the Edit button on the Assignment to edit Assignment details.", tutorialposition: []).tag(8)
                        TutorialPageView(tutorialScreenshot: "Assignments view", tutorialTitle: "Assignments Tab", tutorialInstructions1: "Click the top-right button to toggle Completed Assignments.", tutorialInstructions2: "The blue progress bar shows your progress for the completion of the Assignment.", tutorialInstructions3: "Swipe left on Assignments to complete them.", tutorialInstructions4: "Click on an Assignment to expand and show detailed information.", tutorialInstructions5: "Click on the Edit button on the assignment to edit Assignment details.", tutorialposition: []).tag(9)
                        TutorialPageView(tutorialScreenshot: "Progress View", tutorialTitle: "Progress Tab", tutorialInstructions1: "The Graph shows your grades for all your classes over time.", tutorialInstructions2: "Select which Classes you want to appear on the Graph.", tutorialInstructions3: "Hold a Class to add a Grade for the specific Class.", tutorialInstructions4: "Click on a Class to see detailed information and statistics on your Grades for your Class.", tutorialInstructions5: "", tutorialposition: []).tag(10)
                        TutorialPageView(tutorialScreenshot: "Inside Progress View", tutorialTitle: "Progress of Individual Classes", tutorialInstructions1: "Inside a Class, a bar graph displays your grades over time for that Class.", tutorialInstructions2: "Underneath, there are a range of interesting statistics and insights to highlight your progress relative to global statistics.", tutorialInstructions3: "At the bottom, there is a list of all the Completed Assignments for this Class.", tutorialInstructions4: "", tutorialInstructions5: "", tutorialposition: []).tag(11)
                    }
                }.tabViewStyle(PageTabViewStyle()).indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: self.tutorialPageSelected == 0 ? .never : .always))
            } else {
                EmptyView()
                // Fallback on earlier versions
            }//.frame(height: UIScreen.main.bounds.size.height-200)//.padding(.top, -60)
        }
    }
}


struct SyllabusView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @State var selectedsyllabus: Int = 0
    @State var isIB: Bool = false
    var syllabuslist: [String] = ["Percentage-based", "Letter-based", "Number-based"]
    var badlettergrades: [String] = ["E", "F"]
    @State var selectedbadlettergrade: Int = 0
    @State private var gradingschemes: [String] = []
    var goodnumbergrades: [Int] = [4, 5, 6, 7, 8, 9, 10]
    @State var selectedgoodnumbergrade: Int = 0
    
 
    var body: some View
    {
        
        VStack
        {
            Form
            {
                Section {
                    Toggle(isOn: $isIB)
                    {
                        Text("IB or not IB")
                    }

                }
                    
                Section
                {
                    Picker(selection: $selectedsyllabus, label: Text("Grading Scheme")) {
                        ForEach(0..<syllabuslist.count) {
                            val in
                            Text(syllabuslist[val])


                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                
                Section
                {

                    if (selectedsyllabus == 1)
                    {
                        HStack
                        {
                            Text("Best Grade")
                            Spacer()
                            Text("A").foregroundColor(Color.gray)
                        }
                        VStack
                        {
                            HStack
                            {
                                Text("Worst Grade:")
                                Spacer()
                            }
                            Picker(selection: $selectedbadlettergrade, label: Text("Worst Grade"))
                            {
                                ForEach(0..<badlettergrades.count)
                                {
                                    val in
                                    Text(badlettergrades[val])
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    if (selectedsyllabus == 2)
                    {
                        HStack
                        {
                            Text("Worst Grade")
                            Spacer()
                            Text("1").foregroundColor(Color.gray)
                        }
                        VStack
                        {
                            HStack
                            {
                                Text("Best Grade:")
                                Spacer()
                            }
                            Picker(selection: $selectedgoodnumbergrade, label: Text("Best Grade"))
                            {
                                ForEach(0..<goodnumbergrades.count)
                                {
                                    val in
                                    Text(String(goodnumbergrades[val]))
                                }
                            }.pickerStyle(WheelPickerStyle())
                        }
                    }
                }
                Section
                {
                    Button(action:
                    {
                        if (selectedsyllabus == 0)
                        {
                            gradingschemes.append("P")
                            //print("P")
                        }
                        else if (selectedsyllabus == 1)
                        {
                            gradingschemes.append("LA-" + badlettergrades[selectedbadlettergrade])
                          //  print("LA-" + badlettergrades[selectedbadlettergrade])
                        }
                        else
                        {
                            gradingschemes.append("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]))
                            //print("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]))
                        }
                        
                    })
                    {
                        Text("Save Grading Scheme")
                    }
                }
                Section
                {
                    Text("My Grading Schemes:").font(.title2)
                    List
                    {
                        ForEach(gradingschemes, id: \.self)
                        {
                            gradingscheme in
                            HStack
                            {
                                if (gradingscheme[0..<1] == "P")
                                {
                                    Text("Percentage-based")
                                }
                                else if (gradingscheme[0..<1] == "L")
                                {
                                    Text("Letter-based: " + String(gradingscheme[1..<gradingscheme.count]))
                                }
                                else
                                {
                                    Text("Number-based: " + String(gradingscheme[1..<gradingscheme.count]))
                                }

                           //     Text(gradingscheme)
                                Spacer()
                                Image(systemName: "chevron.left").foregroundColor(Color.gray)
                            }
                        }.onDelete { indexSet in
                            for index in indexSet {
                                gradingschemes.remove(at: index)
                            }
                          print("Freetime deleted")
                       }
                    }
                }
            }

        }.onAppear()
        {
            let defaults = UserDefaults.standard
            
            let value = defaults.object(forKey: "savedgradingschemes") as? [String] ?? []
            gradingschemes = value
            print("Value from store")
            print(defaults.object(forKey: "savedgradingschemes") as? [String] ?? [])
         //   print(gradingschemes)
        //    print(gradingscheme)
            let ibval = defaults.object(forKey: "isIB") as? Bool ?? false
            isIB = ibval
         //   print(ibval)
           // print(gradingscheme, ibval)
          //  selectedsyllabus = 1

        }.onDisappear()
        {
            let defaults = UserDefaults.standard
            defaults.set(isIB, forKey: "isIB")
            defaults.set(gradingschemes, forKey: "savedgradingschemes")
            print("Value stored")
            print(defaults.object(forKey: "savedgradingschemes") as? [String] ?? [])
//            if (selectedsyllabus == 0)
//            {
//                defaults.set("P", forKey: "savedgradingschemes")
//                //print("P")
//            }
//            else if (selectedsyllabus == 1)
//            {
//                defaults.set("LA-" + badlettergrades[selectedbadlettergrade], forKey: "savedgradingscheme")
//              //  print("LA-" + badlettergrades[selectedbadlettergrade])
//            }
//            else
//            {
//                defaults.set("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]), forKey: "savedgradingscheme")
//                //print("N1-" + String(goodnumbergrades[selectedgoodnumbergrade]))
//            }
//            //defaults.set("hello", forKey: "savedbreakvalue")
        }
        
    }
}

struct SettingsView: View {
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
    
    @State var cleardataalert = false
    
    @State var tutorialPageNum = 0
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var easteregg1: Bool = false
    @State var easteregg2: Bool = false
    @State var easteregg3: Bool = false
    
    var body: some View {
        Form {
            List {
                Section {
                    NavigationLink(destination: PreferencesView()) {
//                     ZStack {
////                      //  RoundedRectangle(cornerRadius: 10, style: .continuous)
////                         .fill(Color("twelve"))
////                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//                        HStack {
//                         Text("Preferences").font(.system(size: 24)).fontWeight(.bold).frame(height: 40)
//                            Spacer()
//
//                        }.padding(.horizontal, 25)
//                     }
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.green).frame(width:40, height:40)
                                Image(systemName: "slider.horizontal.3").resizable().frame(width:25, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("Type Sliders").font(.system(size:20))
                        }.frame(height:40)
                    }
               // Divider().frame(width:UIScreen.main.bounds.size.width-40, height: 2)
                
                    NavigationLink(destination: NotificationsView()) {
//                    ZStack {
//
////                       RoundedRectangle(cornerRadius: 10, style: .continuous)
////                        .fill(Color("fifteen"))
////                           .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//
//                       HStack {
//                        Text("Notifications").font(.system(size: 24)).fontWeight(.bold).frame(height: 40)
//                           Spacer()
//
//                       }.padding(.horizontal, 25)
//                    }
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.red).frame(width: 40, height: 40)

                                Image(systemName: "app.badge").resizable().frame(width: 25, height: 25)
                            }
                            
                            Spacer().frame(width: 20)
                            Text("Notifications").font(.system(size: 20))
                        }.frame(height: 40)
                    }
               // Divider().frame(width:UIScreen.main.bounds.size.width-40, height: 2)

                    NavigationLink(destination: HelpCenterView()) {
//                     ZStack {
//
////                        RoundedRectangle(cornerRadius: 10, style: .continuous)
////                         .fill(Color("fourteen"))
////                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//
//                        HStack {
//                         Text("FAQ").font(.system(size: 24)).fontWeight(.bold).frame(height: 40)
//                            Spacer()
//
//                        }.padding(.horizontal, 25)
//                     }
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.blue).frame(width:40, height:40)
                                Image(systemName: "questionmark").resizable().frame(width:15, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("FAQ").font(.system(size:20))
                        }.frame(height:40)
                    }

                
//
//                NavigationLink(destination: Text("email and team")) {
//                     ZStack {
//
//                        RoundedRectangle(cornerRadius: 10, style: .continuous)
//                         .fill(Color.orange)
//                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (80))
//
//
//                        HStack {
//                         Text("About us").font(.system(size: 24)).fontWeight(.bold).frame(height: 80)
//                            Spacer()
//
//                        }.padding(.horizontal, 25)
//                     }
//                }
                }
                
                Section {
                        NavigationLink(destination:
                                        TutorialView().navigationBarTitle("Tutorial", displayMode: .inline)//.edgesIgnoringSafeArea(.all)//.padding(.top, -40)
                        ) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.orange).frame(width:40, height:40)
                                    Image(systemName: "info.circle").resizable().frame(width:25, height:25)
                                }
                                Spacer().frame(width:20)
                                Text("Tutorial").font(.system(size:20))
                            }.frame(height:40)
                        }
//                    }
//                    else {
//                        NavigationLink(destination:
//
//                            EmptyView()
//                            PageViewControllerTutorial(tutorialPageNum: self.$tutorialPageNum, viewControllers: [UIHostingController(rootView: TutorialPageView(tutorialScreenshot: "Tutorial1", tutorialTitle: "Adding Free Time", tutorialInstructions1: "This shows the next upcoming task and a detailed description.", tutorialInstructions2: "If you click on a task, it will divide the pinned box and show details of the assignment e.g. Due Date, Progress Bar, Assignment name and Class name.", tutorialInstructions3: "If you click on a task, it will divide the pinned box and show details of the assignment e.g. Due Date, Progress Bar, Assignment name and Class name.")), UIHostingController(rootView: TutorialPageView(tutorialScreenshot: "Tutorial2", tutorialTitle: "Doing This", tutorialInstructions1: "Do this kinda, needs fixing.", tutorialInstructions2: "Do this kinda, needs fixing.", tutorialInstructions3: "")), UIHostingController(rootView: TutorialPageView(tutorialScreenshot: "Tutorial3", tutorialTitle: "Sie Posel", tutorialInstructions1: "Do this kinda, needs fixing.", tutorialInstructions2: "", tutorialInstructions3: "")), UIHostingController(rootView: TutorialPageViewLastPage(tutorialPageNum: self.$tutorialPageNum))]).navigationBarTitle("Tutorial").id(UUID()).frame(height: UIScreen.main.bounds.size.height)
   
                        
//                        ) {
//
//                            HStack {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.orange).frame(width:40, height:40)
//                                    Image(systemName: "info.circle").resizable().frame(width:25, height:25)
//                                }
//                                Spacer().frame(width:20)
//                                Text("Tutorial").font(.system(size:20))
//                            }.frame(height:40)
//
//                        }
//
//                    }
                }
                
                Section {
                    NavigationLink(destination:
                        WorkHours()
                    ) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.blue).frame(width:40, height:40)
                                Image(systemName: "calendar").resizable().frame(width:25, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("Work Hours").font(.system(size:20))
                        }.frame(height:40)
                    }
                }
                    
                Section {
                    NavigationLink(destination:
                        SyllabusView()
                    ) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.purple).frame(width:40, height:40)
                                Image(systemName: "doc.plaintext").resizable().frame(width:25, height:25)
                            }
                            Spacer().frame(width:20)
                            Text("Syllabus").font(.system(size:20))
                        }.frame(height:40)
                    }
                }
                Section {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text("Developer's Beta 0.9").foregroundColor(.gray)
                    }.contentShape(Rectangle()).onTapGesture(count: 5, perform: {
                        self.easteregg1 = true
                    })
                    
                    if self.easteregg1 {
                        VStack {
                            Text("Hello.").fontWeight(.regular)
                        }
                    }
//                    NavigationLink(destination: VStack(alignment: .leading, spacing: 10) {
//                        Text("This version is running with the following bugs:").font(.title2)
//                        Text("1. Creating an Assignment that is due on the current day will cause an internal error. As a result, the app will not be able to schedule any assignments. To continue using the app functionally, please complete this assignment and the app will function normally again.")
//                        Spacer()
//                    }.padding(.all, 22)) {
//                        Text("Developer's Notes")
//                    }
                    
                    Button(action: {
                        self.cleardataalert.toggle()
                    }) {
                        Text("Clear All Data").foregroundColor(Color.red)
                    }.alert(isPresented:$cleardataalert) {
                        Alert(title: Text("Are you sure you want to clear all data?"), message: Text("You cannot undo this operation."), primaryButton: .destructive(Text("Clear All Data")) {
                            self.delete()
                            print("data cleared")
                        }, secondaryButton: .cancel())
                    }
                }
            }
        }.navigationBarTitle("Settings")
        
        if masterRunning.masterRunningNow {
            MasterClass()
        }
    }
    
    func delete() -> Void {
        if (self.subassignmentlist.count > 0) {
            for (index, _) in self.subassignmentlist.enumerated() {
                 self.managedObjectContext.delete(self.subassignmentlist[index])
            }
        }
//        if (self.assignmenttypeslist.count > 0)
//        {
//        for (index, _) in self.assignmenttypeslist.enumerated() {
//             self.managedObjectContext.delete(self.assignmenttypeslist[index])
//        }
//        }
        for (_, element) in self.assignmenttypeslist.enumerated() {
            element.rangemin = 30
            element.rangemax = 300
        }
        
        if (self.assignmentlist.count > 0) {
            for (index, _) in self.assignmentlist.enumerated() {
                 self.managedObjectContext.delete(self.assignmentlist[index])
            }
        }
        if (self.classlist.count > 0) {
            for (index, _) in self.classlist.enumerated() {
                 self.managedObjectContext.delete(self.classlist[index])
            }
        }
//                for (index, _) in self.freetimelist.enumerated() {
//                     self.managedObjectContext.delete(self.freetimelist[index])
//                }
        
        do {
            try self.managedObjectContext.save()
            //print("AssignmentTypes rangemin/rangemax changed")
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct HelpCenterView: View {
    let faqtitles = ["Payment", "Data usage", "Report a problem", "Tutorial", "Dark Mode"]
    let faqtext = ["Payment": "The application is free to use and does not require any in-app purchases.", "Data usage" : "No customer data is used by Tracr and the app does not require wifi to be used.", "Report a problem" : "Problems and bugs within the app can be reported to the following email: tracrteam@gmail.com","Tutorial" : "Questions regarding how to use the app could be solved through the tutorial.", "Dark Mode": "To use our app in dark mode, you have to change this in your phone’s Settings App in Display & Brightness, and that automatically makes our app function in dark mode."]
    let heights = ["Payment" : 50  , "Data usage" : 50, "Report a problem" : 75, "Tutorial" : 50, "Dark Mode" : 100]
    let colors = ["Payment" : "one", "Data usage" : "two", "Report a problem" : "three", "Tutorial" : "four", "Dark Mode" : "fifteen"]
    
    @State private var selection: Set<String> = ["Payment", "Data usage", "Report a problem", "Tutorial", "Dark Mode"]

    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    var body: some View {
            VStack {
                ScrollView(.vertical, showsIndicators: false, content: {
                    Spacer().frame(height: 20)
                    ForEach(self.faqtitles,  id: \.self) {
                        title in
                        VStack {
        
                            Button(action: {
                                self.selectDeselect(title)
                                
                                
                            }) {
                                HStack {
                                    Text(title).foregroundColor(.black).fontWeight(.bold)
                                    Spacer()
                                    Image(systemName: self.selection.contains(title) ? "chevron.down" : "chevron.up").foregroundColor(Color.black)
                                }.padding(10).background(Color(self.colors[title]!)).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10)
                            }
                        
                            if (self.selection.contains(title))
                            {
                                Text(self.faqtext[title]!).multilineTextAlignment(.leading).lineLimit(nil).frame(width: UIScreen.main.bounds.size.width - 40, alignment: .topLeading)
                            }
                        }
                    }.animation(.spring())
                }).animation(.spring())
            }.navigationBarItems(trailing: Button(action: {
                if (self.selection.count < 5) {
                    for title in self.faqtitles {
                        if (!self.selection.contains(title)) {
                            self.selection.insert(title)
                        }
                    }
                }
                else {
                    self.selection.removeAll()
                }
                
            }, label: {selection.count == 5 ? Text("Collapse All"): Text("Expand All")})).navigationBarTitle("FAQ", displayMode: .inline)
        
    }
}
struct PreferencesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: AssignmentTypes.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \AssignmentTypes.type, ascending: true)])
    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State private var typeval: Int = 150
    @State private var selection: Set<String> = []
 
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]
    var body: some View {
        VStack {
            //Text(String(assignmenttypeslist.count))
          //  Form {
                ScrollView(showsIndicators: false) {
                        Button(action: {
                            self.selectDeselect("show")
                        }) {
                            HStack {
                                Text("What is this?").foregroundColor(.black).fontWeight(.bold)
                                Spacer()
                                Image(systemName: self.selection.contains("show") ? "chevron.down" : "chevron.up").foregroundColor(Color.black)
                            }.padding(10).background(Color("two")).frame(width: UIScreen.main.bounds.size.width-20).cornerRadius(10)
                        }.animation(.spring())
                    
                        if (self.selection.contains("show")) {
                            Text("These are the Type Sliders. You can drag on the Type Sliders to adjust your preferred task length for each assignment type. For example, you can set your preferred task length for essays to 30 to 60 minutes. Then, if possible, the tasks created for Essay assignments will be between 30 and 60 minutes long. ").multilineTextAlignment(.leading).lineLimit(nil).frame(width: UIScreen.main.bounds.size.width - 40, height: 200, alignment: .topLeading).animation(.spring())
                            Divider().frame(width: UIScreen.main.bounds.size.width-40, height: 2).animation(.spring())
                        }
//                    DetailBreakView()
                    ForEach(self.assignmenttypeslist) { assignmenttype in
                        DetailPreferencesView(assignmenttype: assignmenttype)
                    }//.animation(.spring())
                }//.animation(.spring())
           // }.navigationBarTitle("Preferences")
        }.navigationBarTitle("Type Sliders").onDisappear {
            masterRunning.masterRunningNow = true
        }
    }
}
struct DetailBreakView: View {
    @State var breakvalue: Double
    init() {
        let defaults = UserDefaults.standard
        print(defaults.object(forKey: "savedbreakvalue") as? Int ?? 10)
        let breakval = defaults.object(forKey: "savedbreakvalue") as? Int ?? 10
        _breakvalue = State(initialValue: Double(breakval)/5)
        
    }
    var body: some View {
        VStack {
     //   Divider().frame(width: UIScreen.main.bounds.size.width-60, height: 2)
        Text("Break").font(.title).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
        
        Slider(value: $breakvalue, in: 1...4).frame(width: UIScreen.main.bounds.size.width-60)
        HStack {
            Text("Time: " + String(Int(5*Int(breakvalue))) + " minutes")
            Spacer()
        }.frame(width: UIScreen.main.bounds.size.width-60, height: 30)
        Divider().frame(width: UIScreen.main.bounds.size.width-60, height: 2)
        }.onDisappear {
            let defaults = UserDefaults.standard
            defaults.set(Int(5*Int(breakvalue)), forKey: "savedbreakvalue")
        }
    }
}
struct DetailPreferencesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var assignmenttype: AssignmentTypes
    @FetchRequest(entity: AssignmentTypes.entity(),
                  sortDescriptors: [])

    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    @State var currentdragoffsetmin = CGSize.zero
    @State var currentdragoffsetmax = CGSize.zero
    @State var newdragoffsetmax = CGSize.zero
    @State private var typeval: Double = 0
    @State private var typeval2: Double = 0
    @State private var newdragoffsetmin = CGSize.zero
    @State private var textvaluemin = 0
    @State private var textvaluemax = 0

    @EnvironmentObject var masterRunning: MasterRunning

    @State var rectangleWidth = UIScreen.main.bounds.size.width - 60;
    
    init(assignmenttype: AssignmentTypes) {
        self.assignmenttype = assignmenttype
    }
    
    func setValues() -> Bool {
        self.typeval = Double(assignmenttype.rangemin)
        self.typeval2 = Double(assignmenttype.rangemax)
        return true;
    }
    
    var body: some View {
        VStack {
            Text(assignmenttype.type).font(.title).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("add_overlay_bg")).frame(width: self.rectangleWidth, height: 20, alignment: .leading).overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black, lineWidth: 0.5).frame(width: self.rectangleWidth, height: 20, alignment: .leading)
                )
                Rectangle().fill(Color.green).frame(width: max(self.currentdragoffsetmax.width - self.currentdragoffsetmin.width, 0), height: 19).offset(x: getrectangleoffset())
                
                VStack {
                    Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2)
                    Text(textvaluemin == 0 ? String(roundto15minutes(roundvalue: getmintext())) : String(textvaluemin))

                }.offset(x:  self.currentdragoffsetmin.width, y: 15)
                    // 3.
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                           // print(value.translation.width)

                            self.currentdragoffsetmin = CGSize(width: value.translation.width + self.newdragoffsetmin.width, height: value.translation.height + self.newdragoffsetmin.height)
                            
                            if (self.currentdragoffsetmin.width < -1*self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = -1*self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.currentdragoffsetmax.width)
                            {
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                             //   print("success1")
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width - self.rectangleWidth/9 - 1
                            }

                    }   // 4.
                        .onEnded { value in
                           self.currentdragoffsetmin = CGSize(width: value.translation.width + self.newdragoffsetmin.width, height: value.translation.height + self.newdragoffsetmin.height)
                            if (self.currentdragoffsetmin.width < -1*self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = -1*self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.rectangleWidth/2)
                            {
                                self.currentdragoffsetmin.width = self.rectangleWidth/2
                            }
                            if (self.currentdragoffsetmin.width > self.currentdragoffsetmax.width)
                            {
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                             //   print("success2")
                                self.currentdragoffsetmin.width = self.currentdragoffsetmax.width - self.rectangleWidth/9 - 1
                            }

                            self.newdragoffsetmin = self.currentdragoffsetmin
                            
                        }
                )
                VStack {
                    Circle().fill(Color.white).frame(width: 30, height: 30).shadow(radius: 2)
                    Text(textvaluemax == 0 ? String(roundto15minutes(roundvalue: getmaxtext())) : String(textvaluemax))
                }.offset(x:  self.currentdragoffsetmax.width, y: 15)
                     // 3.
                     .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                         .onChanged { value in
                            // print(value.translation.width)

                             self.currentdragoffsetmax = CGSize(width: value.translation.width + self.newdragoffsetmax.width, height: value.translation.height + self.newdragoffsetmax.height)
                             
                             if (self.currentdragoffsetmax.width < -1*self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = -1*self.rectangleWidth/2
                             }
                             if (self.currentdragoffsetmax.width > self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = self.rectangleWidth/2
                             }
                            if (self.currentdragoffsetmax.width < self.currentdragoffsetmin.width)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width + self.rectangleWidth/9 + 1
                            }

                     }   // 4.
                         .onEnded { value in
                            self.currentdragoffsetmax = CGSize(width: value.translation.width + self.newdragoffsetmax.width, height: value.translation.height + self.newdragoffsetmax.height)
                             if (self.currentdragoffsetmax.width < -1*self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = -1*self.rectangleWidth/2
                             }
                             if (self.currentdragoffsetmax.width > self.rectangleWidth/2)
                             {
                                 self.currentdragoffsetmax.width = self.rectangleWidth/2
                             }
                            if (self.currentdragoffsetmax.width < self.currentdragoffsetmin.width)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width
                            }
                            if (self.currentdragoffsetmax.width - self.currentdragoffsetmin.width < self.rectangleWidth/9 + 1)
                            {
                                self.currentdragoffsetmax.width = self.currentdragoffsetmin.width + self.rectangleWidth/9 + 1
                            }

                            self.newdragoffsetmax = self.currentdragoffsetmax
                         }
                 )

            }
//                HStack {
//                   // Text("Min: " + String(roundto15minutes(roundvalue: getmintext()))).frame(width: rectangleWidth/2)
//                 //   Text("Max: " + String(roundto15minutes(roundvalue: getmaxtext()))).frame(width: rectangleWidth/2)
//                }
            Spacer().frame(height: 30)
            HStack {
//                   Spacer().frame(width: 5)
                HStack(spacing: rectangleWidth/9 - 1) {
                    
                    ForEach(0 ..< 10)
                    {
                        value in
                        Rectangle().frame(width: 1, height: 10)
                    }
                }
            }
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black).frame(width: self.rectangleWidth, height: 1, alignment: .leading).offset(y: -8)
            HStack {
                Text("30m").font(.system(size: 10)).offset(x: 5)
                Spacer()
                Text("300m").font(.system(size: 10))
            }.frame(width: rectangleWidth+30).offset(y: -5)
            Spacer().frame(height: 30)
            Divider().frame(width: rectangleWidth, height: 2)

        }.padding(10).onAppear {
            self.typeval = Double(self.assignmenttype.rangemin)
            self.typeval2 = Double(self.assignmenttype.rangemax)
            self.currentdragoffsetmin.width = ((CGFloat(self.assignmenttype.rangemin)-165)/135)*self.rectangleWidth/2
            self.currentdragoffsetmax.width = ((CGFloat(self.assignmenttype.rangemax)-165)/135)*self.rectangleWidth/2
            self.newdragoffsetmin.width = ((CGFloat(self.assignmenttype.rangemin)-165)/135)*self.rectangleWidth/2
            self.newdragoffsetmax.width = ((CGFloat(self.assignmenttype.rangemax)-165)/135)*self.rectangleWidth/2
        }.onDisappear {
//                self.assignmenttype.rangemin = Int64(self.typeval)
//                self.assignmenttype.rangemax = Int64(self.typeval2)
            if (self.textvaluemin == 0) {
                self.assignmenttype.rangemin  = Int64(self.roundto15minutes(roundvalue: self.getmintext()))
            }
            else {
                self.assignmenttype.rangemin = Int64(self.textvaluemin)
            }
            if (self.textvaluemax == 0) {
                self.assignmenttype.rangemax  = Int64(self.roundto15minutes(roundvalue: self.getmaxtext()))
            }
            else {
                self.assignmenttype.rangemax = Int64(self.textvaluemax)
            }
            do {
                try self.managedObjectContext.save()
                //print("AssignmentTypes rangemin/rangemax changed")
            } catch {
                print(error.localizedDescription)
            }
            print("Signal Sent.")
        }
    }
    
    func roundto15minutes(roundvalue: Int) -> Int {
        if (roundvalue % 15 <= 7) {
            return roundvalue - (roundvalue % 15)
        }
        else {
            return roundvalue + 15 - (roundvalue % 15)
        }
    }
    func getrectangleoffset() -> CGFloat {
        return -1*((self.currentdragoffsetmax.width-self.currentdragoffsetmin.width)/2 - (self.currentdragoffsetmin.width))+max(self.currentdragoffsetmax.width - self.currentdragoffsetmin.width, 0)
    }
    func getmintext() -> Int {
        return 165 + Int((self.currentdragoffsetmin.width/(rectangleWidth/2))*135)
    }
    func getmaxtext() -> Int {
        return 165 + Int((self.currentdragoffsetmax.width/(rectangleWidth/2))*135)
    }
}

struct NotificationsView: View {
    let beforeassignmenttimes = ["At Start", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]
    @State var selectedbeforeassignment = 0
    @State var selectedbeforebreak = 0
    let beforebreaktimes = [0,5, 10, 15, 30]
    @State var atassignmentstart = false
    @State var atbreakstart = false
    @State var atassignmentend = false
    @State private var selection: Set<String> = ["None"]
    @State private var selection2: Set<String> = ["None"]
    @State var atbreakend = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var masterRunning: MasterRunning

    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
    private func selectDeselect2(_ singularassignment: String) {
        if selection2.contains(singularassignment) {
            selection2.remove(singularassignment)
        } else {
            selection2.insert(singularassignment)
        }
    }
    var body: some View {
        // NavigationView {
          //  VStack {
                //Text("hello")
                    //NavigationView {
        VStack {
            //Spacer()
                        Form {
                       //     Text("Before Tasks").font(.title)
                            Section(header: Text("Before Tasks").font(.system(size: 20))) {
                                List {
                                    HStack {
                                         Button(action: {
                                            if (!self.selection.contains("None")) {
                                                self.selection.removeAll()
                                                self.selectDeselect("None")
                                            }
                                             
                                         }) {
                                             Text("None")//.foregroundColor(.black)
                                         }
                                        
                                         if (self.selection.contains("None")) {
                                             Spacer()
                                             Image(systemName: "checkmark").foregroundColor(.blue)
                                         }
                                     }
                                    ForEach(self.beforeassignmenttimes,  id: \.self) { repeatoption in
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
                                                    Text(repeatoption)//.foregroundColor(.black)
                                                }
                                                if (self.selection.contains(repeatoption)) {
                                                    Spacer()
                                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                       //     Text("Before Break").font(.title)
                            Section(header: Text("Before End of Tasks").font(.system(size: 20))) {
                                List {
                                    HStack {
                                         Button(action: {
                                            if (!self.selection2.contains("None")) {
                                                self.selection2.removeAll()
                                                self.selectDeselect2("None")
                                            }
                                             
                                         }) {
                                             Text("None")//.foregroundColor(.black)
                                         }
                                        
                                         if (self.selection2.contains("None")) {
                                             Spacer()
                                             Image(systemName: "checkmark").foregroundColor(.blue)
                                         }
                                     }
                                    ForEach(self.beforeassignmenttimes,  id: \.self) { repeatoption in
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Button(action: {self.selectDeselect2(repeatoption)
                                                    if (self.selection2.count==0) {
                                                        self.selectDeselect2("None")
                                                    }
                                                    else if (self.selection2.contains("None")) {
                                                        self.selectDeselect2("None")
                                                    }
                                                    
                                                }) {
                                                    Text(repeatoption)//.foregroundColor(.black)
                                                }
                                                if (self.selection2.contains(repeatoption)) {
                                                    Spacer()
                                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
//                            Picker(selection: $selectedbeforeassignment, label: Text("Before Assignment")) {
//                                ForEach(0 ..< beforeassignmenttimes.count) {
//
//                                    if (self.beforeassignmenttimes[$0] == 0)
//                                    {
//                                        Text("None")
//                                    }
//                                    else
//                                    {
//                                        Text(String(self.beforeassignmenttimes[$0]) + " minutes")
//                                    }
//
//
//                                }
//                            }
//                            Picker(selection: $selectedbeforebreak, label: Text("Before Break")) {
//                                ForEach(0 ..< beforebreaktimes.count) {
//
//                                    if (self.beforebreaktimes[$0] == 0)
//                                    {
//                                        Text("None")
//                                    }
//                                    else
//                                    {
//                                        Text(String(self.beforebreaktimes[$0]) + " minutes")
//                                    }
//
//
//                                }
//                            }
//                            Toggle(isOn: $atassignmentstart) {
//                                Text("Assignment start")
//                            }
//                            Toggle(isOn: $atbreakstart) {
//                                Text("Break start")
//                            }
//                            Toggle(isOn: $atassignmentend) {
//                                Text("Assignment end")
//                            }
//                            Toggle(isOn: $atbreakend) {
//                                Text("Break end")
//                            }
                        }.navigationBarTitle("Notifications", displayMode: .inline)
        }.onAppear() {
            let defaults = UserDefaults.standard
            let array = defaults.object(forKey: "savedassignmentnotifications") as? [String] ?? ["None"]
            self.selection = Set(array)
            let array2 = defaults.object(forKey: "savedbreaknotifications") as? [String] ?? ["None"]
            self.selection2 = Set(array2)
        }.onDisappear() {
            let defaults = UserDefaults.standard
            let array = Array(self.selection)
            defaults.set(array, forKey: "savedassignmentnotifications")
            let array2 = Array(self.selection2)
            defaults.set(array2, forKey: "savedbreaknotifications")
            
            masterRunning.masterRunningNow = true
//            masterRunning.onlyNotifications = true
            print("Signal Sent.")
            print(masterRunning.onlyNotifications)
        }
                   // }
               // }//.navigationBarItems(leading: Text("H")).navigationBarTitle("Notifications", displayMode: .inline)
        //}
    }
}
