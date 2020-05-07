//
//  AppearManagerProtocol.swift
//  Appear
//
//  Created by Magnus Tviberg on 27/03/2020.
//

import Foundation

public protocol AppearManagerProtocol {
    func fetchRealityProject(completion: @escaping (Result<RealityProject>) -> Void)
    func fetchMedia(withID id: String, completion: @escaping (Result<RealityMedia>) -> Void)
    func fetchRealityFileArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void)
}
