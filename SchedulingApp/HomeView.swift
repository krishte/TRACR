//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
           
         NavigationView{
             Text("Bob").navigationBarItems(leading:
                 HStack {
                 Button(action: {}) {
                    Image(systemName: "gear").resizable().scaledToFit().font(.title)
                 }.foregroundColor(.black)
                     
                     
                     Image("Tracr").resizable().foregroundColor(.white).aspectRatio(contentMode: .fit).frame(width: 60, height:40, alignment: .center).padding(UIScreen.main.bounds.size.width/4+30)
                 },trailing:
             HStack {
                 Button(action: {}) {
                     Image(systemName: "plus")
                        .font(.title)
                 }.foregroundColor(.black)
             }).navigationBarTitle(Text(""), displayMode: .inline)
         }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
