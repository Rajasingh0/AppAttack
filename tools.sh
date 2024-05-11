#!/bin/bash

# Function to display help menu
display_help() {
    echo -e "${YELLOW}Interactive Help Menu:${NC}"
    echo "1) osv-scanner: Scan a directory for vulnerabilities"
    echo "   - Download: https://github.com/google/osv-scanner"
    echo "2) snyk cli: Test code locally or monitor for vulnerabilities"
    echo "   - Download: https://snyk.io/download/"
    echo "   - Run code test locally: snyk code test <directory>"
    echo "   - Monitor for vulnerabilities: snyk monitor <directory> --all-projects"
    echo "3) brakeman: Scan a Ruby on Rails application for security vulnerabilities"
    echo "   - Download: https://github.com/presidentbeef/brakeman"
    echo "4) nmap: Network exploration and security auditing tool"
    echo "   - Download: https://nmap.org/download.html"
    echo "5) nikto: Web server scanner"
    echo "   - Download: https://cirt.net/nikto/"
    echo "6) OWASP ZAP: Web application security testing tool"
    echo "   - Download: https://github.com/zaproxy/zaproxy/releases"
    echo "7) Help: Display this help menu"
    echo "8) Exit: Exit the script"
}

# Colors for echo
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to install Go if not installed
install_go() {
    echo -e "${YELLOW}Installing Go...${NC}"
    sudo apt update && sudo apt install -y golang-go
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Go installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install Go.${NC}"
        exit 1
    fi
}

# Function to install npm if not installed
install_npm() {
    echo -e "${YELLOW}Installing npm...${NC}"
    sudo apt update && sudo apt install -y npm
    if [ $? -eq 0 ]; then
        sudo chown -R $(whoami) ~/.npm
        echo -e "${GREEN}npm installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install npm.${NC}"
        exit 1
    fi
}

# Function to install osv-scanner
install_osv_scanner() {
    if ! command -v osv-scanner &> /dev/null; then
        echo -e "${YELLOW}Installing osv-scanner...${NC}"
        go install github.com/google/osv-scanner/cmd/osv-scanner@v1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}osv-scanner installed successfully!${NC}"
            echo "export PATH=\$PATH:$(go env GOPATH)/bin" >> ~/.bashrc
            source ~/.bashrc
        else
            echo -e "${RED}Failed to install osv-scanner.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}osv-scanner is already installed.${NC}"
    fi
}

# Function to install snyk cli
install_snyk_cli() {
    if ! command -v npm &> /dev/null; then
        install_npm
    fi

    if ! command -v snyk &> /dev/null; then
        echo -e "${YELLOW}Installing snyk cli...${NC}"
        sudo npm install -g snyk
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Snyk cli installed successfully!${NC}"
            echo -e "${YELLOW}Authenticating snyk...${NC}"
            echo -e "${RED}Please authenticate by clicking 'Authenticate' in the browser to continue.${NC}"
            snyk auth
        else
            echo -e "${RED}Failed to install snyk cli.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}snyk cli is already installed.${NC}"
    fi
}

# Function to install brakeman
install_brakeman() {
    if ! command -v brakeman &> /dev/null; then
        echo -e "${YELLOW}Installing brakeman...${NC}"
        sudo gem install brakeman
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Brakeman installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install brakeman.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}brakeman is already installed.${NC}"
    fi
}

# Function to install nmap
install_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${YELLOW}Installing nmap...${NC}"
        sudo apt update && sudo apt install -y nmap
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}nmap installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install nmap.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}nmap is already installed.${NC}"
    fi
}

# Function to install nikto
install_nikto() {
    if ! command -v nikto &> /dev/null; then
        echo -e "${YELLOW}Installing nikto...${NC}"
        sudo apt update && sudo apt install -y nikto
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}nikto installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install nikto.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}nikto is already installed.${NC}"
    fi
}
# Function to install OWASP ZAP
install_owasp_zap() {
    if ! command -v zap.sh &> /dev/null; then
        echo -e "${YELLOW}Installing OWASP ZAP...${NC}"
        # Choose the appropriate file based on your system
        wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz
        if [ $? -eq 0 ]; then
            tar -xvf ZAP_2.15.0_Linux.tar.gz
            # Remove existing directory if present
            sudo rm -rf /opt/owasp-zap/ZAP_2.15.0
            sudo mv ZAP_2.15.0 /opt/owasp-zap
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}OWASP ZAP installed successfully!${NC}"
            else
                echo -e "${RED}Failed to move OWASP ZAP.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to download OWASP ZAP.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}OWASP ZAP is already installed.${NC}"
    fi
}

# Function to run OWASP ZAP
run_owasp_zap() {
    read -p "Enter target URL to scan: " target_url
    /opt/owasp-zap/zap.sh -cmd -quickurl $target_url -quickout owasp-zap-results.html
    echo -e "${GREEN}OWASP ZAP scan completed.${NC}"
}

# Main function to check and install tools
main() {
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        install_npm
    fi

    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        install_go
    fi

    # Check and install osv-scanner
    install_osv_scanner

    # Check and install snyk cli
    install_snyk_cli

    # Check and install brakeman
    install_brakeman

    # Check and install nmap
    install_nmap

    # Check and install nikto
    install_nikto

    # Check and install OWASP ZAP
    install_owasp_zap

    # Display help menu
    display_help

    while true; do
        # Run tools
        echo -e "${YELLOW}Select the tool you want to run:${NC}"
        echo "1) osv-scanner"
        echo "2) snyk cli"
        echo "3) brakeman"
        echo "4) nmap"
        echo "5) nikto"
        echo "6) OWASP ZAP"
        echo "7) Exit"
        read -p "Enter your choice (1/2/3/4/5/6/7): " choice

        case $choice in
            1)
                read -p "Enter directory to scan (current directory ./): " directory
                osv-scanner scan "$directory"
                ;;
            2)
                read -p "Select Snyk option:
                1) Run code test locally
                2) Monitor for vulnerabilities and see results in Snyk UI
                Enter your choice (1/2): " snyk_option

                case $snyk_option in
                    1)
                        read -p "Enter directory to scan (current directory ./): " directory
                        snyk code test $directory
                        ;;
                    2)
                        read -p "Enter directory to scan (current directory ./): " directory
                        snyk monitor $directory --all-projects
                        ;;
                    *)
                        echo -e "${RED}Invalid choice!${NC}"
                        ;;
                esac
                ;;
            3)
                sudo brakeman --force
                ;;
            4)
                read -p "Enter URL to scan: " url
                nmap -v -A "$url"
                ;;
            5)
                read -p "Enter URL to scan: " url
                nikto -h "$url"
                ;;
            6)
                run_owasp_zap
                ;;
            7)
                echo -e "${GREEN}Exiting.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                ;;
        esac
    done
}

main

