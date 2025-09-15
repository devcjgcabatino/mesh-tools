
# mesh‑tools 

A portable utilties for **quality‑of‑life CLI tools** for everyday sysadmin tasks.  
Designed to be **portable, and extensible**, so every node feels like home.

These scripts turn long, repetitive CLI incantations into **short, memorable commands** —  
making extraction, compression, search, backup, sync, and other daily tasks **fast, and consistent**.

---

## 🚀 Quick Install

One‑liner to install **all tools** with dependencies:

```bash
bash <(curl -s https://raw.githubusercontent.com/devcjgcabatino/mesh-tools/main/mesh-tools-installer.sh) --with-deps
```

---

## 📦 Included Tools

| Tool        | Description |
|-------------|-------------|
| `extract`   | Universal extractor — auto‑detects archive type, extracts to folder. |
| `compress`  | Universal compressor — tar.gz, zip, rar, 7z, etc. |
| `findit`    | Interactive `find` wizard with persistent default path. |
| `mkcd`      | Make a directory and `cd` into it in one command. |
| `cleanup`   | Interactive junk file remover (tmp, bak, swp, etc.). |
| `recent`    | List files modified in the last N minutes/hours/days. |
| `grepit`    | Interactive grep wrapper for searching text in files. |
| `quickserve`| Instant HTTP server from any folder, shows LAN IP. |
| `syswatch`  | Quick system snapshot (CPU, RAM, disk, uptime). |
| `backup`    | Timestamped archive creator for backups. |
| `syncdir`   | Safe rsync wrapper for local/remote directory sync. |
| `pushit`    | Quick file pusher to remote host via SCP, remembers last host. |

---

## 🛠 Usage Examples

### 📂 File & Folder tasks
```bash
extract file.tar.gz
compress -zip mydir
findit
mkcd projects/new
cleanup ~/Downloads
recent /var/log -2hours
```

### 🔍 Search & Discovery
```bash
grepit "TODO" ~/code
```

### 🌐 Networking
```bash
quickserve 8080
```

### 📊 System load
```bash
syswatch
```

### 💾 Backup & Sync
```bash
backup ~/projects/myapp
syncdir ~/projects user@server:/srv/projects
pushit notes.txt
```

---

## Philosophy

These tools are:
- **Portable** — drop them on any node and they work.
- **Extensible** — easy to add new cli.
- **Mesh‑aware** — designed for repeatable, consistent workflows.
---

## License

MIT License — do whatever you like
```

---
