import os

output_file = "wifi-pass-wxport.txt"

with open(output_file, "w") as f:
    for filename in os.listdir("/etc/NetworkManager/system-connections/"):
        if filename.startswith("."):
            continue
        filepath = os.path.join("/etc/NetworkManager/system-connections/", filename)
        try:
            with open(filepath, "r") as connection_file:
                content = connection_file.read()
                if "[wifi-security]" in content:
                    ssid_line = [line for line in content.splitlines() if line.startswith("ssid=")]
                    psk_line = [line for line in content.splitlines() if line.startswith("psk=")]
                    if ssid_line and psk_line:
                        ssid = ssid_line[0].split("=")[1].strip('"')
                        psk = psk_line[0].split("=")[1]
                        f.write(f"SSID: {ssid}, Şifre: {psk}\n")
        except Exception as e:
            print(f"Hata: {filepath} - {e}")

print(f"Wi-Fi passwords exported : {output_file} ")
