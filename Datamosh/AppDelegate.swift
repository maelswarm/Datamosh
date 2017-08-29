//
//  AppDelegate.swift
//  Datamosh
//
//  Created by fairy-slipper on 8/27/17.
//  Copyright © 2017 fairy-slipper. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    let viewController = ViewController()
    let window = NSWindow(contentRect: NSMakeRect(0, 0, NSScreen.main()!.frame.size.width, NSScreen.main()!.frame.size.height), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: NSBackingStoreType.buffered, defer: false)
    
    func constructMenu() {
        let mainMenu = NSMenu()
        
        var item = NSMenuItem()
        item.title = ""
        mainMenu.addItem(item)
        
        var subMenu = NSMenu()
        subMenu.title = ""
        mainMenu.setSubmenu(subMenu, for: item)
        
        item = NSMenuItem()
        item.title = "Quit"
        item.action = #selector(viewController.quit)
        item.target = viewController
        item.isEnabled = true
        subMenu.addItem(item)
        
        item = NSMenuItem()
        item.title = ""
        mainMenu.addItem(item)
        
        subMenu = NSMenu()
        subMenu.title = "File"
        mainMenu.setSubmenu(subMenu, for: item)
        
        item = NSMenuItem()
        item.title = "Open..."
        item.action = #selector(viewController.loadFile)
        item.target = viewController
        item.isEnabled = true
        subMenu.addItem(item)
        
        item = NSMenuItem()
        item.title = "Save"
        item.action = #selector(viewController.saveFile)
        item.target = viewController
        item.isEnabled = true
        subMenu.addItem(item)
        
        NSApplication.shared().mainMenu = mainMenu
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        viewController.view = NSView(frame: NSMakeRect(0, 0, window.frame.size.width, window.frame.size.height))
        viewController.view.wantsLayer = true
        window.contentView!.addSubview(viewController.view)
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
        viewController.create()
        
//        NSRect newFrame = [[NSScreen mainScreen] frame];
//        [self.window setFrame:newFrame display:YES animate:NO];
//        
//        self.myViewController = [[MasterViewController alloc]initWithNibName:@"MasterViewController" bundle:nil];
//        self.mainView = [[NSView alloc]initWithFrame:[self.window.contentView bounds]];
//        [[self.myViewController view] setFrame:[self.mainView bounds]];
//        [self.mainView addSubview:[self.myViewController view]];
//        [self.window.contentView addSubview:self.mainView];
//        [self constructMainMenu];
        
        self.constructMenu()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Datamosh")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

    func windowDidResize(_ notification: Notification) {
        viewController.view.frame = NSMakeRect(0, 0, window.frame.size.width, window.frame.size.height)
        self.viewController.resize()
    }
    
}

