//
//  FreeTimeView.swift
//  SchedulingApp
//
//  Created by Charan Vadrevu on 02.01.21.
//  Copyright © 2021 Tejas Krishnan. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class FreeTimeEditingView: ObservableObject {
    @Published var editingmode: Bool = true
    @Published var showsavebuttons: Bool = false
    @Published var addingmode: Bool = false
}

struct FreeTimeIndividual: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @State var yoffset: CGFloat
    @State var height: CGFloat
    @State var dayvals: [Bool]
    @State var starttime: Date
    @State var endtime: Date
    @Binding var editingmode: Bool
    @Binding var showsavebuttons: Bool
    @State var freetimeobject: Freetime
    @State var draggingup: Bool = false
    @State var draggingdown: Bool = false
    @State var changingheightallowed = true

    @State var xoffset: CGFloat = 0
    @State var inmotion: Bool = false
    
    func getmaxtop() -> CGFloat {
        var maxdate = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0))
        for freetime in freetimelist {
            if (freetime.monday == dayvals[0] && freetime.tuesday == dayvals[1] && freetime.wednesday == dayvals[2] && freetime.thursday == dayvals[3] && freetime.friday == dayvals[4] && freetime.saturday == dayvals[5] && freetime.sunday == dayvals[6]) {
                if (freetime.tempenddatetime > maxdate && freetime.tempenddatetime <= freetimeobject.tempstartdatetime) {
                    maxdate = freetime.tempenddatetime
                }
            }
        }
