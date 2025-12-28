# Oracle Autonomous DB Client Setup on Ubuntu WSL (2025)

This guide installs **Oracle Instant Client 23c + SQL*Plus** inside Ubuntu WSL and securely connects it to an **Oracle Cloud Always-Free Autonomous Database** using Wallet authentication.

---

## 1. System Preparation

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip curl build-essential
```

---

## 2. Download Oracle Instant Client (on Windows)

Download these two ZIPs:

* **Basic Package**
* **SQL*Plus Package**

From:
[https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html)

Files look like:

```
instantclient-basic-linux.x64-23.xx.x.x.x.zip
instantclient-sqlplus-linux.x64-23.xx.x.x.x.zip
```

---

## 3. Copy ZIPs into WSL

```bash
sudo mkdir -p /opt/oracle
sudo cp /mnt/c/Users/<YOURNAME>/Downloads/instantclient*.zip /opt/oracle
cd /opt/oracle
```

---

## 4. Install Instant Client (Oracle 23c packaging bug workaround)

```bash
sudo unzip instantclient-basic-linux*.zip
cd instantclient_23_*
sudo unzip ../instantclient-sqlplus-linux*.zip
sudo mv instantclient_23_*/* .
sudo rm -rf instantclient_23_*
sudo rm -rf /opt/oracle/META-INF
```

---

## 5. Register Libraries

```bash
sudo sh -c 'echo /opt/oracle/instantclient_23_* > /etc/ld.so.conf.d/oracle.conf'
sudo ldconfig
```

---

## 6. Install Required System Libraries (Ubuntu 24.04+)

```bash
sudo apt install -y libaio-dev
sudo ln -s /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1
sudo ldconfig
```

---

## 7. Configure Environment

```bash
vim ~/.bashrc
```

Add:

```bash
export ORACLE_HOME=/opt/oracle/instantclient_23_*
export PATH=$PATH:$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
sqlplus -v
```

---

## 8. Install Oracle Cloud Wallet

Download wallet ZIP from OCI Autonomous DB → **DB Connection**.

```bash
sudo mkdir -p /opt/oracle/wallet
sudo cp /mnt/c/Users/YOURNAME/Downloads/Wallet_*.zip /opt/oracle/wallet
cd /opt/oracle/wallet
sudo unzip Wallet_*.zip
sudo chown -R $USER:$USER /opt/oracle/wallet
sudo chmod 700 /opt/oracle/wallet
sudo chmod 600 /opt/oracle/wallet/*
```

---

## 9. Configure Wallet

Edit:

```bash
vim /opt/oracle/wallet/sqlnet.ora
```

Set:

```
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/opt/oracle/wallet")))
SSL_SERVER_DN_MATCH = yes
```

Add wallet path to environment:

```bash
vim ~/.bashrc
```

Append:

```bash
export TNS_ADMIN=/opt/oracle/wallet
```

Reload:

```bash
source ~/.bashrc
```

---

## 10. Connect to Oracle Cloud DB

Check aliases:

```bash
cat /opt/oracle/wallet/tnsnames.ora
```

Connect:

```bash
sqlplus admin@<your_service_alias>
```

Example:

```bash
sqlplus admin@mydb_medium
```

---

