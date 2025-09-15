# mesh‑tools — 
A portable utilities of **quality‑of‑life CLI tools** for everyday sysadmin task. Designed to be **portable, extensible **,  ---
## Quick Install
One‑liner to install **all tools** with dependencies:
```bash
bash <(curl -s https://raw.githubusercontent.com/devcjgcabatino/mesh-tools/main/mesh-tools-installer.sh) --with-deps



## Included Tools

| Tool | Description |
| --- | --- |
| `extract` | Universal extractor — auto‑detects archive type, extracts to folder. |
| `compress` | Universal compressor — tar.gz, zip, rar, 7z, etc. |
| `findit` | Interactive `find` wizard with persistent default path. |
| `mkcd` | Make a directory and `cd` into it in one command. |
| `cleanup` | Interactive junk file remover (tmp, bak, swp, etc.). |
| `recent` | List files modified in the last N minutes/hours/days. |
| `grepit` | Interactive grep wrapper for searching text in files. |
| `quickserve` | Instant HTTP server from any folder, shows LAN IP. |
| `syswatch` | Quick system snapshot (CPU, RAM, disk, uptime). |
| `backup` | Timestamped archive creator for backups. |
| `syncdir` | Safe rsync wrapper for local/remote directory sync. |
| `pushit` | Quick file pusher to remote host via SCP, remembers last host. |

## 🛠 Usage Examples
```bash
extract file.tar.gz
compress -zip mydir
findit
mkcd projects/new
cleanup ~/Downloads
recent /var/log -2hours
grepit "TODO" ~/code
quickserve 8080
syswatch
backup ~/projects/myapp
syncdir ~/projects user@server:/srv/projects
pushit notes.txt

## License
MIT License — do whatever you like