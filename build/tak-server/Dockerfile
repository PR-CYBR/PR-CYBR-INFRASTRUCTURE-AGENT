# Use a base image with Java, as TAK Server requires it
FROM openjdk:11-jre-slim

# Set environment variables if needed
ENV TAK_SERVER_HOME=/opt/tak-server

# Create a directory for TAK Server
RUN mkdir -p $TAK_SERVER_HOME

# Copy TAK Server files into the container
COPY ./tak-server $TAK_SERVER_HOME

# Set the working directory
WORKDIR $TAK_SERVER_HOME

# Expose necessary ports (e.g., 8080 for HTTP, 8443 for HTTPS)
EXPOSE 8080 8443

# Define the command to run TAK Server
CMD ["java", "-jar", "tak-server.jar"]