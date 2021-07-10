//
//  APIServiceError.swift
//  
//
//  Created by Markus Bergh on 2021-07-08.
//

import Foundation

public enum AppleMusicServiceError: Error {
    case invalidURL
    case responseError
    case requestError
}
