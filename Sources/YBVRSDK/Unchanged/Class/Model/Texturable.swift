////
////  Texturable.swift
////  YBVRSDK
////
////  Created by Luis Miguel Alarcon on 13/6/22.
////
//
//import MetalKit
//
//protocol Texturable {
//    var texture : MTLTexture? {get set}
//}
//
//
////In order to create a texture, you need to pass the MTLDevice reference, the imagename with the extension of the texture,
////and the dictionary of MTKTextureLoader.Options
//
//extension Texturable{
//    func setTexture(device: MTLDevice, imageName: String, textureLoaderOptions: [MTKTextureLoader.Option : Any]) -> MTLTexture?{
//        let textureLoader = MTKTextureLoader(device: device)
//        var texture:  MTLTexture?=nil
//        
//        
//        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil){
//            do {
//                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
//            }catch{
//                print("Texture not created")
//            }
//        }
//        
//        
//        
//        return texture
//    }
//}
