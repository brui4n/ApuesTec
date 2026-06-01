-- ============================================================================
-- APUESTEC - ESQUEMA DE BASE DE DATOS (POSTGRESQL)
-- ============================================================================

-- 1. TABLA DE USUARIOS
-- Almacena las credenciales, roles y campos optimizados para el motor de puntos.
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),          -- Nulo si el registro es puramente por Google OAuth2
    role VARCHAR(20) DEFAULT 'user',     -- 'user' o 'admin'
    google_id VARCHAR(255) UNIQUE,       -- Para autenticación híbrida con Google OAuth2
    
    -- Campos optimizados para el motor de puntuación (Evita lecturas pesadas)
    puntaje_acumulado INT DEFAULT 0,     -- Suma total de todos los puntos obtenidos
    racha_actual INT DEFAULT 0,          -- Contador para evaluar el "Bono por Racha" de 3 partidos

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABLA DE PARTIDOS
-- Registra los encuentros deportivos, fechas y marcadores oficiales finales.
CREATE TABLE partidos (
    id SERIAL PRIMARY KEY,
    equipo_local VARCHAR(100) NOT NULL,
    equipo_visitante VARCHAR(100) NOT NULL,
    fecha TIMESTAMP NOT NULL,
    goles_local INT,                     -- Nulo hasta que el partido finalice
    goles_visitante INT,                  -- Nulo hasta que el partido finalice
    estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'en_progreso', 'finalizado'
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLA DE PREDICCIONES
-- Registra las predicciones individuales de cada usuario para cada partido.
CREATE TABLE predicciones (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
    partido_id INT REFERENCES partidos(id) ON DELETE CASCADE,
    goles_local INT NOT NULL,
    goles_visitante INT NOT NULL,
    puntos_obtenidos INT DEFAULT 0,      -- Puntos acumulados en este partido (se calcula al finalizar)
    anticipada BOOLEAN DEFAULT FALSE,    -- TRUE si se registró con >24 horas de anticipación
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Restricción para asegurar que un usuario solo tenga una predicción por partido
    CONSTRAINT unica_prediccion_por_usuario UNIQUE (usuario_id, partido_id)
);

-- 4. TABLA DE SALAS (GRUPOS DE AMIGOS)
-- Permite agrupar participantes en tablas de posiciones privadas.
CREATE TABLE salas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo_invitacion VARCHAR(20) UNIQUE NOT NULL, -- Código alfanumérico único para unirse
    creador_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABLA INTERMEDIA DE MIEMBROS DE SALAS (Muchos a Muchos)
-- Relaciona a los usuarios con las salas a las que se han unido.
CREATE TABLE miembros_sala (
    sala_id INT REFERENCES salas(id) ON DELETE CASCADE,
    usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
    unido_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sala_id, usuario_id)
);

-- ============================================================================
-- ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS (Crucial para stress testing)
-- ============================================================================

-- Índice para búsquedas rápidas de usuarios en el leaderboard global
CREATE INDEX idx_usuarios_puntaje ON usuarios(puntaje_acumulado DESC);

-- Índice para buscar predicciones de un partido específico al finalizarlo
CREATE INDEX idx_predicciones_partido ON predicciones(partido_id);

-- Índice para validar códigos de invitación al unirse a salas
CREATE INDEX idx_salas_codigo ON salas(codigo_invitacion);
