import os
import platform
import psutil
import time
from datetime import datetime

def bytes_to_gb(bytes_val):
    return round(bytes_val / (1024 ** 3), 2)

def format_time(seconds):
    return time.strftime("%H:%M:%S", time.gmtime(seconds))

print("=== Rendszerinformációk ===")
print(f"Gép neve: {platform.node()}")
print(f"Operációs rendszer: {platform.system()} {platform.release()}")
print(f"Kernel verzió: {platform.version()}")
boot_time = datetime.fromtimestamp(psutil.boot_time())
print(f"Indítás ideje: {boot_time.strftime('%Y-%m-%d %H:%M:%S')}")

print("\n=== CPU ===")
print(f"CPU magok száma: {psutil.cpu_count(logical=True)}")
print(f"Jelenlegi CPU használat: {psutil.cpu_percent(interval=1)}%")

print("\n=== Memória ===")
mem = psutil.virtual_memory()
print(f"Teljes RAM: {bytes_to_gb(mem.total)} GB")
print(f"Szabad RAM: {bytes_to_gb(mem.available)} GB")
print(f"Memória kihasználtság: {mem.percent}%")

print("\n=== Partíciók és szabad hely ===")
partitions = psutil.disk_partitions()
for p in partitions:
    try:
        usage = psutil.disk_usage(p.mountpoint)
        print(f"\nMount pont: {p.mountpoint}")
        print(f"  Fájlrendszer típusa: {p.fstype}")
        print(f"  Teljes méret: {bytes_to_gb(usage.total)} GB")
        print(f"  Használt: {bytes_to_gb(usage.used)} GB")
        print(f"  Szabad: {bytes_to_gb(usage.free)} GB")
        print(f"  Kihasználtság: {usage.percent}%")
    except PermissionError:
        print(f"\nMount pont: {p.mountpoint} – hozzáférés megtagadva")

