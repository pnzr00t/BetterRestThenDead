//
//  ContentView.swift
//  BetterRest
//
//  Created by 	Oleg2 on 03.07.2020.
//  Copyright © 2020 Oleg Pustoshkin. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUpDate: Date =  {
        var dateComponent = DateComponents()
        dateComponent.hour = 7
        dateComponent.minute = 0
        
        return Calendar.current.date(from: dateComponent) ?? Date()
    }()
    @State private var sleepAmount = 8.0
    @State private var coffeeCupAmount = 1
    
    @State private var alertTitle   = ""
    @State private var alerText     = ""
    @State private var isShowAlert  = false
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    Text("When do you wont wake up")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: self.$wakeUpDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    //.labelsHidden()
                        
                    
                }
                
                Section (header: Text("Enter you sleep amount").font(.title)) {
                    Stepper(value: self.$sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(self.sleepAmount, specifier: "%.2f") hours")
                    }
                }

                Section (header: Text("Enter amount of coffee cup").font(.title)) {
                    Stepper(value: self.$coffeeCupAmount, in: 0...20, step: 1) {
                        if self.coffeeCupAmount > 1 {
                            Text("\(self.coffeeCupAmount) caps")
                        } else
                        {
                            Text("\(self.coffeeCupAmount) cap")
                        }
                    }
                }
            }
            .navigationBarTitle("Better Rest Then Dead")
            .navigationBarItems(trailing: Button(action: self.calculateBedTime) {
                Text("Calculate")
                .padding()
                    .foregroundColor(Color.blue)
                .background(Color.green)
                .clipShape(Capsule())
            } )
            .alert(isPresented: self.$isShowAlert) {
                Alert(title: Text(self.alertTitle), message: Text(self.alerText), dismissButton: .default(Text("OK")))
            }
            
        }

    }
    
    func calculateBedTime() {
        debugPrint("Calc button pressed")
        
        let mlModel = SleepMLModel()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: self.wakeUpDate)
        let hour = (components.hour ?? 0 ) * 60 * 60
        let minute = (components.minute ?? 0 ) * 60
        
        do {
            let predict = try mlModel.prediction(wake: Double(hour + minute), estimatedSleep: self.sleepAmount, coffee: Double(self.coffeeCupAmount))
            
            
            let sleepTime = self.wakeUpDate - predict.actualSleep
            
            debugPrint(predict.actualSleep / 60 / 60 )
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            
            self.alertTitle = "You ideal bed time is ..."
            self.alerText = dateFormatter.string(from: sleepTime)
            self.alerText += "\n"
            self.alerText += "You need a sleep about " + String(format: "%.2f", predict.actualSleep / 60 / 60)
            
        } catch {
            self.alerText = "We get Error"
            self.alerText = "Sorry i have a problem with calculation bed time"
        }
        
        self.isShowAlert = true
    }
    
    
    func makeDefaultWaitTime() -> Date {
        var dateComponent = DateComponents()
        dateComponent.hour = 7
        dateComponent.minute = 0
        
        return Calendar.current.date(from: dateComponent) ?? Date()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
