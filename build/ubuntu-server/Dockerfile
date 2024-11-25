# Use the official Ubuntu image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    # Add your desired packages here, e.g., curl, vim, etc.
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /root

# Expose any necessary ports (e.g., 80 for HTTP)
EXPOSE 80

# Define the command to run your application or service
CMD ["bash"]