//
//  Today_s_Tasks.swift
//  Today's Tasks
//
//  Created by Charan Vadrevu on 02.04.21.
//  Copyright © 2021 Tejas Krishnan. All rights reserved.
//

import WidgetKit
import SwiftUI
import Foundation
import UIKit
import CoreData

//group.com.schedulingapp.tracr.widget

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    var managedObjectContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    var workingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.managedObjectContext
        return context
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.schedulingapp.tracr.widget")!
        let storeURL = containerURL.appendingPathComponent("ClassModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        let container = NSPersistentContainer(name: "ClassModel")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            }
        })
        
        
//        private let persistentContainer: NSPersistentContainer = {
//            let storeURL = FileManager.appGroupContainerURL.appendingPathComponent("DataModel.sqlite")
//            let container = NSPersistentContainer(name: "DataModel")
//            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
//            container.loadPersistentStores(completionHandler: { storeDescription, error in
//                if let error = error as NSError? {
//                    print(error.localizedDescription)
//                }
//            })
//            return container
//        }()
        
        
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//                WidgetCenter.shared.reloadAllTimelines()
//            } catch let error {
//                print("Error Save Oppty: \(error.localizedDescription)")
//            }
//        }
        
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        self.managedObjectContext.performAndWait {
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                    print("Main context saved")
                } catch (let error) {
                    print(error)
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    func saveWorkingContext(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Working context saved")
            saveContext()
        } catch (let error) {
            print(error)
            fatalError(error.localizedDescription)
        }
    }
}



extension TasksProvider {
    static let sharedDataFileURL: URL = {
        let appGroupIdentifier = "group.com.schedulingapp.tracr.widget"
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return url.appendingPathComponent("WidgetSAList.plist")
        }
        else {
            preconditionFailure("Expected a valid app group container")
        }
    }()
}





struct TasksProvider: TimelineProvider {
    @Environment(\.managedObjectContext) var managedObjectContext
        
    //all functions create and return entries as quickly as possible
    //all the data will be sent from this struct to the entries, which will then be sent to the View.
        //therefore, CoreData stuff will be from read here and sent as variables to the entry --> View.
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), isPlaceholder: true, headerText: "", largeBodyText: "", smallBodyText1: "", smallBodyText2: "", progressCount: 0, schedule: [TodaysScheduleEntry(taskName: "", className: "")])
    }

    //sometimes in the preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), isPlaceholder: false, headerText: "", largeBodyText: "", smallBodyText1: "", smallBodyText2: "", progressCount: 0, schedule: [TodaysScheduleEntry(taskName: "", className: "test")])
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var subassignmentlist: [Subassignmentnew] = []
        let moc = CoreDataStack.shared.managedObjectContext
//
//        var assignmentlistrequest: FetchRequest<Subassignmentnew>
//        let request = FetchRequest<Subassignmentnew>(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.assignmentduedate, ascending: true)])
//
//        var assignmentlist: FetchedResults<Subassignmentnew>{request.wrappedValue}

        
//        let request = FetchRequest<NSFetchRequestResult>(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.assignmentduedate, ascending: true)])
//        let request = NSFetchRequest<Subassignmentnew>(entityName: "Subassignmentnew")
//        let result = try! moc.fetch(request)

//        do {
//            let subassignmentlista = {assignmentlistrequest.wrappedValue}
//            let subassignmentlista = try moc.fetch(request)
//
//            subassignmentlist = subassignmentlista
//
//            print("asfsfsf")
//        } catch {
////            print("Failed to fetch: \(error)")
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
//        print(subassignmentlist.count)
//        fatalError(String(subassignmentlist.count))
//
//        print(assignmentlist.count)
//        fatalError(String(assignmentlist.count))
        
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 1 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset*10, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, isPlaceholder: false, headerText: "NOW", largeBodyText: "Eat Chicken long longer longest", smallBodyText1: "28 minutes left", smallBodyText2: "", progressCount: 53, schedule: [TodaysScheduleEntry(taskName: "Eat Something (long example so that text is cut appropriately)", className: "IDK"), TodaysScheduleEntry(taskName: "Just Do It.", className: "Nike"), TodaysScheduleEntry(taskName: "OKAY", className: "sdf")])
            
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd) //maybe change to .never?
        completion(timeline)
    }
}

struct TodaysScheduleEntry {
    var taskName: String
    var className: String
    //left out for now
//    var classGradient: LinearGradient
}

struct SimpleEntry: TimelineEntry {
    //entry Date
    let date: Date
    
    //if isPlaceholder, then display the animated RoundedRectangles
    let isPlaceholder: Bool
    
    //normally headerText = "NOW" or "UPCOMING", but alternatively could be "DEADLINE"...
    //could later be used for other notifications – new GClassroom assignments...
    let headerText: String
    
    //normally largeBodyText = "[TASK NAME]", but alternatively could be something else
    let largeBodyText: String
    
