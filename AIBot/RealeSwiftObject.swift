

//
//  RealeSwiftObject.swift
//  AIBot
//
//  Created by lalala on 2017/5/19.
//  Copyright © 2017年 lsh. All rights reserved.
//

import Foundation
import RealmSwift

class Message: Object {
   dynamic var senderName = ""
   dynamic var senderID = ""
   dynamic var senderMessage = ""
}
