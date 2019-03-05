//
//  ViewController.swift
//  appSatisfaction
//
//  Created by Admin on 5/3/2562 BE.
//  Copyright © 2562 devkmutnbA. All rights reserved.
//


import UIKit
import SQLite3

class ViewController: UIViewController {
    var db : OpaquePointer?
    @IBOutlet weak var textView: UITextView!
    let fileName = "product.sqlite"
    let fileManager = FileManager.default
    var dbPath = String()
    var sql = String()
    var stmt: OpaquePointer?
    var pointer: OpaquePointer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let dbURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appendingPathComponent(fileName)
        let openDb = sqlite3_open(dbURL.path, &db)
        if openDb != SQLITE_OK {
            print ("database open error")
            return
        }else {
//            print ("open database ")
        }

        
        sql = "CREATE TABLE IF NOT EXISTS product " +
            "(dateproduct TEXT, " +
            "place TEXT, " +
            "satisfaction TEXT, " +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "nameproduct TEXT)"
       // id,dateproduct,nameproduct,place,satisfaction
        let createTb = sqlite3_exec(db, sql, nil, nil , nil)
        if createTb != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print (err)
        }
      //  CREATE TABLE "product" ( `dateproduct` TEXT, `place` TEXT, `satisfaction` TEXT, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `nameproduct` TEXT )2
        sql = "INSERT INTO product  (dateproduct,place,satisfaction,id,nameproduct) VALUES " +
            "('10/01/22','1','water','school','good'), " +
            "('10/01/12','2','water2','school','good') "
        sqlite3_exec(db,sql,nil,nil,nil)
        select()
        sqlite3_close(db)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func select () {
      
        sql = "SELECT * FROM product"
        sqlite3_prepare(db,sql,-1,&pointer,nil)
        textView.text = ""
        var id: Int32
        var count1: Int32
        var count2: Int32
        var count3: Int32
        count1 = 0
        count2 = 0
        count3 = 0
        var dateproduct: String
        var nameproduct: String
        var place: String
        var satisfaction: String
        while (sqlite3_step(pointer) == SQLITE_ROW) {
 
            dateproduct = String(cString: sqlite3_column_text(pointer,1))
            
            textView.text?.append("วันที่บันทึก: \(dateproduct)\n")
            
            place = String(cString: sqlite3_column_text(pointer,2))
            textView.text?.append("สถานที่: \(place)\n")
            
            satisfaction = String(cString: sqlite3_column_text(pointer,3))
            textView.text?.append("ความพึงพอใจ: \(satisfaction)\n")
            
            if(satisfaction == "good"){
                count1=count1+1
            }
            if(satisfaction == "bad"){
                count2=count2+1
            }
            if(satisfaction == "adjust"){
               count3=count3+1
            }
            
            id = sqlite3_column_int(pointer, 0)
            textView.text?.append("id: \(id)\n")
            
            
            nameproduct = String(cString: sqlite3_column_text(pointer,4))
            textView.text?.append("ชื่อสินค้า: \(nameproduct)\n\n")
            
            
        }
        textView.text?.append("จำนวนความพึ่งใจระดับ ดี : \(count1)\n")
        textView.text?.append("จำนวนความพึ่งใจระดับ แย่ : \(count2)\n")
        textView.text?.append("จำนวนความพึ่งใจระดับ ปรับปรุง : \(count3)\n\n")
    }

    @IBAction func buttonAddDidTap(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Insert", message: "ใส่ข้อมูลให้ครบทุกช่อง", preferredStyle: .alert)
        
                alert.addTextField(configurationHandler: { tf in
                    tf.placeholder = "วันที่บันทึกข้อมูล"
                    tf.font = UIFont.systemFont(ofSize: 18)
                })
        
                alert.addTextField(configurationHandler: { tf in
                    tf.placeholder = "สถานที่"
                    tf.font = UIFont.systemFont(ofSize: 18)
                })
        
                alert.addTextField(configurationHandler: { tf in
                    tf.placeholder = "ความพึ่งพอใจ"
                    tf.font = UIFont.systemFont(ofSize: 18)
                })
        
                alert.addTextField(configurationHandler: { tf in
                    tf.placeholder = "ชื่อสินค้า"
                    tf.font = UIFont.systemFont(ofSize: 18)
                })
        

        
        
                let btCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let btOk = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.sql = "INSERT INTO product VALUES (null, ?, ?, ?, ?)"
                    sqlite3_prepare(self.db, self.sql, -1, &self.stmt, nil)
                    let dateproduct = alert.textFields![0].text! as NSString
                    let place = alert.textFields![1].text! as NSString
                    let satisfaction = alert.textFields![2].text! as NSString
                    let nameproduct = alert.textFields![3].text! as NSString
                    sqlite3_bind_text(self.stmt, 1, dateproduct.utf8String, -1, nil)
                    sqlite3_bind_text(self.stmt, 2, place.utf8String, -1, nil)
                    sqlite3_bind_text(self.stmt, 3, satisfaction.utf8String, -1, nil)
                    sqlite3_bind_text(self.stmt, 4, nameproduct.utf8String, -1, nil)
                    sqlite3_step(self.stmt)
//
                    self.select()
                })
        
                alert.addAction(btCancel)
                alert.addAction(btOk)
                present(alert, animated: true, completion: nil)
        
        
    }
 
    @IBAction func bunttonDeleteDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete",
                              message: "ใส่ ID ของแถวที่ต้องการลบ",
                              preferredStyle: .alert)
        
                alert.addTextField(configurationHandler: { tf in
                    tf.placeholder = "ID ของแถวที่ต้องการลบ"
                    tf.font = UIFont.systemFont(ofSize: 18)
                    tf.keyboardType = .numberPad
                })
        
                let btCancel = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
        
                let btOK = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: { _ in
                                            guard let id = Int32(alert.textFields!.first!.text!) else {
                                                return
                                            }
                                            self.sql = "DELETE FROM product WHERE id = \(id)"
                                            sqlite3_exec(self.db, self.sql, nil,nil,nil)
                                            self.select()
                })
        
                alert.addAction(btCancel)
                alert.addAction(btOK)
                present(alert, animated: true, completion: nil)
        
    }
   
    
}

