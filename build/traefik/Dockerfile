# Use the official Traefik image
FROM traefik:v2.9

# Copy Traefik configuration files
COPY traefik.yml /etc/traefik/traefik.yml
COPY dynamic/ /etc/traefik/dynamic/

# Expose ports
EXPOSE 80
EXPOSE 443
EXPOSE 8080

# Command to run Traefik
CMD ["traefik"] 