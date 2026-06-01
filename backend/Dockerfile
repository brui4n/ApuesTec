# --- STAGE 1: Builder ---
FROM golang:alpine AS builder

WORKDIR /app

# Instalar herramientas necesarias para la compilación (si se requieren)
RUN apk add --no-cache git gcc musl-dev

# Copiar archivos de dependencias
COPY go.mod go.sum ./

# Descargar dependencias
RUN go mod download

# Copiar el código fuente
COPY . .

# Compilar el binario optimizado para producción
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main .

# --- STAGE 2: Runner ---
FROM alpine:latest  

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# Copiar el binario desde la fase de construcción
COPY --from=builder /app/main .

# Exponer el puerto
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["./main"]
