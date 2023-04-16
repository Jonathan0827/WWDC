//
//  OnboardingView.swift
//  NotIM
//
//  Created by 임준협 on 2023/03/31.
//

import SwiftUI
import Combine
import CloudKit
struct OnboardingView: View {
    @AppStorage("userName") var userName = ""
    @State var title = ""
    @State var tempUserName = "" {
        didSet {
            if tempUserName.isEmpty {
                withAnimation {
                    showNameField = false
                }
            } else {
                withAnimation {
                    showNameField = true
                }
            }
        }
    }
    @State var goNext: Bool = false
    @State var helloAnimation: Bool = false
    @State var welcomeAnimation: Bool = false
    @State var befAskAnimation: Bool = false
    @State var askName: Bool = false
    @State var showNameField: Bool = false
    @State var noNameButSubmitted: Bool = false
    let h = UIScreen.main.bounds.height
    let w = UIScreen.main.bounds.width
    var body: some View{
        NavigationView{
            VStack{
                //            NavigationLink(destination: FeaturesView(), isActive: $goNext, label: {EmptyView()})
                if helloAnimation {
                    Text("👋🏻 Hello!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                if befAskAnimation {
                    HStack{
                        Text("Welcome to")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("NotIM!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.accentColor)
                    }
                }
                if welcomeAnimation {
                    Text("What's your name?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                HStack {
                    if askName {
                        ZStack{
                            TextField("Please enter your name.", text: $tempUserName)
                                .onSubmit {
                                    if tempUserName.isEmpty {
                                        noNameButSubmitted = true
                                    } else {
                                        withAnimation {
                                            userName = tempUserName
                                            welcomeAnimation = false
                                            askName = false
                                            showNameField = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                goNext = true
                                            })                                    }
                                    }
                                }
                                .onReceive(Just(tempUserName)) { tempUserName in
                                    if tempUserName.isEmpty {
                                        withAnimation {
                                            showNameField = false
                                        }
                                    } else {
                                        withAnimation {
                                            showNameField = true
                                        }
                                    }
                                }
                                .padding(10)
                                .shadow(color: .primary, radius: 20)
                                .frame(width: 300)
                                .zIndex(1)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.background)
                                .padding(10)
                                .frame(width: 320, height: 70)
                                .shadow(color: .secondary, radius: 10)
                        }
                    }
                    
                    if showNameField {
                        Button(action: {
                            withAnimation{
                                userName = tempUserName
                                welcomeAnimation = false
                                askName = false
                                showNameField = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    goNext = true
                                })
                            }
                        }, label: {
                            ZStack{
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 30, weight: .bold))
                                //                                .resizable()
                                //                                .frame(width: 30, height: 30)
                                    .zIndex(1)
                                    .foregroundColor(Color("notColorMode"))
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("colorMode"))
                                    .frame(width: 50, height: 50)
                                    .zIndex(0)
                                    .shadow(color: .secondary, radius: 10)
                                
                            }
                            .padding(.trailing, 10)
                            
                        })
                    }
                    if goNext {
                        FeaturesView(title: $title, userName: $userName)
                    }
                }
                .navigationBarTitle(title)
                
            }
            .alert("Please Enter Your Name", isPresented: $noNameButSubmitted, actions: {})
            .onAppear{
                userName = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    withAnimation { helloAnimation.toggle() }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    withAnimation { befAskAnimation.toggle() }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    withAnimation { welcomeAnimation.toggle() }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                    withAnimation {
                        askName.toggle()
                        helloAnimation.toggle()
                        befAskAnimation.toggle()
                    }
                })
            }
        }
    }
}

struct FeaturesView: View {
    @AppStorage("isFirstLaunching") var isFirstLaunching = true
    @Binding var title: String
    @State var viewLoaded: Bool = false
    @State var befShowFeatures: Bool = false
    @State var ShowFeatures1: Bool = false
    @State var ShowFeatures2: Bool = false
    @State var ShowFeatures3: Bool = false
    @State var showDoneBtn: Bool = false

    @Binding var userName: String
    var body: some View{
        VStack{
            Spacer()
            if viewLoaded{
                Text("Hey, \(userName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            if befShowFeatures {
                HStack{
                    Text("Say 'Hello!' to")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("NotIM")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.accentColor)
                }
            }
            VStack(alignment: .leading){
                if ShowFeatures1 {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                            .padding(.leading, 10)
                            .font(Font.system(size: 80))
                        VStack(alignment: .leading){
                            Text("Easily")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                                .foregroundColor(.accentColor)
                            Text("write notes.")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                        }
                    }
                }
                if ShowFeatures2 {
                    HStack {
                        Image(systemName: "lock.circle.fill")
                            .padding(.leading, 10)
                            .font(Font.system(size: 80))
                        VStack(alignment: .leading){
                            Text("Lock")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                                .foregroundColor(.accentColor)
                            Text("Notes.")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                        }
                    }
                    .padding(.top, 10)
                }
                if ShowFeatures3 {
                    HStack {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .padding(.leading, 10)
                            .font(Font.system(size: 80))
                        VStack(alignment: .leading){
                            Text("Share")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                                .foregroundColor(.accentColor)
                            Text("text.")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                        }
                    }
                    .padding(.top, 10)
                }
            }
            Spacer()
            if showDoneBtn {
                Button(action: {
                    isFirstLaunching = false
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let documentsDirectory = paths[0]
                    let docURL = URL(string: documentsDirectory)!
                    let dataPath = docURL.appendingPathComponent("NotIM")
                    if !FileManager.default.fileExists(atPath: dataPath.path) {
                        do {
                            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }, label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.orange)
                            .frame(width: 280, height: 70)
                        HStack{
                            Text("Done")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }.foregroundColor(Color("notColorMode"))
                        
                    }
                })
                .padding(.bottom, 10)
                .transition(AnyTransition.move(edge: .bottom))
            }
        }

        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                withAnimation { viewLoaded.toggle() }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                withAnimation { befShowFeatures.toggle() }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.7, execute: {
                withAnimation {
                    viewLoaded.toggle()
                    befShowFeatures.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
                withAnimation {
                    title = "Features"
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
                withAnimation {
                    ShowFeatures1.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5, execute: {
                withAnimation {
                    ShowFeatures2.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.5, execute: {
                withAnimation {
                    ShowFeatures3.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
                withAnimation {
                    showDoneBtn.toggle()
                }
            })
        }
    }
}
