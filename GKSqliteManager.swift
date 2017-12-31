//
//  GKSqliteManager.swift
//  sqliteDemo
//
//  Created by Mac mini-1 on 2017/12/31.
//  Copyright © 2017年 Mac mini-1. All rights reserved.
//

import UIKit
import SQLite
class GKSqliteManager: NSObject {
    private lazy var  path : String = {//数据库路径
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        path.append("/user_db.sqlite")
        return path
    }()
    
    //MARK: 创建必要的字段
    private var db: Connection!
    private let users = Table("users") //表名
    private let id =   Expression<Int64>("id")      //主键
    private let name = Expression<String>("name")  //列表1
    private let email = Expression<String>("email") //列表2
    private let model = Expression<Blob>("model") //列表3
    
    
    //创建单例模式
    static let defaultManager = GKSqliteManager()
    private override init() {
        super.init()
        createSqlite()
    }
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
}


extension GKSqliteManager{
    
     //MARK: 创建数据库文件
    private func createSqlite()  {
        do {
            print(path)
            db = try Connection(path)
            try db.run(users.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(email, unique: true)
                t.column(model)
            })
        } catch { print(error) }
    }
    
     //MARK: 插入数据
   @discardableResult func insertData(_name: String, _email: String)-> Bool{
        do {
            let insert = users.insert(name <- _name, email <- _email)
            let rest = try db.run(insert)
            return   rest > 0
        } catch {
            print(error)
            return false
        }
    }
    
     //MARK: 读取数据
    func readData() -> [(id: String, name: String, email: String)] {
        var userData = (id: "", name: "", email: "")
        var userDataArr = [userData]
        for user in try! db.prepare(users) {
            userData.id = String(user[id])
            userData.name = user[name]
            userData.email = user[email]
            userDataArr.append(userData)
        }
        return userDataArr
    }
    
     //MARK: 更新数据
    @discardableResult func updateData(userId: Int64, new_name: String ,new_email:String) -> Bool{
        let currUser = users.filter(id == userId)
        do {
          let rest = try db.run(currUser.update(name <- new_name,email <- new_email))
            print("更新结果===\(rest)")
            return rest > 0
        } catch {
            print(error)
            return false
        }
        
    }
    

     //MARK: 删除数据
   @discardableResult func removeData(userId: Int64) -> Bool {
        let currUser = users.filter(id == userId)
        do {
            let rest = try db.run(currUser.delete())
            print("删除结果===\(rest)")
            return rest > 0
        } catch {
            print(error)
            return false
        }
    }
    
     //MARK: 升级字段
     func addedColumn(key : String){
        do {
            let express = Expression<String>(key)
            let add = users.addColumn(express, defaultValue: " ")
            let rest = try db.run(add)
            print("删除结果===\(rest)")
        
        } catch {
            print(error)
       
        }
    }
    
}
