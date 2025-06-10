#!/bin/bash

# Usage: ./scope_discovery.sh example.com

set -e

if [ -z "$1" ]; then
  echo "[!] Usage: $0 <domain.com>"
  exit 1
fi

TARGET=$1
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTDIR="outdir_${TARGET}_$DATE"
mkdir -p "$OUTDIR/screenshots"

WHOIS_INFO="$OUTDIR/whois_$TARGET.txt"
SUBDOMAINS_FILE="$OUTDIR/subdomains_$TARGET.txt"
OSINT_FILE="$OUTDIR/osint_$TARGET"
S3_RESULTS="$OUTDIR/s3_results.txt"
ASN_INFO="$OUTDIR/asn_$TARGET.txt"
SCREENSHOTS_DIR="$OUTDIR/screenshots"

echo "[*] Output directory: $OUTDIR"

# Tool Checks
REQUIRED_TOOLS=(whois dig jq curl subfinder github-subdomains theHarvester gowitness zip)
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v $tool &> /dev/null; then
    echo "[!] $tool is not installed. Please install it first."
    exit 1
  fi
done

echo "[*] WHOIS Lookup..."
whois $TARGET > "$WHOIS_INFO"

ORG_NAME=$(grep -i "OrgName" "$WHOIS_INFO" | head -1 | cut -d ':' -f2 | xargs)

echo "[*] Reverse WHOIS (Manual step)"
echo "🔍 Search manually for '$ORG_NAME' at: https://viewdns.info/reversewhois/"

echo "[*] ASN Info..."
IP=$(dig +short $TARGET | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n1)
if [ -n "$IP" ]; then
  whois -h whois.cymru.com "$IP" | tee "$ASN_INFO"
else
  echo "[!] Could not resolve IP for $TARGET"
fi

echo "[*] Parsing SSL Certificates from crt.sh..."
timeout 30 curl -s "https://crt.sh/?q=%25.$TARGET&output=json" |
  jq -r '.[].name_value' 2>/dev/null | sort -u | grep -v null >> "$SUBDOMAINS_FILE" || echo "[!] crt.sh failed or timed out."

echo "[*] Enumerating subdomains with subfinder..."
subfinder -d $TARGET -silent >> "$SUBDOMAINS_FILE"

echo "[*] GitHub Subdomain Recon..."
if [ -z "$GITHUB_TOKEN" ]; then
  echo "[!] Set GITHUB_TOKEN env variable to use github-subdomains"
else
  github-subdomains -d $TARGET -t "$GITHUB_TOKEN" >> "$SUBDOMAINS_FILE"
fi

echo "[*] Deduplicating subdomains..."
sort -u "$SUBDOMAINS_FILE" -o "$SUBDOMAINS_FILE"

echo "[*] S3 Bucket Discovery..."
> "$S3_RESULTS"
while read -r sub; do
  if aws s3 ls "s3://$sub" 2>/dev/null; then
    echo "[+] S3 Bucket found: $sub"
    echo "$sub" >> "$S3_RESULTS"
  fi
done < "$SUBDOMAINS_FILE"

echo "[*] Gathering OSINT with theHarvester..."
theHarvester -d $TARGET -b all -f "$OSINT_FILE" &> /dev/null

echo "[*] Taking Screenshots of subdomains..."
gowitness file -f "$SUBDOMAINS_FILE" -P "$SCREENSHOTS_DIR" &> /dev/null

echo "[*] Zipping results..."
zip -r "${OUTDIR}.zip" "$OUTDIR" &> /dev/null

echo "[✔] Recon complete! All results are in: $OUTDIR"
echo "[📦] Zipped archive: ${OUTDIR}.zip"
