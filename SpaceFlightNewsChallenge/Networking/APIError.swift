//
//  APIError.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL es inválida. Por favor, intenta nuevamente."
        case .invalidResponse:
            return "Respuesta inválida del servidor. Por favor, intenta más tarde."
        case .httpError(let code):
            switch code {
            case 400:
                return "Solicitud incorrecta. Verifica los parámetros de búsqueda."
            case 401:
                return "No autorizado. Verifica tus credenciales."
            case 404:
                return "No se encontraron recursos."
            case 500...599:
                return "Error del servidor. Por favor, intenta más tarde."
            default:
                return "Error HTTP: \(code). Por favor, intenta nuevamente."
            }
        case .decodingError(let error):
            return "Error al procesar los datos: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription). Verifica tu conexión a internet."
        }
    }
}
