import os
import os.path
import subprocess
import time
import argparse
import logging as log
from datetime import datetime

from saleae import automation


parser = argparse.ArgumentParser(description='Interact with Saleae: {Spawn, Kill} Logic GUI (gRPC server), {Start, Stop} capture to RAM, Export capture')
parser.add_argument("-v", "--verbose", help="Output verbosity", action="store_true")
args = parser.parse_args()

if args.verbose:
    log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
    log.info("Verbose output.")
else:
    log.basicConfig(format="%(levelname)s: %(message)s")


cmd_logic_gui = "./logic.sh"


log.debug("Starting %s" % cmd_logic_gui)
proc_logic_gui = subprocess.Popen(cmd_logic_gui)
log.debug("Started %s" % cmd_logic_gui)

log.info("Waiting for gRPC server (Logic GUI) to start up")
time.sleep(10)  # TODO: Poll if the port

log.debug("Remember connection to Logic 2 Application on port")
manager = automation.Manager(port=10430)

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

# Start a capture - the capture will be automatically closed when leaving the  block
# Note: We are using serial number 'F4241' here, which is the serial number for
#       the Logic Pro 16 demo device. You will need to use your device's serial number
#       to use a real device. Please see the "Finding the Serial Number of a Device" section.


try:
    with manager.start_capture(device_serial_number='D684A188723FA297',
                               device_configuration=device_configuration,
                               capture_configuration=capture_configuration) as capture:

        print("asdasdasd")

        # Wait until the capture has finished
        # This will take about 5 seconds because we are using a timed capture mode
        capture.wait()

        # Add an analyzer to the capture
        # Note: The simulator output is not actual SPI data
        spi_analyzer = capture.add_analyzer('SPI', label=f'Test Analyzer', settings={
            'MISO': 0,
            'Clock': 1,
            'Enable': 2,
            'Bits per Transfer': '8 Bits per Transfer (Standard)'
        })

        # Store output in a timestamped directory
        output_dir = os.path.join(os.getcwd(), f'output-{datetime.now().strftime("%Y-%m-%d_%H-%M-%S")}')
        os.makedirs(output_dir)

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

    print("fffffffffffffffffff")

except Exception as e:
    log.error("Got exception %r. Is the Logic GUI running and listening?" % type(e))
    manager.close() # We must close the manager thread, or else python will block waiting for it to end
    proc_logic_gui.kill()
    raise e  # Be noisy and propagate the exception


manager.close()  # No exception occured, but we must still close the manager thread
proc_logic_gui.kill()