//        print(maxdate.description, Calendar.current.startOfDay(for: maxdate).description)
//        print("maxtop", CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: maxdate), to: maxdate).minute!)*60.35/60)
        return CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: maxdate), to: maxdate).minute!)*60.35/60
    }
    
    func getmaxbottom() -> CGFloat {
        var mindate = Date(timeInterval: 3600*24-1, since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
        
        for freetime in freetimelist {
            if (freetime.monday == dayvals[0] && freetime.tuesday == dayvals[1] && freetime.wednesday == dayvals[2] && freetime.thursday == dayvals[3] && freetime.friday == dayvals[4] && freetime.saturday == dayvals[5] && freetime.sunday == dayvals[6]) {
                if (freetime.tempstartdatetime < mindate && freetime.tempstartdatetime >= freetimeobject.tempenddatetime) {
                    mindate = freetime.tempstartdatetime
                }
            }
        }
//        print(mindate.description)
//        print("maxbottom",  CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: mindate), to: mindate).minute!)*60.35/60
//)
        if (mindate == Date(timeInterval: 3600*24-1, since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))) {
            return CGFloat(24*60.35)
        }
        
        return CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: mindate), to: mindate).minute!)*60.35/60
    }
    func getoffset() -> CGFloat {
//        if (self.editingmode)
//        {
//            var counter = 0
//            for freetime in freetimelist
//            {
//                if (freetime.monday == dayvals[0] && freetime.tuesday == dayvals[1] && freetime.wednesday == dayvals[2] && freetime.thursday == dayvals[3] && freetime.friday == dayvals[4] && freetime.saturday == dayvals[5] && freetime.sunday == dayvals[6])
//                {
//                    if (freetime.startdatetime == self.starttime)
//                    {
//                        return CGFloat(counter)*110
//                    }
//                    counter += 1
//                }
//
//            }
//            return 0
//
//        }
//        else
//        {
            return self.yoffset
       // }
    }
    func getHeight() -> CGFloat {
//        if (self.editingmode)
//        {
//            return 100
//        }
//        else
//        {
            return self.height
   //     }
    }
    func getstarttext() -> String {
        let y = Int(round(100*(self.yoffset)))
        
       // print("Starttime: " + "\(Double(y%6035)/Double(6035)*4)")
        var stringitya = String(format: "%f", (self.yoffset)/60.35)[0..<2]
        var stringityb =  "\(Int(Double(y%6035)/Double(6035)*4+0.01)*15)"
            
        if (stringitya.contains(".")) {
            stringitya = "0" + String(stringitya[0..<1])
        }
        
        if (stringityb.count == 1) {
            stringityb += "0"
        }
        
        return stringitya + ":" + stringityb
    }
    
    func getendtext() -> String {
        let y = Int(round(100*(self.yoffset+self.height)))
        var stringitya = String(format: "%f", (self.yoffset + self.height)/60.35)[0..<2]
        var stringityb =  "\(Int(Double(y%6035)/Double(6035)*4 + 0.01)*15)"
            
        if (stringitya.contains(".")) {
            stringitya = "0" + String(stringitya[0..<1])
        }
        
        if (stringityb.count == 1) {
            stringityb += "0"
        }
        
        return stringitya + ":" + stringityb
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 0, style: .continuous).fill(self.draggingup ? Color("freetimeblue") : Color("freetimeblue")).frame(width: UIScreen.main.bounds.size.width - 80, height: 10).gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                        if (!self.editingmode) {
                            withAnimation(.spring()) {
                                self.showsavebuttons = false
                            }

                            if self.yoffset >= 0 && self.height >= 30.175 {
                                if !(self.yoffset == 0 && value.translation.height < 0) {
                                    if (self.changingheightallowed) {
                                        self.height = self.height - value.translation.height
                                    }
                                    self.yoffset = self.yoffset + value.translation.height
                                }
                            }
                            
                            if self.height < 30.175 {
                                self.height = 30.175
                            }
                            
                            withAnimation(.spring()) {
                                self.draggingup = true
                            }
                            
                            if self.yoffset < 0 {
                                self.yoffset = 0
                            }
                            
                            if (self.yoffset < getmaxtop()) {
                                self.yoffset = getmaxtop()
                                self.changingheightallowed = false
                            }
                            else {
                                self.changingheightallowed = true
                            }
                            
                            if (self.yoffset+self.height > getmaxbottom()) {
                                self.yoffset = getmaxbottom()-self.height
                            }
                        }
                    }.onEnded {
                        _ in
                        if (!self.editingmode) {
                            withAnimation(.spring()) {
                                self.showsavebuttons = true
                            }
                            
                            withAnimation(.spring()) {
                                self.draggingup = false
                            }
                            
                            let roundedval = CGFloat(Double(Int(self.yoffset/(15.09) + 0.5))*15.09) - self.yoffset
                            self.yoffset += roundedval
                            self.height -= roundedval
                            let y = Int(round(100*(self.yoffset)))
                            let starttimeval = Int((self.yoffset)/60.35)*3600 + Int(Double(y%6035)/Double(6035)*4)*15*60
                            freetimeobject.tempstartdatetime = Date(timeInterval: TimeInterval(starttimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                            
                            let x = Int(round(100*((self.yoffset+self.height))))
                            let endtimeval =  Int(((self.yoffset+self.height))/60.35)*3600 + Int(Double(x%6035)/Double(6035)*4)*15*60
                            freetimeobject.tempenddatetime =  Date(timeInterval: TimeInterval(endtimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                            do {
                                try self.managedObjectContext.save()
                                //print("AssignmentTypes rangemin/rangemax changed")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    })
                    
                    Image(systemName: "minus").resizable().foregroundColor(Color.white).frame(width: 45, height: 4).opacity(self.draggingup ? 1 : 0)
                }.frame(width: UIScreen.main.bounds.size.width - 80, height: 10)
                
                RoundedRectangle(cornerRadius:  0, style: .continuous).fill(Color("freetimeblue")).frame(width: UIScreen.main.bounds.size.width - 80, height: self.getHeight() - 20).gesture(DragGesture(minimumDistance: self.editingmode ? 10 : 0, coordinateSpace: .local).onChanged { value in
                    if (!self.editingmode) {
                        withAnimation(.spring()) {
                            self.showsavebuttons = false
                        }
                        if self.yoffset >= 0 {
                            self.yoffset = self.yoffset + value.translation.height
                        }
                      //  self.xoffset += value.translation.width
                        if self.yoffset < 0 {
                            self.yoffset = 0
                        }
                        
                        if (self.yoffset < getmaxtop()) {
                            self.yoffset = getmaxtop()
                        }
                        
                        if (self.yoffset+self.height > getmaxbottom()) {
                            self.yoffset = getmaxbottom()-self.height
                        }
                        
                        if ((self.yoffset+self.height)/60.35 >= 24) {
                            self.yoffset = 24*60.35-self.height
                        }
                        
                        withAnimation(.spring()) {
                            self.draggingup = true
                            self.draggingdown = true
                        }

                        withAnimation(.easeInOut(duration: 0.1), {
                            self.inmotion = true
                        })
                    }
                    
                    else {
//                        if self.xoffset < 40 {
                            self.xoffset += value.translation.width
//                        }
                    }
                }.onEnded { _ in
                    if (!self.editingmode)
                    {
                        withAnimation(.spring())
                        {
                            self.showsavebuttons = true
                        }
                        withAnimation(.easeInOut(duration: 0.1), {
                            self.inmotion = false
                        })
                        withAnimation(.spring())
                        {
                            self.xoffset = 0
                            self.draggingup = false
                            self.draggingdown = false
                        }
                        
                        self.yoffset = CGFloat(Double(Int(self.yoffset/(15.09) + 0.5))*15.09)
                        let y = Int(round(100*(self.yoffset)))
                        let starttimeval = Int((self.yoffset)/60.35)*3600 + Int(Double(y%6035)/Double(6035)*4)*15*60
                        freetimeobject.tempstartdatetime = Date(timeInterval: TimeInterval(starttimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                        
                        let x = Int(round(100*((self.yoffset+self.height))))
                        let endtimeval =  Int(((self.yoffset+self.height))/60.35)*3600 + Int(Double(x%6035)/Double(6035)*4)*15*60
                        freetimeobject.tempenddatetime =  Date(timeInterval: TimeInterval(endtimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                        do {
                            try self.managedObjectContext.save()
                            //print("AssignmentTypes rangemin/rangemax changed")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    else {
                        if (self.xoffset < -1/2 * UIScreen.main.bounds.size.width) {
                            withAnimation(.spring()) {
                                self.xoffset = -UIScreen.main.bounds.size.width
                            }
                            
                            for (index, freetime) in freetimelist.enumerated() {
                                if (freetime.startdatetime == self.starttime && freetime.enddatetime == self.endtime) {
                                    if (freetime.monday == dayvals[0] && freetime.tuesday == dayvals[1] && freetime.wednesday == dayvals[2] && freetime.thursday == dayvals[3] && freetime.friday == dayvals[4] && freetime.saturday == dayvals[5] && freetime.sunday == dayvals[6]) {

                                        self.managedObjectContext.delete(self.freetimelist[index])

                                        do {
                                            try self.managedObjectContext.save()
                                            //print("AssignmentTypes rangemin/rangemax changed")
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                        
                        withAnimation(.spring()) {
                            self.xoffset = 0
                        }
                    }
                })
                
                ZStack {
                    RoundedRectangle(cornerRadius: 0, style: .continuous).fill(self.draggingdown ? Color("freetimeblue") : Color("freetimeblue")).frame(width: UIScreen.main.bounds.size.width - 80, height: 10).gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                        if (!self.editingmode) {
                            withAnimation(.spring()) {
                                self.showsavebuttons = false
                            }
                            
                            if self.height >= 30.175 {
                                self.height = self.height + value.translation.height
                            }
                            
                            if self.height < 30.175 {
                                self.height = 30.175
                            }
                            
                            if (self.yoffset+self.height > getmaxbottom()) {
                                self.height = getmaxbottom() - self.yoffset
                            }
                            
                            if ((self.yoffset+self.height)/60.35 >= 24) {
                                self.height = 24*60.35-self.yoffset
                            }
                            
                            withAnimation(.spring()) {
                                self.draggingdown = true
                            }
                        }
                    }.onEnded {
                        _ in
                        if (!self.editingmode) {
                            withAnimation(.spring()) {
                                self.showsavebuttons = true
                            }
                            withAnimation(.spring()) {
                                self.draggingdown = false
                            }
                            self.height = CGFloat(Double(Int(self.height/(15.09) + 0.5))*15.09)
                            self.height = max(self.height, 30.175)
                            
                            let y = Int(round(100*(self.yoffset)))
                            let starttimeval = Int((self.yoffset)/60.35)*3600 + Int(Double(y%6035)/Double(6035)*4)*15*60
                            freetimeobject.tempstartdatetime = Date(timeInterval: TimeInterval(starttimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                            
                            let x = Int(round(100*((self.yoffset+self.height))))
                            let endtimeval =  Int(((self.yoffset+self.height))/60.35)*3600 + Int(Double(x%6035)/Double(6035)*4)*15*60
                            freetimeobject.tempenddatetime =  Date(timeInterval: TimeInterval(endtimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
                            
                            do {
                                try self.managedObjectContext.save()
                                //print("AssignmentTypes rangemin/rangemax changed")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    })
                    
                    Image(systemName: "minus").resizable().foregroundColor(Color.white).frame(width: 45, height: 4).opacity(self.draggingdown ? 1 : 0)
                }
            }.cornerRadius(8).offset(x: 20 + self.xoffset, y: self.getoffset())

            HStack {
                Text(self.getstarttext() + " - " + self.getendtext()).foregroundColor(.white).offset(y: self.getoffset() - (self.getHeight()/2) + 15).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 65)
                Spacer()
            }.offset(x: self.xoffset)
            
            ZStack {
                RoundedRectangle(cornerRadius: 0, style: .continuous).fill(Color.red).frame(width: UIScreen.main.bounds.size.width, height: self.getHeight()).offset(x: UIScreen.main.bounds.size.width + self.xoffset, y: self.getoffset())
                Text("Delete").foregroundColor(Color.white).offset(x: self.xoffset > -80 ? UIScreen.main.bounds.size.width/2+40+self.xoffset : UIScreen.main.bounds.size.width/2-40, y: self.getoffset() )
            }
        }
    }
}

struct ObstructingFreeTimes: View {
    @Binding var ObstructingFreeTimeObjectsWhenAdding: [Freetime]
    
    var freetime: Freetime
    
    @Binding var PossibleDateBrackets: [[CGFloat]]
    
    func appendToObstructingList() -> Void {
        ObstructingFreeTimeObjectsWhenAdding.append(freetime)
        PossibleDateBrackets = updateObstructions()
        print(PossibleDateBrackets)
    }
    
    func removeFromObstructingList() -> Void {
        ObstructingFreeTimeObjectsWhenAdding.remove(at: ObstructingFreeTimeObjectsWhenAdding.firstIndex(of: freetime) ?? 0)
        PossibleDateBrackets = updateObstructions()
    }
    
    func DateObjectToCGFloat(date: Date) -> CGFloat {
        return CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: date), to: date).minute!)*60.35/60
    }
    
    func updateObstructions() -> [[CGFloat]] {
        ObstructingFreeTimeObjectsWhenAdding.sort{ $0.startdatetime < $1.startdatetime }
        
        if ObstructingFreeTimeObjectsWhenAdding.count > 0 {
            var freetimeBlocks: [[Date]] = [[ObstructingFreeTimeObjectsWhenAdding[0].startdatetime, ObstructingFreeTimeObjectsWhenAdding[0].enddatetime]]
            
            for ObstructingFreetime in ObstructingFreeTimeObjectsWhenAdding {
                var indextoChange = 0
                var shouldAdd = false
                
                for (index, freetimeBlock) in freetimeBlocks.enumerated() {
                    if ObstructingFreetime.startdatetime >= Date(timeInterval: TimeInterval(1800), since: freetimeBlock[1]) {
                        shouldAdd = true
                    }
                    
                    else {
                        shouldAdd = false
                        indextoChange = index
                        break
                    }
                }

                if shouldAdd {
                    freetimeBlocks.append([ObstructingFreetime.startdatetime, ObstructingFreetime.enddatetime])
                }
                
                else {
                    if ObstructingFreetime.enddatetime > freetimeBlocks[indextoChange][1] {
                        freetimeBlocks[indextoChange][1] = ObstructingFreetime.enddatetime
                    }
                }
            }
            
            var PossibleDateBrackets: [[CGFloat]] = []
            
            if freetimeBlocks.count > 0 {
                if freetimeBlocks[0][0] >= Date(timeInterval: TimeInterval(1800), since: Calendar.current.startOfDay(for: freetimeBlocks[0][0])) {
                    PossibleDateBrackets.append([0, DateObjectToCGFloat(date: freetimeBlocks[0][0])])
                }
                
                if freetimeBlocks[freetimeBlocks.count - 1][1] <= Date(timeInterval: TimeInterval(84600), since: Calendar.current.startOfDay(for: Date(timeInterval: TimeInterval(-1), since: freetimeBlocks[freetimeBlocks.count - 1][1]))) {
                    PossibleDateBrackets.append([DateObjectToCGFloat(date: freetimeBlocks[freetimeBlocks.count - 1][1]), CGFloat(24 * 60.35)])
                }
            }
            
            if freetimeBlocks.count > 1 {
                for i in 0..<(freetimeBlocks.count - 1) {
                    PossibleDateBrackets.append([DateObjectToCGFloat(date: freetimeBlocks[i][1]), DateObjectToCGFloat(date: freetimeBlocks[i+1][0])])
                }
            }

            return PossibleDateBrackets
        }
        
        else {
            return [[CGFloat(0), CGFloat(24 * 60.35)]]
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .strokeBorder(Color("freetimeblue"), style: StrokeStyle(lineWidth: 3, lineCap: .square, lineJoin: .round, dash: [12]))
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("freetimeblue")).opacity(0.28))
            .frame(width: UIScreen.main.bounds.size.width - 80, height: CGFloat(Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!)*60.35/60)
            .offset(x: -15, y: CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: freetime.startdatetime), to: freetime.startdatetime).minute!)*60.35/60)
            .onAppear(perform: appendToObstructingList)
            .onDisappear(perform: removeFromObstructingList)
    }
}

struct FreeTimeToAdd: View {
    @State var pdb: [CGFloat]
    @Binding var addFreeTimeCGFloats: [CGFloat]
    
    @Binding var showsavebuttons: Bool

    @State var draggingup: Bool = false
    @State var draggingdown: Bool = false
    
    @State var yoffset: CGFloat = 0
    @State var height: CGFloat = 0
    
    @State var changingheightallowed: Bool = true
    //remember to save yoffset and height to addFreeTimeCGFloats
    func getmaxtop() -> CGFloat {
        return pdb[0]
    }
    
    func getmaxbottom() -> CGFloat {
        return pdb[1]
    }
    
    func getstarttext() -> String {
        let y = Int(round(100*(self.yoffset)))
        
        var stringitya = String(format: "%f", (self.yoffset)/60.35)[0..<2]
        var stringityb =  "\(Int(Double(y%6035)/Double(6035)*4+0.01)*15)"
            
        if (stringitya.contains(".")) {
            stringitya = "0" + String(stringitya[0..<1])
        }
        
        if (stringityb.count == 1) {
            stringityb += "0"
        }
        
        return stringitya + ":" + stringityb
    }

    func getendtext() -> String {
        let y = Int(round(100*(self.yoffset + self.height)))
        var stringitya = String(format: "%f", (self.yoffset + self.height)/60.35)[0..<2]
        var stringityb =  "\(Int(Double(y%6035)/Double(6035)*4 + 0.01)*15)"
            
        if (stringitya.contains(".")) {
            stringitya = "0" + String(stringitya[0..<1])
        }
        
        if (stringityb.count == 1) {
            stringityb += "0"
        }
        
        return stringitya + ":" + stringityb
    }
    
    func getHeight() -> CGFloat {
        return self.height
    }
    
    var body: some View {
        if self.addFreeTimeCGFloats.isEmpty || self.addFreeTimeCGFloats[0] < (self.pdb[0] - 5) || self.addFreeTimeCGFloats[1] > (self.pdb[1] + 5) {
            Button(action:
            {
                print(addFreeTimeCGFloats, pdb)
                self.addFreeTimeCGFloats = [self.pdb[0], CGFloat(self.pdb[0] + 60.35/2)]
                self.yoffset = self.addFreeTimeCGFloats[0]
                self.height = self.addFreeTimeCGFloats[1] - self.addFreeTimeCGFloats[0]
                
            })
            {
                ZStack {
                    Rectangle()
                        .strokeBorder(Color.green, style: StrokeStyle(lineWidth: 3))
                        .background(Rectangle().fill(Color.green).opacity(0.43))
                        .frame(width: UIScreen.main.bounds.size.width - 80, height: self.pdb[1] - self.pdb[0])
                    VStack {
                        Image(systemName: "plus").resizable().foregroundColor(Color.green).frame(width: 20, height: 20)
                    }
                }
            }.offset(x: -15, y: self.pdb[0])
        }

        else {
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0, style: .continuous).fill(Color.green).frame(width: UIScreen.main.bounds.size.width - 80, height: 10).gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                                withAnimation(.spring()) {
                                    self.showsavebuttons = false
                                }

                                if self.yoffset >= 0 && self.height >= 30.175 {
                                    if !(self.yoffset == 0 && value.translation.height < 0) {
                                        if (self.changingheightallowed) {
                                            self.height = self.height - value.translation.height
                                        }
                                        self.yoffset = self.yoffset + value.translation.height
                                    }
                                }
                                
                                if self.height < 30.175 {
                                    self.height = 30.175
                                }
                                
                                withAnimation(.spring()) {
                                    self.draggingup = true
                                }
                                
                                if self.yoffset < 0 {
                                    self.yoffset = 0
                                }
                                
                                if (self.yoffset < getmaxtop()) {
                                    self.yoffset = getmaxtop()
                                    self.changingheightallowed = false
                                }
                                
                                else {
                                    self.changingheightallowed = true
                                }
                                
                                if (self.yoffset+self.height > getmaxbottom()) {
                                    self.yoffset = getmaxbottom() - self.height
                                }
                        }.onEnded { _ in
                            withAnimation(.spring()) {
                                self.showsavebuttons = true
                            }
                            
                            withAnimation(.spring()) {
                                self.draggingup = false
                            }
                            
                            let roundedval = CGFloat(Double(Int(self.yoffset/(15.09) + 0.5))*15.09) - self.yoffset
                            self.yoffset += roundedval
                            self.height -= roundedval
                            
                            self.addFreeTimeCGFloats[0] = self.yoffset
                            self.addFreeTimeCGFloats[1] = self.yoffset + self.height
                        })
                        
                        Image(systemName: "minus").resizable().foregroundColor(Color.white).frame(width: 45, height: 4).opacity(self.draggingup ? 1 : 0)
                    }.frame(width: UIScreen.main.bounds.size.width - 80, height: 10)
                    
                    RoundedRectangle(cornerRadius:  0, style: .continuous).fill(Color.green).frame(width: UIScreen.main.bounds.size.width - 80, height: self.getHeight() - 20).gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                        withAnimation(.spring()) {
                            self.showsavebuttons = false
                        }
                        
                        if self.yoffset >= 0 {
                            self.yoffset = self.yoffset + value.translation.height
                        }

                        if self.yoffset < 0 {
                            self.yoffset = 0
                        }
                        
                        if (self.yoffset < getmaxtop()) {
                            self.yoffset = getmaxtop()
                        }
                        
                        if (self.yoffset+self.height > getmaxbottom()) {
                            self.yoffset = getmaxbottom()-self.height
                        }
                        
                        if ((self.yoffset+self.height)/60.35 >= 24) {
                            self.yoffset = 24*60.35-self.height
                        }
                        
                        withAnimation(.spring()) {
                            self.draggingup = true
                            self.draggingdown = true
                        }
                    }.onEnded { _ in
                        withAnimation(.spring()) {
                            self.showsavebuttons = true
                        }
                        
                        withAnimation(.spring()) {
                            self.draggingup = false
                            self.draggingdown = false
                        }
                        
                        self.yoffset = CGFloat(Double(Int(self.yoffset/(15.09) + 0.5))*15.09)
                        
                        self.addFreeTimeCGFloats[0] = self.yoffset
                        self.addFreeTimeCGFloats[1] = self.yoffset + self.height
                    })
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 0, style: .continuous).fill(Color.green).frame(width: UIScreen.main.bounds.size.width - 80, height: 10).gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                            withAnimation(.spring()) {
                                self.showsavebuttons = false
                            }
                            
                            if self.height >= 30.175 {
                                self.height = self.height + value.translation.height
                            }
                            
                            if self.height < 30.175 {
                                self.height = 30.175
                            }
                            
                            if (self.yoffset+self.height > getmaxbottom()) {
                                self.height = getmaxbottom() - self.yoffset
                            }
                            
                            if ((self.yoffset+self.height)/60.35 >= 24) {
                                self.height = 24*60.35-self.yoffset
                            }
                            
                            withAnimation(.spring()) {
                                self.draggingdown = true
                            }
                        }.onEnded { _ in
                            withAnimation(.spring()) {
                                self.showsavebuttons = true
                            }
                            
                            withAnimation(.spring()) {
                                self.draggingdown = false
                            }
                            
                            self.height = CGFloat(Double(Int(self.height/(15.09) + 0.5))*15.09)
                            self.height = max(self.height, 30.175)
                            
                            self.addFreeTimeCGFloats[0] = self.yoffset
                            self.addFreeTimeCGFloats[1] = self.yoffset + self.height
                        })
                        
                        Image(systemName: "minus").resizable().foregroundColor(Color.white).frame(width: 45, height: 4).opacity(self.draggingdown ? 1 : 0)
                    }
                }.cornerRadius(8).offset(x: 20, y: self.yoffset)

                HStack {
                    Text(self.getstarttext() + " - " + self.getendtext()).foregroundColor(.white).offset(y: self.yoffset - (self.getHeight()/2) + 15).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 65)
                    Spacer()
                }
            }
        }
    }
}


