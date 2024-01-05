#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display banner
display_banner() {
    echo -e "${GREEN}"
    echo " Simple Web Recon Script -  "
    echo " DNS Enumeration, WHOIS Look Up, Port Scanning "
    echo " WebServer Information(HTTP) #add https"
    echo " SSL Certificate Information(HTTPS)"
    echo " Robots.txt(HTTP) #change to https"
    echo " Directory Listing (HTTP+HTTPS)"
    echo -e "${NC}"
    echo -e "${YELLOW}--- Website Security Recon Script ---${NC}"
    echo ""
}

# Display Banner
display_banner

# Get user input for IP or domain
read -p "Enter IP or domain: " target

# Check if user provided an IP or domain
if [ -z "$target" ]; then
    echo -e "${RED}Invalid input. Please provide an IP or domain.${NC}"
    exit 1
fi

# Step 1: DNS Enumeration
echo -e "${YELLOW}Performing DNS Enumeration...${NC}"
host "$target"

# Array of DNS record types
record_types=("A" "AAAA" "CNAME" "MX" "TXT")

# Loop through record types and perform nslookup
for record_type in "${record_types[@]}"; do
    echo -e "${GREEN}${record_type} records:${NC}"
    nslookup -type="$record_type" "$target" | grep -v 'NXDOMAIN\|SERVFAIL'
    echo ""
done

# Step 2: WHOIS Lookup
echo -e "${YELLOW}Performing WHOIS Lookup...${NC}"
whois "$target"
echo ""

# Step 3: Port Scanning and export results to text
echo -e "${YELLOW}Performing Port Scanning...${NC}"
nmap -sC -sV -oN "nmap-scan-$target.txt" "$target"
echo ""

# Step 4: Web Server Information (HTTP + HTTPS)
echo -e "${YELLOW}Fetching Web Server Information (HTTP)...${NC}"
curl -I "http://$target" 2>/dev/null | head -n 1
echo ""

echo -e "${YELLOW}Fetching Web Server Information (HTTPS)...${NC}"
curl -I "https://$target" 2>/dev/null | head -n 1
echo ""

# Step 5: SSL Certificate Information (HTTPS)
echo -e "${YELLOW}Fetching SSL Certificate Information (HTTPS)...${NC}"
openssl s_client -showcerts -connect "$target:443" </dev/null 2>/dev/null | openssl x509 -noout -text
echo ""

# Step 6: Robots.txt (HTTP + HTTPS)
echo -e "${YELLOW}Fetching Robots.txt Information (HTTP)...${NC}"
curl -sL "http://$target/robots.txt" 2>/dev/null

echo -e "${YELLOW}Fetching Robots.txt Information (HTTPS)...${NC}"
curl -sL "https://$target/robots.txt" 2>/dev/null
echo ""

# Step 7: Directory Listing Check (HTTP + HTTPS)
#echo -e "${YELLOW}Checking for Directory Listing (HTTP)...${NC}"
#response_http=$(curl -s -o /dev/null -w "%{http_code}" "http://$target/")
#if [ "$response_http" -eq 200 ]; then
#    echo "Directory listing over HTTP is enabled."
#else
#    echo "Directory listing over HTTP is not enabled. Attempting directory brute-forcing..."
#    dirb "http://$target" /usr/share/wordlists/dirb/common.txt -f
#fi
#echo ""

echo -e "${YELLOW}Checking for Directory Listing (HTTPS)...${NC}"
response_https=$(curl -s -o /dev/null -w "%{http_code}" "https://$target/")
if [ "$response_https" -eq 200 ]; then
    echo "Directory listing over HTTPS is enabled."
else
    echo "Directory listing over HTTPS is not enabled. Attempting directory brute-forcing..."
    dirb "https://$target" /usr/share/wordlists/dirb/common.txt -f
fi
echo ""
