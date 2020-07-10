//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

func NewAssignment() {
    print("new assignment")
}

func NewClass() {
    print("new class")
}

func NewOccupiedTime() {
    print("new occupied time")
}

func NewFreeTime() {
    print("new free time")
}

func NewGrade() {
    print("new grade")
}

struct AddOptionsView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            VStack(alignment: .trailing, spacing: 10) {
                Button(action: {NewAssignment()}) {
                    HStack {
                        Image(systemName: "paperclip").resizable().scaledToFit().frame(width: 18)
                        Spacer()
                        Text("Assignment").font(Font.body.weight(.semibold))
                    }.frame(width: 160)
                }.foregroundColor(.black).padding(.horizontal, 14).padding(.vertical, 7).background(Color("add_overlay_bg_light")).cornerRadius(10)

                Button(action: {NewClass()}) {
                    HStack {
                        Image(systemName: "list.bullet").resizable().scaledToFit().frame(width: 18)
                        Spacer()
                        Text("Class").font(Font.body.weight(.semibold))
                    }.frame(width: 160)
                }.foregroundColor(.black).padding(.horizontal, 14).padding(.vertical, 7).background(Color("add_overlay_bg_light")).cornerRadius(10)
                
                Button(action: {NewOccupiedTime()}) {
                    HStack {
                        Image(systemName: "clock.fill").resizable().scaledToFit().frame(width: 18)
                        Spacer()
                        Text("Occupied Time").font(Font.body.weight(.semibold))
                    }.frame(width: 160)
                }.foregroundColor(.black).padding(.horizontal, 14).padding(.vertical, 7).background(Color("add_overlay_bg_light")).cornerRadius(10)
                
                Button(action: {NewFreeTime()}) {
                    HStack {
                        Image(systemName: "clock").resizable().scaledToFit().frame(width: 18)
                        Spacer()
                        Text("Free Time").font(Font.body.weight(.semibold))
                    }.frame(width: 160)
                }.foregroundColor(.black).padding(.horizontal, 14).padding(.vertical, 7).background(Color("add_overlay_bg_light")).cornerRadius(10)

                Button(action: {NewGrade()}) {
                    HStack {
                        Image(systemName: "percent").resizable().scaledToFit().frame(width: 16)
                        Spacer()
                        Text("Grade").font(Font.body.weight(.semibold))
                    }.frame(width: 160)
                }.foregroundColor(.black).padding(.horizontal, 14).padding(.vertical, 7).background(Color("add_overlay_bg_light")).cornerRadius(10)
                
            }.padding().background(Color("add_overlay_bg")).overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("add_overlay_border"), lineWidth: 1)
            ).shadow(color: Color.black.opacity(0.1), radius: 20, x: -7, y: 7).padding(.leading, 61)
            
            Spacer()
            
        }
    }
}

struct HomeView: View {
    @State var showAddOptions = true
    
    var body: some View {
        ZStack {
             GeometryReader { geometry in
                 NavigationView{
                     EmptyView()
                     .navigationBarItems(
                        leading:
                            HStack(spacing: geometry.size.width / 4.2) {
                                Button(action: {print("settings button clicked")}) {
                                    Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                                }.padding(.leading, 2.0);
                            
                                Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                                Button(action: {}){
                                    Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12).onTapGesture {
                                        NewAssignment()                            }
                                    .onLongPressGesture(minimumDuration: 0.05) {
                                        self.showAddOptions.toggle()                            }
                                }
                        }.padding(.top, -11.0))
                        
                 }
            }
            
            VStack {
                if showAddOptions {
                    AddOptionsView()
                }
            }
        }.onTapGesture {
            self.showAddOptions = false
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
