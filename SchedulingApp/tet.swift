import SwiftUI

struct ContendtView: View {

    @State var offset : CGFloat = UIScreen.main.bounds.height
    
    
    var body: some View {
        ZStack{
            Button(action: {
                self.offset = 0
            }) {
                Text("Action Sheet")
            }
            
            VStack{
                Spacer()
                
                CustomActionSheet()
                .offset(y: self.offset)
            }.background((self.offset <= 100 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.offset = 0
            }).edgesIgnoringSafeArea(.bottom)
        }.animation(.default)
    }
}

struct ContendtView_Previews: PreviewProvider {
    static var previews: some View {
        ContendtView()
    }
}

struct CustomActionSheet : View {
    @State private var hours = 0
    @State private var minutes = 0
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    var body : some View {
        VStack(spacing: 15) {
            //shows current time left of assignment, gives picker for adding time
            //which defaults to the length of the original subassignment (if possible)
            //and shows the new time left
            Form {
                Section {
                    Text("Time to Add:")
                    HStack {
                        VStack {
                            Picker(selection: $hours, label: Text("Hour")) {
                                ForEach(hourlist.indices) { hourindex in
                                    Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                                 }
                             }.pickerStyle(WheelPickerStyle())
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                        
                        VStack {
                            if hours == 0 {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist[1...].indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                            
                            else {
                                Picker(selection: $minutes, label: Text("Minutes")) {
                                    ForEach(minutelist.indices) { minuteindex in
                                        Text(String(self.minutelist[minuteindex]) + " mins")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }
                        }.frame(minWidth: 100, maxWidth: .infinity)
                        .clipped()
                    }
                }
            }.background(Color.white)
        }.frame(maxHeight: 300).cornerRadius(25)
    }
}
