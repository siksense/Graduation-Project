//
//  MainViewController.swift
//  Mobibench_by_Swift
//
//  Created by Yoonsik on 10/2/16.
//  Copyright © 2016 Yoonsik. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var dbSizeSegment: UISegmentedControl!
    @IBOutlet weak var journalSegment: UISegmentedControl!
    @IBOutlet weak var fileSizeSegment: UISegmentedControl!
    @IBOutlet weak var sequentialIOSizeSegment: UISegmentedControl!
    @IBOutlet weak var randomDataSizeSegment: UISegmentedControl!
    @IBOutlet weak var ioModeSegment: UISegmentedControl!
    
    var insertSpeed: String = ""
    var updateSpeed: String = ""
    var deleteSpeed: String = ""
    var sequentialIOSpeed: String = ""
    var randomIOSpeed: String = ""
    
    @IBAction func calculateSQLite3(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Insert 속도 측정
        var start = NSDate.init()
        do {
            for i in 0..<appDelegate.dbSize {
                try appDelegate.insertData(i, name: "AAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDDEEEEEEEEEEFFFFFFFFFFGGGGGGGGGGHHHHHHHHHHIIIIIIIIIIJJJJJJJJJJ")
            }
        } catch let e {
            print("Error: ", e)
        }
        var finish = NSDate.init()
        var diff = finish.timeIntervalSinceDate(start)
        self.insertSpeed = String(format: "%.0f", (Double(appDelegate.dbSize) / diff))
        
        // Update 속도 측정
        start = NSDate.init()
        do {
            for i in 0..<appDelegate.dbSize {
                try appDelegate.updateData(i, newName: "KKKKKKKKKKLLLLLLLLLLMMMMMMMMMMNNNNNNNNNOOOOOOOOOOPPPPPPPPPPQQQQQQQQQQRRRRRRRRRSSSSSSSSSTTTTTTTTTT")
            }
        } catch let e {
            print("Error: ", e)
        }
        finish = NSDate.init()
        diff = finish.timeIntervalSinceDate(start)
        self.updateSpeed = String(format: "%.0f", (Double(appDelegate.dbSize) / diff))
        
        // Delete 속도 측정
        start = NSDate.init()
        do {
            for i in 0..<appDelegate.dbSize {
                try appDelegate.deleteData(i)
            }
        } catch let e {
            print("Error: ", e)
        }
        finish = NSDate.init()
        diff = finish.timeIntervalSinceDate(start)
        self.deleteSpeed = String(format: "%.0f", (Double(appDelegate.dbSize) / diff))
        
        print("Jounal Mode: \(appDelegate.getJournalMode()), Insert: \(insertSpeed), Update: \(updateSpeed), Delete: \(deleteSpeed), Page Size: \(sysconf(_SC_PAGE_SIZE))")
    }
    
    @IBAction func calculateFileIO(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // AppDelegate에서 선언한 filePath를 C의 char배열로 바꾼다.
        let fileCString = appDelegate.filePath.cStringUsingEncoding(NSString.defaultCStringEncoding())
        
        // 파일과 연결한다.
        let fd = open(fileCString!, O_RDWR)
        let fileHandler = NSFileHandle.init(fileDescriptor: fd)
        
        // Sequential I/O 측정에 사용할 I/O size 만큼의 데이터
        let cCharacterArrayForSeqIO: [CChar] = [CChar].init(count: appDelegate.sequentialIOSize, repeatedValue: 65)
        // NSString형으로 변환해준다.
        let stringForSeqIO: NSString = NSString.init(CString: cCharacterArrayForSeqIO, encoding: NSASCIIStringEncoding)!
        
        // Random I/O 측정에 사용할 Data size 만큼의 데이터
        let cCharacterArrayForRandIO: [CChar] = [CChar].init(count: appDelegate.dataSize, repeatedValue: 66)
        // NSString형으로 변환해준다.
        let stringForRandIO: NSString = NSString.init(CString: cCharacterArrayForRandIO, encoding: NSASCIIStringEncoding)!
        
        // Sequential I/O 속도 측정
        var start = NSDate.init()
        for _ in 0..<appDelegate.fileSize/appDelegate.sequentialIOSize {
            fileHandler.writeData((stringForSeqIO.dataUsingEncoding(NSUTF8StringEncoding))!)
        }
        var finish = NSDate.init()
        var diff = finish.timeIntervalSinceDate(start)
        self.sequentialIOSpeed = String(format: "%.0f", (Double(appDelegate.fileSize)/diff/1048576))
        
        // Random I/O 속도 측정
        start = NSDate.init()
        switch appDelegate.mode {
        case 0:
            for i in 0..<appDelegate.fileSize/16384 {
                fileHandler.seekToFileOffset(UInt64(appDelegate.randomOffset[i] * 16384))
                fileHandler.writeData((stringForRandIO.dataUsingEncoding(NSUTF8StringEncoding))!)
            }
        case 1:
            for i in 0..<appDelegate.fileSize/16384 {
                fileHandler.seekToFileOffset(UInt64(appDelegate.randomOffset[i] * 16384))
                fileHandler.writeData((stringForRandIO.dataUsingEncoding(NSUTF8StringEncoding))!)
                fsync(fileHandler.fileDescriptor)
            }
        case 2:
            fcntl(fileHandler.fileDescriptor, F_NOCACHE)
            for i in 0..<appDelegate.fileSize/16384 {
                fileHandler.seekToFileOffset(UInt64(appDelegate.randomOffset[i] * 16384))
                fileHandler.writeData((stringForRandIO.dataUsingEncoding(NSUTF8StringEncoding))!)
            }
        default:
            for i in 0..<appDelegate.fileSize/16384 {
                fileHandler.seekToFileOffset(UInt64(appDelegate.randomOffset[i] * 16384))
                fileHandler.writeData((stringForRandIO.dataUsingEncoding(NSUTF8StringEncoding))!)
            }
        }
        finish = NSDate.init()
        diff = finish.timeIntervalSinceDate(start)
        self.randomIOSpeed = String(format: "%.0f", (Double(appDelegate.fileSize)/diff/16384))
        
//        do {
//            try NSFileManager.defaultManager().removeItemAtPath(appDelegate.filePath)
//        } catch let e {
//            print(e)
//        }
        
        print("Seq I/O: \(sequentialIOSpeed), Ran I/O: \(randomIOSpeed), Page Size: \(sysconf(_SC_PAGESIZE))")
    }
    
    @IBAction func selectDBSize(sender: UISegmentedControl) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch dbSizeSegment.selectedSegmentIndex {
        case 0:
            appDelegate.dbSize = 100
        case 1:
            appDelegate.dbSize = 500
        case 2:
            appDelegate.dbSize = 1000
        default:
            appDelegate.dbSize = 100
        }
    }
    @IBAction func selectJournalMode(sender: UISegmentedControl) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch journalSegment.selectedSegmentIndex {
        case 0:
            appDelegate.changeJournalMode("delete")
        case 1:
            appDelegate.changeJournalMode("truncate")
        case 2:
            appDelegate.changeJournalMode("memory")
        case 3:
            appDelegate.changeJournalMode("persist")
        case 4:
            appDelegate.changeJournalMode("wal")
        case 5:
            appDelegate.changeJournalMode("off")
        default:
            appDelegate.changeJournalMode("delete")
        }

    }

    @IBAction func selectIOSize(sender: UISegmentedControl) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch sequentialIOSizeSegment.selectedSegmentIndex {
        case 0:
            appDelegate.sequentialIOSize = 1024 * 256
        case 1:
            appDelegate.sequentialIOSize = 1024 * 512
        case 2:
            appDelegate.sequentialIOSize = 1024 * 768
        default:
            appDelegate.sequentialIOSize = 1024 * 256
        }

    }
    @IBAction func selectDataSize(sender: UISegmentedControl) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch randomDataSizeSegment.selectedSegmentIndex {
        case 0:
            appDelegate.dataSize = 16384
        case 1:
            appDelegate.dataSize = 4096
        default:
            appDelegate.dataSize = 16384
        }

    }
    @IBAction func selectIOMode(sender: UISegmentedControl) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch ioModeSegment.selectedSegmentIndex {
        case 0:
            appDelegate.mode = 0
        case 1:
            appDelegate.mode = 1
        case 2:
            appDelegate.mode = 2
        default:
            appDelegate.mode = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sqliteResult" {
            let sqliteView: SqliteResultViewController = segue.destinationViewController as! SqliteResultViewController
            
            sqliteView.receivedInsertResult = insertSpeed
            sqliteView.receivedUpdateResult = updateSpeed
            sqliteView.receivedDeleteResult = deleteSpeed
        } else if segue.identifier == "fileIOResult" {
            let fileIOView: FileIOResultViewController = segue.destinationViewController as! FileIOResultViewController
            
            fileIOView.receivedSequentialResult = sequentialIOSpeed
            fileIOView.receivedRandomResult = randomIOSpeed
        }
    }
}



