//
//  JsonThings.swift
//  NotIM
//
//  Created by 임준협 on 2023/04/01.
//

import Foundation
import LocalAuthentication
import LocalConsole

let consoleManager = LCManager.shared
func cprint(_ desc: Any) {
    consoleManager.print(desc)
}
func visibleConsole(_ vis: Bool) {
    consoleManager.isVisible = vis
}


func saveJsonData(data: newNote, title: String) {
    let jsonEncoder = JSONEncoder()
    
    do {
        let encodedData = try jsonEncoder.encode(data)
        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//            let path = Bundle.main.resourcePath!
//            let documentDirectoryUrl = URL(string: path)
        let fileURL = documentDirectoryUrl.appendingPathComponent("NotIM/\(title)")
        
        do {
            try encodedData.write(to: fileURL)
        }
        catch let error as NSError {
            print(error)
            cprint(error)
        }
        
        
    } catch {
        print(error)
    }
    
}
func deleteJsonData(title: String) {
    let fileManager = FileManager.default
    do {        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//            let path = Bundle.main.resourcePath!
//            let documentDirectoryUrl = URL(string: path)
        let fileURL = documentDirectoryUrl.appendingPathComponent("NotIM/\(title)")
        
        do {
            try fileManager.removeItem(at: fileURL)
        }
        catch let error as NSError {
            print(error)
            cprint(error)
        }
        
        
    } catch {
        print(error)
        cprint(error)
    }
    
}
func loadJsonFile(title: String) -> newNote?{
    let jsonDecoder = JSONDecoder()
    do {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
//            let path = Bundle.main.resourcePath!
//            let documentDirectoryUrl = URL(string: path)
        let fileURL = documentDirectoryUrl.appendingPathComponent("NotIM/\(title)")
        print(fileURL)
        let jsonData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        
        let decodedNotes = try jsonDecoder.decode(newNote.self, from: jsonData)
//        print(decodedNotes)
        return decodedNotes
    }
    catch {
        print(error)
        return nil
    }
}

struct newNote: Codable {
    let title: String
    let date: Date
    let data: String
    let author: String
    let locked: Bool
}
