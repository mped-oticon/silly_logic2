import os
import os.path
import sys
import subprocess
import time
import re
import argparse
import logging as log
from datetime import datetime

from saleae import automation


parser = argparse.ArgumentParser(
    description='Interact with Saleae: {Spawn, Kill} Logic GUI (gRPC server), {Start, Stop} capture to RAM, Export capture',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("--verbose", default=False, action=argparse.BooleanOptionalAction,
    help="Print debug messages")

parser.add_argument("-s", "--server_cmd", type=str, default="./logic.sh", 
    help="Command to start the gRPC server (Logic GUI)")
parser.add_argument("-p", "--server_port", type=int, default=10430, 
    help="gRPC server's listening port that we will connect to")
parser.add_argument("--server_open", type=bool, default=True, action=argparse.BooleanOptionalAction,
    help="Execute the gRPC server initially")
parser.add_argument("--server_close", type=bool, default=True, action=argparse.BooleanOptionalAction,
    help="Stop the gRPC server once done")

parser.add_argument("--capture", type=bool, default=True, action=argparse.BooleanOptionalAction,
    help="Ask gRPC server to capture")

parser.add_argument("--list_devices", default=False, action="store_true",
    help="Ask gRPC server for attached Saleae Logic devices' serial numbers. Then exit. Exit OK if 1 or more was found")
parser.add_argument("-d", "--device_serial_number", type=str, default="D684A188723FA297", 
    help="Saleae Logic hardware device's serial number")


args = parser.parse_args()

if args.verbose:
    log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
    log.info("Verbose output.")
else:
    log.basicConfig(format="%(levelname)s: %(message)s")



def get_physical_saleae_devices(manager) -> list[str]:    
    '''
    Return list of attached physical Saleae Logics, by serial number.
    This is a hack. We would like to use official offical API, but can't.
    Example:
        >>> print("devices1:", get_physical_saleae_devices(manager))  # Ugly unofficial hack. Works
        >>> print("devices2:", manager.get_devices())                 # Nice official API. Does not work
        devices1: ['D684A188723FA297', '499970BCEB9C10D6']
        devices2: []
    '''

    ret = []
    e_str = ""
    bad_serial = "purposefully not existant"
    default_cfg = automation.LogicDeviceConfiguration()

    virtual_device_ids = ['F4241', 
                          'F4242',   # F4242 not actually reported
                          'F4243', 
                          'F4244']

    # Official manager.get_devices() is broken as of version 0.0.1 of the Automation API
    # As a workaround, we start a capture with wrong serial number; this will cause an exception to be thrown.
    # This exception contains the device list - which we must parse out. Ugly but we have to.
    try:
        manager.start_capture(device_serial_number=bad_serial, device_configuration=default_cfg)
    except Exception as e:
        e_str = str(e.args)

    pattern = re.compile(r"Connected device serial numbers: (.*).")
    result = pattern.search(e_str)
    if result:
        csv_list = result.group(1)

        pattern_ids = re.compile(r"([^ ,.;']+)")
        ret = pattern_ids.findall(csv_list)
    
    ret = list(filter(lambda d: d not in virtual_device_ids, ret))

    return ret









proc_logic_gui = None
if args.server_open:
    log.debug("Starting %s" % args.server_cmd)
    proc_logic_gui = subprocess.Popen(args.server_cmd)
    log.debug("Started %s" % args.server_cmd)

    log.info("Waiting for gRPC server (Logic GUI) to start up")
    time.sleep(10)  # TODO: Poll if the port is listening



def clean_up(manager):
    # We must close the manager thread, or else python will block waiting for it to end
    log.debug("Closing manager thread")
    manager.close()

    if args.server_close:
        if proc_logic_gui:
            log.debug("Killing gRPC server")
            proc_logic_gui.kill()
        else:
            log.error("Can't kill what was never started")




log.debug("Connecting to gRPC server on localhost:%i" % args.server_port)
manager = automation.Manager(port=args.server_port)

# We always need a list of devices
log.debug("Asking gRPC server for currently connected devices")
dev_ids = get_physical_saleae_devices(manager)
log.debug("Connected devices: %r" % dev_ids)



if args.list_devices:
    # Simple print to stdout, one line per device
    for d in dev_ids:
        print(d)

    # Remember to clean up
    clean_up(manager)

    # Exit code 0 means OK, i.e. we found device(s)
    sys.exit(0 if len(dev_ids)>=1 else 1)  





if args.capture:
    # Configure the capturing device to record on digital channels 0, 1, 2, and 3,
    # with a sampling rate of 10 MSa/s, and a logic level of 3.3V.
    device_configuration = automation.LogicDeviceConfiguration(
        enabled_digital_channels=[0, 1, 2, 3],
        digital_sample_rate=10_000_000,
        digital_threshold_volts=3.3,
    )

    # Record 5 seconds of data before stopping the capture
    capture_configuration = automation.CaptureConfiguration(
        capture_mode=automation.TimedCaptureMode(duration_seconds=5.0)
    )

    try:
        # Start a capture - the capture will be automatically closed when leaving the  block
        # Note: We are using serial number 'F4241' here, which is the serial number for
        #       the Logic Pro 16 demo device. You will need to use your device's serial number
        #       to use a real device. Please see the "Finding the Serial Number of a Device" section.
        with manager.start_capture(device_serial_number=args.device_serial_number,
                                   device_configuration=device_configuration,
                                   capture_configuration=capture_configuration) as capture:

            # Store output in a timestamped directory
            output_dir = os.path.join(os.getcwd(), f'output-{datetime.now().strftime("%Y-%m-%d_%H-%M-%S")}')
            os.makedirs(output_dir)

            # Wait until the capture has finished
            # This will take about 5 seconds because we are using a timed capture mode
            log.info("Capturing...")
            capture.wait()

            # Add an analyzer to the capture
            # Note: The simulator output is not actual SPI data
            spi_analyzer = capture.add_analyzer('SPI', label=f'Test Analyzer', settings={
                'MISO': 0,
                'Clock': 1,
                'Enable': 2,
                'Bits per Transfer': '8 Bits per Transfer (Standard)'
            })

            # Export analyzer data to a CSV file
            analyzer_export_filepath = os.path.join(output_dir, 'spi_export.csv')
            capture.export_data_table(
                filepath=analyzer_export_filepath,
                analyzers=[spi_analyzer],
                radix=automation.RadixType.ASCII
            )

            # Export raw digital data to a CSV file
            capture.export_raw_data_csv(directory=output_dir, digital_channels=[0, 1, 2, 3])

            # Finally, save the capture to a file
            capture_filepath = os.path.join(output_dir, 'example_capture.sal')
            capture.save_capture(filepath=capture_filepath)
            log.info("Exported capture: %s" % capture_filepath)

    except Exception as e:
        log.error("Got exception %r. Is the Logic GUI running and listening?" % type(e))
        clean_up(manager)
        raise e  # Be noisy and propagate the exception after we've cleaned up


# No exception occured, but we must still clean up
clean_up(manager)
