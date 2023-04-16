import SwiftUI

struct ContentView: View {
    @AppStorage("consoleIsEnabled") var consoleIsEnabled = true
    @AppStorage("userName") var userName = ""
    @AppStorage("isFirstLaunching") var isFirstLaunching = true
    @State var userIsAuthorized: Bool = false
    @State var newNoteTitle: String = ""
    @State var createNote: Bool = false
    @State var fileArray = [String]()
    let time = Date()
    let hour = Calendar.current.component(.hour, from: Date())
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    consoleIsEnabled.toggle()
                    visibleConsole(consoleIsEnabled)
                }, label: {
                    Text("console")
                })

//                Button(action: {isFirstLaunching = true}, label: {Text("reset")})
                if fileArray == [] || fileArray == [".DS_Store"] {
                    Text("No note available.")
                        .foregroundColor(.secondary)
                } else {
                    List{
                        ForEach(fileArray, id: \.self) { note in
                            if note == ".DS_Store" {
                            } else {
                                
                                //                                .onAppear {
                                //                                    print("noteLockState")
                                //                                    print(loadJsonFile(title: note)!.locked)
                                //                                }
                                Button(action: {
                                }, label: {
                                    NoteListPreview(title: note, noteList: $fileArray, userIsAuthorized: $userIsAuthorized, noteIsLocked: loadJsonFile(title: note)!.locked)
                                    //                                    Text(note)
                                })
                                .swipeActions(edge: .trailing) {
                                    Button(action: {
                                        fileArray = fileArray.filter {$0 != note}
                                        
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                                            deleteJsonData(title: note)
                                            let fileManager = FileManager()
                                            guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                                            let fileURL = path.appendingPathComponent("NotIM")
                                            
                                            do {
                                                let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                                                fileArray = contents
                                            } catch let error as NSError {
                                                print("Error access directory: \(error)")
                                            }
                                        })
                                    }, label: {
                                        Image(systemName: "trash.fill")
                                    })
                                    .tint(.red)
                                }
                            }
                            //                    Text(notes)
                            //                        .onAppear{
                            //                            print("a")
                            //                            print(notes)
                            //                        }
                        }
                    }
                    .background(.background)
                }
                Spacer()
                if userIsAuthorized{
                    Button(action: {
                        userIsAuthorized = false
                    }, label: {
                        Text("Lock Notes")
                    })
                }
                Button(action: {
                    createNote.toggle()
                }, label: {
                    ZStack{
                        HStack{
                            Image(systemName: "square.and.pencil.circle.fill")
                                .font(.system(size: 30))
                            Text("New Note")
                                .fontWeight(.semibold)
                        }
                        .zIndex(1)
                        .foregroundColor(Color("colorMode"))
                        Capsule()
                            .frame(width: 160, height: 50)
                            .zIndex(0)
                    }
                })
                .padding(20)
            }
            .navigationViewStyle(StackNavigationViewStyle())

            .onAppear {                
                findContents()
                visibleConsole(consoleIsEnabled)
                let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                cprint("Document Dir is")
                cprint(documentDirectoryUrl?.appendingPathComponent("NotIM"))
            }
            .navigationBarTitle(morningAfterEvening())
            
            .fullScreenCover(isPresented: $isFirstLaunching) {OnboardingView()}
            .sheet(isPresented: $createNote) {NewMemoView(createNote: $createNote, fileArray: $fileArray)}
            Text("Nothing Selected")
                .fontWeight(.bold)
                .font(.title)
        }
    }
    func morningAfterEvening() -> String{
        var timeDesc = ""
        if hour >= 5 && hour < 12 {
            timeDesc = "Good Morning! 🌄"
        } else if hour >= 12 && hour < 17 {
            timeDesc = "Good Afternoon! 🌇"
        } else if hour >= 17 && hour < 19{
            timeDesc = "Good Evening! 🌆"
        } else if hour >= 19{
            timeDesc = "Good Night! 🌃"
        } else {
            timeDesc = "How's it going?"
        }
        return "\(timeDesc)"
    }
    func findContents() {
        let fileManager = FileManager()
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = path.appendingPathComponent("NotIM")

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
            print(contents)
            fileArray = contents
        } catch let error as NSError {
            print("Error access directory: \(error)")
        }
        
    }


    
    
}
