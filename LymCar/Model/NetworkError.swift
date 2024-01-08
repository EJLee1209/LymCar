//
//  NetworkErrro.swift
//  LymCar
//
//  Created by 이은재 on 1/8/24.
//

import Foundation

enum NetworkError: String, Error {
    case invalidURL = "잘못된 URL 요청입니다"
    case invalidServerResponse = "서버 요청 실패\n잠시 후 다시 시도해주세요"
}
