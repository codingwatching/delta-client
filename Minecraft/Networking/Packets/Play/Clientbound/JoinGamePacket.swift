//
//  JoinGamePacket.swift
//  Minecraft
//
//  Created by Rohan van Klinken on 3/1/21.
//

import Foundation

struct JoinGamePacket: ClientboundPacket {
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
  
  init(from packetReader: inout PacketReader) throws {
    playerEntityId = packetReader.readInt()
    let gamemodeInt = Int8(packetReader.readUnsignedByte())
    isHardcore = gamemodeInt & 0x8 == 0x8
    gamemode = Gamemode(rawValue: gamemodeInt)!
    previousGamemode = Gamemode(rawValue: packetReader.readByte())!
    worldCount = packetReader.readVarInt()
    worldNames = []
    for _ in 0..<worldCount {
      worldNames.append(try packetReader.readIdentifier())
    }
    dimensionCodec = try packetReader.readNBTTag()
    dimension = try packetReader.readIdentifier()
    worldName = try packetReader.readIdentifier()
    hashedSeed = packetReader.readLong()
    maxPlayers = packetReader.readUnsignedByte()
    viewDistance = packetReader.readVarInt()
    reducedDebugInfo = packetReader.readBool()
    enableRespawnScreen = packetReader.readBool()
    isDebug = packetReader.readBool()
    isFlat = packetReader.readBool()
  }
  
  func handle(for server: Server) throws {
    server.config = ServerConfig(worldCount: worldCount, worldNames: worldNames,
                                 dimensionCodec: dimensionCodec, maxPlayers: maxPlayers,
                                 viewDistance: viewDistance, useReducedDebugInfo: reducedDebugInfo,
                                 enableRespawnScreen: enableRespawnScreen)
    let worldConfig = WorldConfig(worldName: worldName, dimension: dimension,
                                  hashedSeed: hashedSeed, isDebug: isDebug, isFlat: isFlat)
    let world = World(config: worldConfig)
    server.worlds[worldName] = world
    server.currentWorldName = worldName
    server.downloadingTerrain = true
  }
}
