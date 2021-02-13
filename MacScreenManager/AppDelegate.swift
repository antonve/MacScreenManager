import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = {
        return NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }()

    var screenCount = 0;

    private var window: NSWindow?
    private var highlighterWork: DispatchWorkItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupWindow()
        setupStatusItem()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationDidChangeScreenParameters(_ notification: Notification) {
        guard screenCount != 2 && NSScreen.screens.count == 2 else {
            screenCount = NSScreen.screens.count
            return
        }
        screenCount = NSScreen.screens.count
        layoutScreens()
    }

    @objc
    private func handleQuit() {
        NSApplication.shared.terminate(nil)
    }
}

private extension AppDelegate {
    func setupWindow() {
        let window = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
        window.isOpaque = false
        window.makeKeyAndOrderFront(nil)
        window.backgroundColor = .clear
        window.level = .floating
        self.window = window
    }

    func setupStatusItem() {
        if let button = statusItem.button {
            button.title = "S"
        }

        statusItem.menu = {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Anton's Screen Manager", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(handleQuit), keyEquivalent: "q"))
            return menu
        }()
    }

    func layoutScreens() {
        shell("maxscreen")
    }

    @discardableResult
    private func shell(_ command: String) -> Int32 {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["zsh", "-c", command]
        task.launchPath = "/usr/bin/env"
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "\(env["PATH"]):/Users/\(ProcessInfo.processInfo.fullUserName)/dotfiles/bin:/usr/local/bin/"
        task.environment = env
        task.launch()
        task.waitUntilExit()

//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)!
//        print(output)

        return task.terminationStatus
    }

}