    //normally smallBodyText1 = "[Time Left]", but alternatively could be something else
    let smallBodyText1: String
    
    //normally not used, but can be used as largeBodyText2 = "[Start - End Time]"...
    let smallBodyText2: String
    
    //if progress bar shown, then progressCount relevant (medium and large views)
    let progressCount: Int64
    
    //background gradient, normally based on class colours
    //left out for now
//    let bgGradient: LinearGradient
    
    //not used if family != .large, else uses taskName, className, and classGradient properties
    let schedule: [TodaysScheduleEntry]
}

struct TodaysTasksSmallPlaceholderView: View {
    let geometry: GeometryProxy
    
    let placeholderGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 15).opacity(0.07)
                
                Spacer()
            }
            
            Spacer()
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.18, height: 26).opacity(0.12)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.48, height: 26).opacity(0.12)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.28, height: 26).opacity(0.12)
                    
                    Spacer()
                }
            }
                        
            Spacer()
            
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.4, height: 15).opacity(0.09)

                Spacer()
            }
        }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
    }
}

struct TodaysTasksSmallView: View {
    var entry: TasksProvider.Entry
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
//    let request = FetchRequest<Subassignmentnew>(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.assignmentduedate, ascending: true)])
//
//    var assignmentlist: FetchedResults<Subassignmentnew>{request.wrappedValue}

    var itemsCount: Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subassignmentnew")
        
        do {
            return try CoreDataStack.shared.managedObjectContext.count(for: request)
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
//    var subassignmentlist: [Subassignmentnew] = []
//    let moc = CoreDataStack.shared.managedObjectContext
//
//        var assignmentlistrequest: FetchRequest<Subassignmentnew>
//        let request = FetchRequest<Subassignmentnew>(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.assignmentduedate, ascending: true)])
//
//        var assignmentlist: FetchedResults<Subassignmentnew>{request.wrappedValue}

    
//    let request = FetchRequest<NSFetchRequestResult>(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.assignmentduedate, ascending: true)])
//    let request = NSFetchRequest<Subassignmentnew>(entityName: "Subassignmentnew")
//    let result = try! moc.fetch(request)
    
//    do {
//        let subassignmentlista = try moc.fetch(request)
//
//        subassignmentlist = subassignmentlista
//
//        print("asfsfsf")
//    } catch {
////            print("Failed to fetch: \(error)")
//    }
    
    
    var body: some View {
        GeometryReader { geometry in
            if entry.isPlaceholder {
                TodaysTasksSmallPlaceholderView(geometry: geometry)
            }
            
            else {
                VStack {
                    HStack {
                        Text(String(self.itemsCount))
                        Text(entry.headerText).fontWeight(.light).font(.caption2)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(entry.largeBodyText).fontWeight(.bold).font(.system(size: 25)).lineLimit(3).allowsTightening(true)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(entry.smallBodyText1).fontWeight(.regular).font(.caption2)
                        Spacer()
                        Text(entry.smallBodyText2).fontWeight(.light).font(.caption2)
                    }
                }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TodaysTasksMediumPlaceholderView: View {
    let geometry: GeometryProxy
    
    let placeholderGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 15).opacity(0.07)

                Spacer()
            }
            
            Spacer()
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.18, height: 30).opacity(0.12)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.48, height: 30).opacity(0.12)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 16).opacity(0.09)

                Spacer()
            }
            
            Spacer()
            
            ZStack {
                HStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientC")).frame(width: (geometry.size.width - 32), height: 15)
                    
                    Spacer()
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientD")).frame(width: CGFloat(0.78 * (geometry.size.width - 32)), height: 15)
                    
                    Spacer()
                }
            }.opacity(0.15)
        }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
    }
}


struct TodaysTasksMediumView: View {
    var entry: TasksProvider.Entry
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader { geometry in
            if entry.isPlaceholder {
                TodaysTasksMediumPlaceholderView(geometry: geometry)
            }
            
            else {
                VStack {
                    HStack {
                        Text(entry.headerText).fontWeight(.light).font(.caption2)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(entry.largeBodyText).fontWeight(.bold).font(.system(size: 25)).lineLimit(2).allowsTightening(true)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(entry.smallBodyText1).fontWeight(.regular).font(.caption2)
                        Spacer()
                        Text(entry.smallBodyText2).fontWeight(.light).font(.caption2)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: (geometry.size.width - 24), height: 15)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("progressBlue")).frame(width:  CGFloat(CGFloat(entry.progressCount)/100 * (geometry.size.width - 24)), height: 15, alignment: .leading)
                            
                            Spacer()
                        }
                    }
                }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TodaysTasksLargePlaceholderView: View {
    let geometry: GeometryProxy
    
    let placeholderGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        VStack {
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 15).opacity(0.07)

                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.18, height: 30).opacity(0.12)
                        
                        Spacer()
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/1.48, height: 30).opacity(0.12)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/4, height: 16).opacity(0.09)

                    Spacer()
                }
                
                Spacer()
                
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientC")).frame(width: (geometry.size.width - 32), height: 15)
                        
                        Spacer()
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("gradientD")).frame(width: CGFloat(0.78 * (geometry.size.width - 32)), height: 15)
                        
                        Spacer()
                    }
                }.opacity(0.15)
            }.frame(height: (geometry.size.height * 0.35))
            
            Spacer()
            
            Divider().padding(.vertical, 5)
            
            Spacer()
            
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/3, height: 28).opacity(0.10)
                    
                    Spacer()
                }
                                    
                ForEach(0..<3, id: \.self) { scheduleEntryIndex in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.07)
                        }

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(self.placeholderGradient).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.07)
                        }
                    }
                }
            }
        }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
    }
}

