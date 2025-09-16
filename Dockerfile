FROM eclipse-temurin:21-jre-alpine AS builder
WORKDIR workspace
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} catalog-service.jar
RUN java -Djarmode=layertools -jar catalog-service.jar extract

FROM eclipse-temurin:21-jre-alpine
# Create a group and a user 'spring'
RUN addgroup -S spring && adduser -S spring -G spring

# Switch to the non-root user
USER spring
WORKDIR workspace
COPY --from=builder workspace/dependencies/ ./
COPY --from=builder workspace/spring-boot-loader/ ./
COPY --from=builder workspace/snapshot-dependencies/ ./
COPY --from=builder workspace/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]

# Use the link below to build Java jars and push them to the repository of your liking without
# having to write dockerfiles yourself.
#https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin
# ====== Build stage ======
#FROM maven:3.9.9-eclipse-temurin-21 AS build
#WORKDIR /app

# Copy only pom.xml first (to cache dependencies)
#COPY pom.xml .
#RUN mvn dependency:go-offline -B

# Copy source code and build
#COPY src ./src
#RUN mvn clean package -DskipTests

# ====== Runtime stage ======
#FROM eclipse-temurin:21-jdk-jammy
#WORKDIR /app

# Copy jar from build stage
#COPY --from=build /app/target/*.jar app.jar

# Run the app
#ENTRYPOINT ["java", "-jar", "app.jar"]