struct WorkHours: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var dayslist: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State private var selection: Set<String> = ["Monday"]
    @State private var addingselection: Set<String> = ["Monday"]
    @ObservedObject var freetimeediting: FreeTimeEditingView = FreeTimeEditingView()

    @State var ObstructingFreeTimeObjectsWhenAdding: [Freetime] = []
    
    @State var rotationdegree = 20.0
    
    @State var PossibleDateBrackets: [[CGFloat]] = [[CGFloat(0), CGFloat(24 * 60.35)]]
    @State var addFreeTimeCGFloats: [CGFloat] = []
    
    @State var pressing: Bool = false
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @State var refreshID = UUID()
    
    private func selectDeselect(_ singularassignment: String) {
        selection.removeAll()
        selection.insert(singularassignment)
        
        addingselection.removeAll()
        addingselection.insert(singularassignment)
    }
    
    private func addingSelectDeselect(_ singularassignment: String) {
        if addingselection.contains(singularassignment) {
            if addingselection.count > 1 {
                addingselection.remove(singularassignment)
            }
        } else {
            addingselection.insert(singularassignment)
        }
    }

    func getdisplayval(freetimeval: Freetime) -> Bool {
        if (selection.contains("Monday")) {
            return freetimeval.monday
        }
        
        else if (selection.contains("Tuesday")) {
            return freetimeval.tuesday
        }
        
        else if (selection.contains("Wednesday")) {
            return freetimeval.wednesday
        }
        
        else if (selection.contains("Thursday")) {
            return freetimeval.thursday
        }
        
        else if (selection.contains("Friday")) {
            return freetimeval.friday
        }
        
        else if (selection.contains("Saturday")) {
            return freetimeval.saturday
        }
        
        else {
            if (freetimeval.sunday) {
                return true
            }
            
            return false
        }
    }
    
    func addinggetdisplayval(freetimeval: Freetime) -> Bool {
        if (addingselection.contains("Monday") && freetimeval.monday) {
            return true
        }
        
        else if (addingselection.contains("Tuesday") && freetimeval.tuesday) {
            return true
        }
        
        else if (addingselection.contains("Wednesday") && freetimeval.wednesday) {
            return true
        }
        
        else if (addingselection.contains("Thursday") && freetimeval.thursday) {
            return true
        }
        
        else if (addingselection.contains("Friday") && freetimeval.friday) {
            return true
        }
        
        else if (addingselection.contains("Saturday") && freetimeval.saturday) {
            return true
        }
        
        else {
            if (addingselection.contains("Sunday") && freetimeval.sunday) {
                return true
            }
            
            return false
        }
    }
    
    func savefreetimes() -> Void {
        for freetime in freetimelist {
            freetime.startdatetime = freetime.tempstartdatetime
            freetime.enddatetime = freetime.tempenddatetime
            do {
                try self.managedObjectContext.save()
                //print("AssignmentTypes rangemin/rangemax changed")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        masterRunning.masterRunningNow = true
        withAnimation(.spring())
        {
            self.refreshID = UUID()
        }
    }
    
    func cancelfreetimes() -> Void {
        for freetime in freetimelist {
            freetime.tempstartdatetime = freetime.startdatetime
            freetime.tempenddatetime = freetime.enddatetime
            do {
                try self.managedObjectContext.save()
                //print("AssignmentTypes rangemin/rangemax changed")
            } catch {
                print(error.localizedDescription)
            }
        }
        withAnimation(.spring())
        {
            self.refreshID = UUID()
        }
    }
    
    func addfreetime() -> Void {
        let y = Int(round(100*(addFreeTimeCGFloats[0])))
        let starttimeval = Int((addFreeTimeCGFloats[0])/60.35)*3600 + Int(Double(y%6035)/Double(6035)*4)*15*60
        let generalstartdatetime = Date(timeInterval: TimeInterval(starttimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))

        let x = Int(round(100*((addFreeTimeCGFloats[1]))))
        let endtimeval =  Int(((addFreeTimeCGFloats[1]))/60.35)*3600 + Int(Double(x%6035)/Double(6035)*4)*15*60
        let generalenddatetime = Date(timeInterval: TimeInterval(endtimeval), since: Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0)))
    
        self.addingselection.forEach { dayoftheweek in
            let newFreetime = Freetime(context: self.managedObjectContext)
            
            newFreetime.tempstartdatetime = generalstartdatetime
            newFreetime.startdatetime = generalstartdatetime
            newFreetime.tempenddatetime = generalenddatetime
            newFreetime.enddatetime = generalenddatetime
            
            newFreetime.monday = (dayoftheweek == "Monday")
            newFreetime.tuesday = (dayoftheweek == "Tuesday")
            newFreetime.wednesday = (dayoftheweek == "Wednesday")
            newFreetime.thursday = (dayoftheweek == "Thursday")
            newFreetime.friday = (dayoftheweek == "Friday")
            newFreetime.saturday = (dayoftheweek == "Saturday")
            newFreetime.sunday = (dayoftheweek == "Sunday")
    
            do {
                try self.managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        masterRunning.masterRunningNow = true
        
        withAnimation(.spring())
        {
            self.refreshID = UUID()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 5)

                HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                    ForEach(dayslist,  id: \.self) { day in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill((self.selection.contains(day) && !self.freetimeediting.addingmode) ? Color("datenumberred") : Color.clear).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3).animation(.easeInOut(duration: 0.14))
                            
                            RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(((self.addingselection.contains(day) && self.freetimeediting.addingmode) ? Color("datenumberred") : Color.clear), lineWidth: 2).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3).animation(.easeInOut(duration: 0.14))
                            
                            Text(String(Array(day)[0..<3]))
                        }.rotationEffect((self.selection.contains(day) && !self.freetimeediting.editingmode) ? Angle.degrees(self.rotationdegree) : Angle.degrees(0.0))
                        .animation((self.selection.contains(day) && !self.freetimeediting.editingmode) ? Animation.easeInOut(duration: 0.19).repeatForever(autoreverses: true) : Animation.linear(duration: 0))
                        .rotationEffect((self.selection.contains(day) && !self.freetimeediting.editingmode) ? Angle.degrees(-10.0) : Angle.degrees(0.0))
                        .animation(.easeInOut(duration: 0.14))
                        .brightness(self.pressing ? -0.14 : 0)
                        .scaleEffect(self.pressing ? 0.95 : 1.00)
                        .animation(.easeIn(duration: 0.17))
                        .onTapGesture {
                            if self.freetimeediting.addingmode {
                                self.addingSelectDeselect(day)
                                self.addFreeTimeCGFloats.removeAll()
                            }
                            
                            else {
                                print("dsf")
                                print(self.selection.contains(day))
                                print(!self.freetimeediting.editingmode)
                                print("fsd")
                                
                                
                                if (self.selection.contains(day) && !self.freetimeediting.editingmode) {
                                    self.savefreetimes()
                                    self.freetimeediting.editingmode = true
                                    self.freetimeediting.showsavebuttons = false
                                }

                                else {
                                    self.selectDeselect(day)
                                }
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.45, pressing: { _ in
                            if !self.freetimeediting.addingmode {
                                self.pressing = true
                                self.selectDeselect(day)
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(20)) {
                                    self.pressing = false
                                }
                            }
                        }) {
                            if !self.freetimeediting.addingmode {
                                if (self.selection.contains(day) && !self.freetimeediting.editingmode) {
                                    self.savefreetimes()
                                    self.freetimeediting.editingmode = true
                                    self.freetimeediting.showsavebuttons = false
                                }
                                
                                else {
                                    self.selectDeselect(day)
                                    self.freetimeediting.editingmode = false
                                    self.freetimeediting.showsavebuttons = true
                                }
                            }
                        }
                    }
                }
                      
                ZStack {
                    ScrollView {
                        ZStack {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    ForEach((0...24), id: \.self) { hour in
                                        HStack {
                                            Text(String(format: "%02d", hour)).font(.system(size: 13)).frame(width: 20, height: 20)
                                            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-50, height: 0.5)
                                        }
                                    }.frame(height: 50)
                                }
                            }
                            
                            HStack(alignment: .top) {
                                Spacer()
                                VStack {
                                    Spacer().frame(height: 25)
                                    
        //                            ZStack(alignment: .topTrailing) {
        //                                ForEach(freetimelist, id: \.self) { freetime in
        //                                    FreeTimeIndividual(freetime: freetime)
        //                                }.animation(.spring())
        //                            }
                                    ZStack(alignment: .topTrailing) {
        //                                ForEach((0...3), id: \.self) { num in
        //                                    FreeTimeIndividual(yoffset: CGFloat(181.05*Double(num)))
        //                                }//.animation(.spring())
                               //         if (!self.freetimeediting.editingmode)
                                     //   {
                                        ForEach(freetimelist, id: \.self) { freetime in
                                            if self.freetimeediting.addingmode {
                                                if addinggetdisplayval(freetimeval: freetime) {
                                                    ObstructingFreeTimes(ObstructingFreeTimeObjectsWhenAdding: self.$ObstructingFreeTimeObjectsWhenAdding, freetime: freetime, PossibleDateBrackets: self.$PossibleDateBrackets)
                                                }
                                            }
                                            
                                            else {
                                                if (getdisplayval(freetimeval: freetime)) {
                                                    FreeTimeIndividual(yoffset:  CGFloat(Calendar.current.dateComponents([.minute], from: Calendar.current.startOfDay(for: freetime.startdatetime), to: freetime.startdatetime).minute!)*60.35/60, height:  CGFloat(Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!)*60.35/60, dayvals: [freetime.monday, freetime.tuesday, freetime.wednesday, freetime.thursday, freetime.friday, freetime.saturday, freetime.sunday], starttime: freetime.startdatetime, endtime: freetime.enddatetime, editingmode: self.$freetimeediting.editingmode, showsavebuttons: self.$freetimeediting.showsavebuttons, freetimeobject: freetime)
                                                }
                                            }
                                        }.id(self.refreshID)
                                            
                                        if self.freetimeediting.addingmode {
                                            ForEach(self.PossibleDateBrackets, id: \.self) { PossibleDateBracket in
                                                FreeTimeToAdd(pdb: [PossibleDateBracket[0], PossibleDateBracket[1]], addFreeTimeCGFloats: self.$addFreeTimeCGFloats, showsavebuttons: self.$freetimeediting.showsavebuttons)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                
                    VStack {
                        Spacer()
                        
                        HStack {
                            if (self.freetimeediting.showsavebuttons) {
                                Button(action: {
                                    if self.freetimeediting.addingmode {
                                        if !self.addFreeTimeCGFloats.isEmpty {
                                            self.addfreetime()
                                            self.freetimeediting.editingmode = true
                                            self.freetimeediting.addingmode = false
                                            self.freetimeediting.showsavebuttons = false
                                            self.addFreeTimeCGFloats.removeAll()
                                            self.addingselection = self.selection
                                        }
                                    }
                                    else {
                                        self.savefreetimes()
                                        self.freetimeediting.editingmode = true
                                        self.freetimeediting.showsavebuttons = false
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color("ftaddmenubg")).frame(width: 120, height: 46)
                                        Text(self.freetimeediting.addingmode ? "Add" : "Save").font(.system(size: 18)).fontWeight(.semibold).foregroundColor((self.freetimeediting.addingmode && self.addFreeTimeCGFloats.isEmpty) ? Color.gray : Color.blue)
                                    }.padding(.all, 7).padding(.trailing, -7)
                                }
                                
                                Rectangle().fill(Color.gray).frame(width: 0.4, height: 26)
                                
                                Button(action: {
                                    self.cancelfreetimes()
                                    self.addFreeTimeCGFloats.removeAll()
                                    self.freetimeediting.editingmode = true
                                    self.freetimeediting.addingmode = false
                                    self.freetimeediting.showsavebuttons = false
                                    self.addingselection = self.selection
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color("ftaddmenubg")).frame(width: 120, height: 46)
                                        Text("Cancel").font(.system(size: 18)).fontWeight(.semibold).foregroundColor(Color.red)
                                    }.padding(.all, 7).padding(.leading, -7)
                                }
                            }
                        }.background(Color("ftaddmenubg")).cornerRadius(14).padding(.all, 14).shadow(color: (colorScheme == .light ? .gray : .black), radius: 3, x: 2, y: 2)
                    }
                }
            }
//End of main VStack, Start of Add Button
            VStack {
                Spacer()
                if self.freetimeediting.editingmode && !self.freetimeediting.addingmode {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.freetimeediting.addingmode = true
                            self.freetimeediting.showsavebuttons = true
                        }) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).opacity(1).padding(20).overlay(
                                ZStack {
                                    Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30)
                                }
                            )
                        }.buttonStyle(PlainButtonStyle()).contextMenu {
                            Button(action: {
                                self.freetimeediting.addingmode = true
                                self.freetimeediting.showsavebuttons = true
                            }) {
                                Text("Work Hours")
                                Image(systemName: "clock")
                            }
                        }
                    }
                }
            }
            
            if masterRunning.masterRunningNow {
                MasterClass()
            }
        }.navigationBarTitle("Work Hours", displayMode: .large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring()) {
                        self.freetimeediting.editingmode.toggle()
                        self.freetimeediting.showsavebuttons.toggle()
                        
                        if self.freetimeediting.editingmode {
                            self.savefreetimes()
                        }
                    }
                }) {
                    Text(self.freetimeediting.addingmode ? "" : (self.freetimeediting.editingmode ? "Edit" : "Save")).fontWeight(.bold).foregroundColor(Color.blue)
                }
            }
        }
    }
}