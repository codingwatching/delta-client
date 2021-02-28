//
//  Client.swift
//  Minecraft
//
//  Created by Rohan van Klinken on 12/1/21.
//

import Foundation
import os

// pretty much the backend class for the whole game
class Client {
  var state: ClientState = .idle
  var server: Server
  var config: Config
  
  var eventManager: EventManager
  
  enum ClientState {
    case idle
    case initialising
    case connecting
    case play
  }
  
  init(eventManager: EventManager, serverInfo: ServerInfo, config: Config) {
    self.eventManager = eventManager
    self.config = config
    
    self.server = Server(withInfo: serverInfo, eventManager: eventManager, clientConfig: config)
  }
  
  // TEMP
  func play() {
    server.login()
  }
  
  func runCommand(_ command: String) {
    let logger = Logger(subsystem: "Minecraft", category: "commands")
    logger.log("running command `\(command)`")
    let parts = command.split(separator: " ")
    if let command = parts.first {
      let options = parts.dropFirst()
      switch command {
        case "say":
          let message = options.joined(separator: " ")
          let packet = ChatMessageServerboundPacket(message: message)
          server.sendPacket(packet)
        case "useitem":
          let packet = UseItemPacket(hand: .mainHand)
          server.sendPacket(packet)
          Logger.log("used item in main hand")
        case "swing":
          if options.count > 0 {
            if options.first == "offhand" {
              let packet = AnimationServerboundPacket(hand: .offHand)
              server.sendPacket(packet)
              Logger.log("swung off hand")
              return
            }
          }
          let packet = AnimationServerboundPacket(hand: .mainHand)
          server.sendPacket(packet)
          Logger.log("swung main hand")
        case "tablist":
          Logger.log("-- BEGIN TABLIST --")
          for playerInfo in server.tabList.players {
            Logger.log("[\(playerInfo.value.displayName?.toText() ?? playerInfo.value.name)] ping=\(playerInfo.value.ping)ms")
          }
          Logger.log("-- END TABLIST --")
        case "unpackchunk":
          var chunkUnpacker = ChunkUnpacker()
          chunkUnpacker.unpack([UInt8](server.testChunk))
        default:
          Logger.log("invalid command")
      }
    }
  }
}