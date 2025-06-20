# 🔍 Bug Bounty Scope Discovery Automation Script

This script automates the **initial reconnaissance phase** for bug bounty and penetration testing. It gathers WHOIS data, subdomains, ASN info, S3 buckets, OSINT info, and even screenshots of discovered subdomains. It’s ideal for bug bounty hunters, red teamers, and security researchers looking to streamline asset discovery.

---

## 📁 Features

- ✅ WHOIS & Reverse WHOIS lookup
- ✅ ASN & IP Range discovery
- ✅ Subdomain enumeration using:
  - crt.sh (SSL Certificate Transparency Logs)
  - subfinder
  - GitHub Recon (via `github-subdomains`)
- ✅ Amazon S3 Bucket discovery
- ✅ OSINT info gathering with `theHarvester`
- ✅ Real-time subdomain screenshots with `gowitness`
- ✅ All outputs saved and zipped in a timestamped directory

---

## ⚙️ Requirements

Ensure the following tools are installed and in your system's `$PATH`:

- `bash` (Linux/macOS)
- `whois`
- `dig`
- `curl`
- `jq`
- `subfinder`
- `github-subdomains`
- `theHarvester`
- `gowitness`
- `aws-cli`
- `zip`

You can install most tools via `apt`, `brew`, or Go. For example:

```bash
sudo apt install whois dnsutils curl jq zip
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/gwen001/github-subdomains@latest
sudo snap install gowitness
pip3 install theHarvester
````

---

## 🔐 GitHub Token (Required)

To enable GitHub subdomain recon, you must generate a GitHub **Personal Access Token**:

1. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Give it a name (e.g., `subdomain-scan`)
4. Select scopes: You can leave scopes **unchecked** (no permissions needed)
5. Generate and copy the token

Then set the token in your terminal:

```bash
export GITHUB_TOKEN=your_personal_access_token_here
```

💡 *Tip: Add this to your `~/.bashrc` or `~/.zshrc` to persist it.*

---

## 🚀 Usage

```bash
chmod +x scope_discovery.sh
./scope_discovery.sh example.com
```

* Replace `example.com` with the domain you want to scan.
* Output will be saved in `outdir_example.com_YYYY-MM-DD_HH-MM-SS/`
* A zipped archive will also be generated: `outdir_example.com_*.zip`

---

## 📦 Output Structure

```
outdir_example.com_YYYY-MM-DD_HH-MM-SS/
│
├── whois_example.com.txt           → WHOIS & Org Info
├── asn_example.com.txt             → ASN and IP Info
├── subdomains_example.com.txt      → All discovered subdomains
├── s3_results.txt                  → Found S3 buckets
├── osint_example.com.xml           → OSINT results from theHarvester
├── screenshots/                    → HTML screenshots of all subdomains
└── outdir_example.com_*.zip        → Zipped archive of entire output
```

---

## 🧠 Manual Step

For **reverse WHOIS**, you can manually search the organization name in:

📍 [https://viewdns.info/reversewhois/](https://viewdns.info/reversewhois/)

Use the `OrgName` found in `whois_example.com.txt` (e.g., *Facebook, Inc.*).

---

## 🛠️ Future Improvements

* ✅ Integrate Shodan API for more IP intel
* ✅ Add support for reverse IP lookup
* ✅ Passive DNS integration
* ✅ Cloud asset detection (Azure/GCP buckets)

---

## 📜 License

MIT License

---

## 🙌 Author

Created with 💻 by Vipin 
GitHub: https://github.com/Infinity-e

