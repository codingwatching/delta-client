//
//  JoinGame.swift
//  Minecraft
//
//  Created by Rohan van Klinken on 3/1/21.
//

import Foundation

struct JoinGamePacket: Packet {
  typealias PacketType = JoinGamePacket
  static let id: Int = 0x25
  
  var playerEntityId: Int32
  var isHardcore: Bool
  var gamemode: Gamemode
  var previousGamemode: Gamemode
  var worldCount: Int32
  var worldNames: [Identifier]
  var dimensionCodec: NBTCompound
  var dimension: Identifier
  var worldName: Identifier
  var hashedSeed: Int64
  var maxPlayers: UInt8
  var viewDistance: Int32
  var reducedDebugInfo: Bool
  var enableRespawnScreen: Bool
  var isDebug: Bool
  var isFlat: Bool
  
  static func from(_ packetReader: inout PacketReader) throws -> JoinGamePacket {
    let playerEntityId = packetReader.readInt()
    let gamemodeInt = Int8(packetReader.readUnsignedByte())
    let isHardcore = gamemodeInt & 0x8 == 0x8
    let gamemode = Gamemode(rawValue: gamemodeInt)!
    let previousGamemode = Gamemode(rawValue: packetReader.readByte())!
    let worldCount = packetReader.readVarInt()
    var worldNames: [Identifier] = []
    for _ in 0..<worldCount {
      worldNames.append(try packetReader.readIdentifier())
    }
    let dimensionCodec = try packetReader.readNBTTag()
    let dimension = try packetReader.readIdentifier()
    let worldName = try packetReader.readIdentifier()
    let hashedSeed = packetReader.readLong()
    let maxPlayers = packetReader.readUnsignedByte()
    let viewDistance = packetReader.readVarInt()
    let reducedDebugInfo = packetReader.readBool()
    let enableRespawnScreen = packetReader.readBool()
    let isDebug = packetReader.readBool()
    let isFlat = packetReader.readBool()
    let packet = JoinGamePacket(playerEntityId: playerEntityId, isHardcore: isHardcore, gamemode: gamemode,
                          previousGamemode: previousGamemode, worldCount: worldCount, worldNames: worldNames,
                          dimensionCodec: dimensionCodec, dimension: dimension, worldName: worldName, hashedSeed: hashedSeed,
                          maxPlayers: maxPlayers, viewDistance: viewDistance, reducedDebugInfo: reducedDebugInfo,
                          enableRespawnScreen: enableRespawnScreen, isDebug: isDebug, isFlat: isFlat)
    return packet
  }
}