struct TodaysTasksLargeView: View {
    var entry: TasksProvider.Entry
    @Environment(\.colorScheme) var colorScheme: ColorScheme
        
    var body: some View {
        GeometryReader { geometry in
            if entry.isPlaceholder {
                TodaysTasksLargePlaceholderView(geometry: geometry)
            }
            
            else {
                VStack {
                    VStack {
                        HStack {
                            Text(entry.headerText).fontWeight(.light).font(.caption2)
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text(entry.largeBodyText).fontWeight(.bold).font(.system(size: 25)).lineLimit(2).allowsTightening(true)
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text(entry.smallBodyText1).fontWeight(.regular).font(.caption2)
                            Spacer()
                            Text(entry.smallBodyText2).fontWeight(.light).font(.caption2)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white).frame(width: (geometry.size.width - 32), height: 15)
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("progressBlue")).frame(width:  CGFloat(CGFloat(entry.progressCount)/100 * (geometry.size.width - 32)), height: 15, alignment: .leading)
                                
                                Spacer()
                            }
                        }
                    }.frame(height: (geometry.size.height * 0.35))
                    
                    Spacer()
                    
                    Divider().padding(.vertical, 5)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text("Today's Tasks").fontWeight(.semibold).font(.title3)
                            Spacer()
                        }
                                            
                        ForEach(0..<3, id: \.self) { scheduleEntryIndex in
                            HStack {
                                ZStack {
                                    let n = 2 * scheduleEntryIndex

                                    if (n < entry.schedule.count) {
                                        VStack {
                                            HStack {
                                                Text(entry.schedule[n].taskName).fontWeight(.semibold).font(.body)
                                                Spacer()
                                            }.padding(.top, 6)
                                            
                                            HStack {
                                                Text(entry.schedule[n].className).fontWeight(.light).font(.callout)
                                                Spacer()
                                            }
                                            
                                            Spacer()
                                        }.frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8)
                                    }
                                    
                                    else {
                                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.03)
                                    }
                                }

                                Spacer()

                                ZStack {
                                    let n = 2 * scheduleEntryIndex + 1

                                    if (n < entry.schedule.count) {
                                        VStack {
                                            HStack {
                                                Text(entry.schedule[n].taskName).fontWeight(.semibold).font(.body)
                                                Spacer()
                                            }.padding(.top, 6)
                                            
                                            HStack {
                                                Text(entry.schedule[n].className).fontWeight(.light).font(.callout)
                                                Spacer()
                                            }
                                            
                                            Spacer()
                                        }.frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8)
                                    }
                                    
                                    else {
                                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("gradientD"), Color("gradientC")]), startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: (geometry.size.width-32)/2, height: (geometry.size.height-32)/8).opacity(0.07)
                                    }
                                }
                            }
                        }
                    }
                }.padding(.all, 16).background(LinearGradient(gradient: Gradient(colors: [Color("gradientA"), Color("gradientB")]), startPoint: .top, endPoint: .bottom)).frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct TodaysTasksNAView: View {
    var body: some View {
        Text("An error occured. Please report this to tracrteam@gmail.com.")
        Text("Error 1605. Widget Family Unknown.")
    }
}

struct TodaysTasksEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: TasksProvider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
            case .systemSmall: TodaysTasksSmallView(entry: self.entry)
            case .systemMedium: TodaysTasksMediumView(entry: self.entry)
            case .systemLarge: TodaysTasksLargeView(entry: self.entry)
            default: TodaysTasksNAView()
        }
    }
}

@main
struct TodaysTasks: Widget {
    let kind: String = "Today's Tasks"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasksProvider()) { entry in
            TodaysTasksEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("Keep track of today's ongoing and upcoming tasks.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TodaysTasksPreviews: PreviewProvider {
    static var previews: some View {
        TodaysTasksEntryView(entry: SimpleEntry(date: Date(), isPlaceholder: false, headerText: "", largeBodyText: "", smallBodyText1: "", smallBodyText2: "", progressCount: 0, schedule: [TodaysScheduleEntry(taskName: "", className: "")]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
