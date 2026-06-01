FROM node:20-alpine

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json package-lock.json ./

# Instalar dependencias omitiendo los scripts pre/post-install por seguridad
RUN npm ci --ignore-scripts

# Copiar el código del frontend
COPY . .

# Exponer el puerto de desarrollo de Next.js
EXPOSE 3000

# Desactivar la telemetría de Next.js en desarrollo (Opcional)
ENV NEXT_TELEMETRY_DISABLED=1

# Comando para ejecutar Next.js en modo de desarrollo
CMD ["npm", "run", "dev"]
