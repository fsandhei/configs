#! /usr/bin/env python
# Convenience script to connect to Bluetooth devices
# Devices can be added to the script by using additional
# 'find_and_connect' calls.
#
# Dependencies:
#   bluetoothctl

import argparse
import re
import subprocess
import sys


class KnownDeviceNames:
    WH_1000_XM3 = "WH-1000XM3"
    LE_WH_1000_XM3 = "LE_WH-1000XM3"
    KEYCHRON_K8_PRO = "Keychron K8 Pro"

NUMBER_OF_CONNECTION_ATTEMPTS = 5

def get_args():
    parser = argparse.ArgumentParser(
            prog = "bl-connect",
            description = "Handle connection to bluetooth devices."
            )
    parser.add_argument("--disconnect",
                        action = "store_true",
                        default = False,
                        help = "Disconnect from device.")
    parser.add_argument("--name",
                        action = "append",
                        type = str,
                        help = "Specify name of the device to connect / disconnect.\n"
                               "The device must be an already paired device.",
                        default = None)
    parser.add_argument("--attempts",
                        type = int,
                        help = "Specify how many connection attempts to try.",
                        default = None)
    parser.add_argument("--list",
                        action = "store_true",
                        default = False,
                        help = "List available devices.")


    return parser.parse_args()

def get_mac_address(bluetooth_entry: str):
    mac_address_regex = re.compile("([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})")
    mac_address_search = mac_address_regex.search(bluetooth_entry)
    return mac_address_search.group()

def get_list_of_bluetooth_devices() -> str:
    args = ["bluetoothctl", "devices"]
    bluetooth_devices_cmd = subprocess.run(args, capture_output = True)

    if bluetooth_devices_cmd.returncode != 0:
        raise RuntimeError(f"Failed to get bluetooth devices:"
                           f"{bluetooth_devices_cmd.stderr}")
    return bluetooth_devices_cmd.stdout.decode("utf-8").split("\n")

def connect(mac_address: str) -> subprocess.CompletedProcess:
    args = ["bluetoothctl", "--timeout", "5", "connect", mac_address]
    bluetooth_connect_cmd = subprocess.run(args, capture_output = True)

    return bluetooth_connect_cmd

def attempt_connect(device: str, mac_address: str, attempts: int) -> int:
    for i in range(1, attempts):
        print(f"\rAttempting to connect to {mac_address}, attempt {i} out of {attempts}", end = "")
        cmd = connect(mac_address)
        stdout = cmd.stdout.decode("utf-8")
        returncode = cmd.returncode

        successful_connection_regex = get_successful_regex_from_device_name(device)

        if returncode == 0 and successful_connection_regex.search(stdout) != None:
            print()
            return (returncode, i)

    print()
    return (-1, NUMBER_OF_CONNECTION_ATTEMPTS)

# Some devices seem to not be actually connected even though bluetoothctl seems to return 0.
# Therefore we require different regexes for some devices in the off-chance they do not work with the default one
def get_successful_regex_from_device_name(name: str):
    match name:
        # Wh-1000XM3 does not seem to have a proper connection made even when bluetoothctl returns 0.
        # So, in order to check if a connection was correctly made for it,
        # we check if there has been made any new transport layer connections.
        case KnownDeviceNames.WH_1000_XM3 | KnownDeviceNames.LE_WH_1000_XM3:
            return re.compile("\[.*NEW.*\] Transport /org/bluez/.*")
        case _:
            return re.compile("Connection successful")

def disconnect(name: str = None):
    args = ["bluetoothctl", "disconnect"]
    if name != None:
        mac_address = get_mac_address(name)
        args.append(mac_address)
    subprocess.run(args)
    return 0

def find_and_connect(device: str, alternate_name: str = None, attempts: int = None) -> int:
    if alternate_name != None:
        returncode = find_and_connect(alternate_name)
        if returncode == 0:
            return returncode
    bluetooth_devices = get_list_of_bluetooth_devices()
    for entry in bluetooth_devices:
        if device in entry:
            mac_address = get_mac_address(entry)

            if attempts is not None:
                number_of_attempts = attempts
            else:
                number_of_attempts = NUMBER_OF_CONNECTION_ATTEMPTS
            (returncode, attempts) = attempt_connect(device, mac_address, number_of_attempts)
            if returncode == 0:
                print(f"Successfully connected to {mac_address}")
                print(f"Number of tries: {attempts} out of "
                      f"{number_of_attempts} allowed tries")
            else:
                print(f"Failed to connect to {mac_address} after {attempts} attempts")

def main():
    try:
        args = get_args()

        if args.disconnect:
            for name in args.name:
                returncode = disconnect(name)
                if returncode != 0:
                    raise RuntimeError(f"Failed to disconnect device {name}. code = {returncode}")
            return returncode

        if args.list:
            devices = get_list_of_bluetooth_devices()
            for device in devices:
                print(device)
            return 0

        if args.name != None:
            for name in args.name:
                find_and_connect(name, attempts = args.attempts)
        else:
            find_and_connect(KnownDeviceNames.WH_1000_XM3, alternate_name = KnownDeviceNames.LE_WH_1000_XM3, attempts = args.attempts)
            find_and_connect(KnownDeviceNames.KEYCHRON_K8_PRO, attempts = args.attempts)

    except Exception as e:
        print("Error: " + str(e))
        sys.exit(1)

if __name__ == "__main__":
    main()
