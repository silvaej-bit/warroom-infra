#!/bin/sh
# Gera /app/application-infra.properties a partir das variaveis de ambiente.
# Equivalente ao confd -onetime -backend env, sem dependencia de binario externo.
set -e

cat > /app/application-infra.properties <<EOF
server.port=${SERVER_PORT:-8080}

spring.datasource.url=${WARROOM_DB_URL}
spring.datasource.username=${WARROOM_DB_USER:-warroom}
spring.datasource.password=${WARROOM_DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

spring.jpa.hibernate.ddl-auto=none
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:db/migration

logging.level.root=${LOG_LEVEL_ROOT:-INFO}
logging.level.com.warroom=${LOG_LEVEL_APP:-INFO}
logging.level.org.springframework=${LOG_LEVEL_SPRING:-WARN}
logging.level.org.hibernate.SQL=${LOG_LEVEL_SQL:-WARN}

springdoc.swagger-ui.enabled=${SWAGGER_ENABLED:-false}
springdoc.api-docs.enabled=${SWAGGER_ENABLED:-false}
EOF

echo "[entrypoint] application-infra.properties gerado em /app"
exec java $JAVA_OPTS -jar /app/app.jar \
  --spring.config.additional-location=file:/app/application-infra.properties
