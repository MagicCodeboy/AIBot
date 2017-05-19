//
//  ViewController.swift
//  AIBot
//
//  Created by lalala on 2017/5/19.
//  Copyright © 2017年 lsh. All rights reserved.
//

import UIKit
import Realm //数据库
import RealmSwift
import JSQMessagesViewController //聊天界面
import ApiAI //机器交互框架


struct User {
    var id: String
    var name: String
}

class ViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    
    let user1 = User(id: "1",name: "angle")
    let user2 = User(id: "2",name: "linda")
    
    var currentUser: User {
        return user1
    }
    
}
//收发接收到的信息 对数据库进行操作
extension ViewController {
    func addMessage(senderName: String, senderID: String, senderMessage: String) {
        let message = Message()
        message.senderID = senderID
        message.senderName = senderName
        message.senderMessage = senderMessage
        
        //写进数据库中
        let realm = try!Realm()
        try!realm.write {
            realm.add(message)
        }
    }
    func qurryAllmessage() {
        let realm = try!Realm()//拿到数据库
        let messages = realm.objects(Message.self)
        
        //遍历数据
        for message in messages {
            let msg = JSQMessage(senderId: message.senderID, displayName: message.senderName, text: message.senderMessage)
            self.messages.append(msg!)
        }
        
    }
    //让机器人说话
    func handleSendMessage(message: String) {
        //设置一个请求
        let request = ApiAI.shared().textRequest()
        request?.query = message
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            //解析数据
            let response = response as! AIResponse
            
            if let responseFromAI = response.result.fulfillment.speech {
                self.handleStroreBotMsg(botMsg: responseFromAI)
            }
        }, failure: { (request, error) in
            print(error!)
        })
        ApiAI.shared().enqueue(request)
    }
    func handleStroreBotMsg(botMsg: String) {
        //传送信息到数据库
        addMessage(senderName: user2.name, senderID: user2.id, senderMessage: botMsg)
        //把信息传递到JSQ ARRAY 中
        let botMessage = JSQMessage(senderId: user2.id, displayName: user2.name, text: botMsg)
        
        messages.append(botMessage!)
        
        finishSendingMessage()
    }
}
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = currentUser.id
        self.senderDisplayName = currentUser.name
        
        qurryAllmessage()
    }
    
}

//搭建出聊天框架
extension ViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//         super.didPressSend(button, withMessageText: text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        messages.append(message!)
        
        addMessage(senderName: senderDisplayName, senderID: senderId, senderMessage: text)
        
        handleSendMessage(message: text)
        
        finishSendingMessage()
        
        print("send")
    }
    //设置发出者的名字
   override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUserName = message.senderDisplayName
    
        return NSAttributedString(string: messageUserName!)
    }
    //名字距离气泡有多远
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout:     JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
         return nil
    }
    //显示气泡 设置左右的方向
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if currentUser.id == message.senderId {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .green)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    //显示多少条数据
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    //显示的内容
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
         return messages[indexPath.row]
    }
}