//@IBAction func showInsertView(sender: UIButton) {
//    let dateFormatter = NSDateFormatter.init()
//    dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss:SSS"
//    
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    let phoneModel = UIDevice.currentDevice().model
//    let current_iOS = UIDevice.currentDevice().systemVersion
//    
//    let start = NSDate.init()
//    do {
//        for _ in 0..<dbSize {
//            try appDelegate.insertData("AAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDDEEEEEEEEEEFFFFFFFFFFGGGGGGGGGGHHHHHHHHHHIIIIIIIIIIJJJJJJJJJJ")
//        }
//    } catch let e {
//        print("Error: ", e)
//    }
//    let finish = NSDate.init()
//    
//    let startTime = dateFormatter.stringFromDate(start)
//    let finishTime = dateFormatter.stringFromDate(finish)
//    print("Start time: \(startTime)")
//    print("Finish time: \(finishTime)")
//    
//    let diff = finish.timeIntervalSinceDate(start)
//    print("\(diff)")
//    
//    let strRR = "Device Model: \(phoneModel)\n" + "OS Version: \(current_iOS)\n" + "Excution per sec: " + String(format: "%.2f", (Double(dbSize) / diff)) +
//        "\nJournal mode: " + appDelegate.getJournalMode()
//    
//    let alertController = UIAlertController(title: "INSERT 검사 결과", message: strRR, preferredStyle: UIAlertControllerStyle.Alert)
//    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) in
//        print("You have pressed the Cancel button")
//    }
//    alertController.addAction(cancelAction)
//    
//    self.presentViewController(alertController, animated: true, completion: nil)
//}
//
//@IBAction func showUpdateView(sender: UIButton) {
//    let dateFormatter = NSDateFormatter.init()
//    dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss:SSS"
//    
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    let phoneModel = UIDevice.currentDevice().model
//    let current_iOS = UIDevice.currentDevice().systemVersion
//    
//    let start = NSDate.init()
//    do {
//        for _ in 0..<dbSize {
//            try appDelegate.updateData("KKKKKKKKKKLLLLLLLLLLMMMMMMMMMMNNNNNNNNNOOOOOOOOOOPPPPPPPPPPQQQQQQQQQQRRRRRRRRRSSSSSSSSSTTTTTTTTTT",
//                                       oldName: "AAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDDEEEEEEEEEEFFFFFFFFFFGGGGGGGGGGHHHHHHHHHHIIIIIIIIIIJJJJJJJJJJ")
//        }
//    } catch let e {
//        print("Error: ", e)
//    }
//    let finish = NSDate.init()
//    
//    let startTime = dateFormatter.stringFromDate(start)
//    let finishTime = dateFormatter.stringFromDate(finish)
//    print("Start time: \(startTime)")
//    print("Finish time: \(finishTime)")
//    
//    let diff = finish.timeIntervalSinceDate(start)
//    print("\(diff)")
//    
//    let strRR = "Device Model: \(phoneModel)\n" + "OS Version: \(current_iOS)\n" + "Excution per sec: " + String(format: "%.2f", (Double(dbSize) / diff)) +
//        "\nJournal mode: " + appDelegate.getJournalMode()
//    
//    let alertController = UIAlertController(title: "UPDATE 검사 결과", message: strRR, preferredStyle: UIAlertControllerStyle.Alert)
//    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) in
//        print("You have pressed the Cancel button")
//    }
//    alertController.addAction(cancelAction)
//    
//    self.presentViewController(alertController, animated: true, completion: nil)
//}
//
//@IBAction func showDeleteView(sender: UIButton) {
//    let dateFormatter = NSDateFormatter.init()
//    dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss:SSS"
//    
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    let phoneModel = UIDevice.currentDevice().model
//    let current_iOS = UIDevice.currentDevice().systemVersion
//    
//    let start = NSDate.init()
//    do {
//        for _ in 0..<dbSize {
//            try appDelegate.deleteData()
//        }
//    } catch let e {
//        print("Error: ", e)
//    }
//    let finish = NSDate.init()
//    
//    let startTime = dateFormatter.stringFromDate(start)
//    let finishTime = dateFormatter.stringFromDate(finish)
//    print("Start time: \(startTime)")
//    print("Finish time: \(finishTime)")
//    
//    let diff = finish.timeIntervalSinceDate(start)
//    print("\(diff)")
//    
//    let strRR = "Device Model: \(phoneModel)\n" + "OS Version: \(current_iOS)\n" + "Excution per sec: " + String(format: "%.2f", (Double(dbSize) / diff)) +
//        "\nJournal mode: " + appDelegate.getJournalMode()
//    
//    let alertController = UIAlertController(title: "DELETE 검사 결과", message: strRR, preferredStyle: UIAlertControllerStyle.Alert)
//    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) in
//        print("You have pressed the Cancel button")
//    }
//    alertController.addAction(cancelAction)
//    
//    self.presentViewController(alertController, animated: true, completion: nil)
//}
//    @IBAction func showFwirteView(sender: UIButton) {
//        let dateFormatter = NSDateFormatter.init()
//        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss:SSS"
//
//        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let docDir = paths.objectAtIndex(0)
//        let docFile = docDir.stringByAppendingPathComponent("deck.txt")
//        NSFileManager.defaultManager().createFileAtPath(docFile, contents: nil, attributes: nil)
//        let doc = docFile.cStringUsingEncoding(NSString.defaultCStringEncoding())
//        let fd = open(doc!, O_RDWR)
//
//        let arr1 = [CChar].init(count: ioSizeSeq, repeatedValue: 65)
//
//        let str1 = NSString.init(CString: arr1, encoding: NSASCIIStringEncoding)
//        let myHandle = NSFileHandle.init(fileDescriptor: fd)
//
//        let t2 = NSDate.init()
//        for _ in 0..<fileSize / ioSizeSeq {
//            myHandle.writeData((str1?.dataUsingEncoding(NSUTF8StringEncoding))!)
//        }
//        let t3 = NSDate.init()
//        let diff = t3.timeIntervalSinceDate(t2)
//        print("Sequential write time: \(diff)")
//
//        let strRR = "Sequential write (MB/s): " + String(format: "%.2f", (Double(fileSize)/diff/1048576))
//
//        let alertController = UIAlertController(title: "File I/O 검사 결과", message: strRR, preferredStyle: UIAlertControllerStyle.Alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) in
//            print("You have pressed the Cancel button")
//        }
//        alertController.addAction(cancelAction)
//
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
//
//    @IBAction func showFdeleteView(sender: UIButton) {
//        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let docDir = paths.objectAtIndex(0)
//        let docFile = docDir.stringByAppendingPathComponent("deck.txt")
//
//        do {
//            let fileAttributes: NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(docFile)
//            let fileSizeNumber: NSNumber = fileAttributes.objectForKey(NSFileSize) as! NSNumber
//            let fileSize2 = fileSizeNumber.longLongValue
//
//            print("File size: \(fileSize2)")
//        } catch let e {
//            print(e)
//        }
//
//        do {
//            try NSFileManager.defaultManager().removeItemAtPath(docFile)
//        } catch let e {
//            print(e)
//        }
//
//        let alertController = UIAlertController(title: "File I/O Delete", message: "Remove the file", preferredStyle: UIAlertControllerStyle.Alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction!) in
//            print("You have pressed the Cancel button")
//        }
//        alertController.addAction(cancelAction)
//
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }