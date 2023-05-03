# Processing and Analyzing Tests
This folder contains all the scripts to correlate and analyze the data:
- [DATA](tests/DATA/DATA_README.md)
- [controlled_DATA](tests/controlled_DATA/controlled_DATA_README.md)

The scripts can be separated in two: \
**Processing Scripts:**
- **processing-input-driver.ipynb:** Generates the processed and processed_averaged results given start and end timestamps of the Netflow input-driver.
- **processing-with-yang.ipynb:** Same as `processing-input-driver.ipynb` but for any application that receives and outputs yang modelled data.
- **processing-output-driver.ipynb:** Same as `processing-input-driver.ipynb` but for Netflow output-driver.
- **processing-noDriver.ipynb:** Same as `processing-input-driver.ipynb` but when no driver is used.
- **processing-memorycpu.ipynb:** Processed the Memory and CPU Usage from the obtained Prometheus metrics.


**Analyzing Scripts**
- **Analysis-driverapps-uncontrolled.ipynb:** Graphs data from uncontrolled tests.
- **Analysis-driverapps-controlled.ipynb:** Graphs data of controlled tests.
- **Analysis-memorycpu.ipynb:** Graphs data of Memory and CPU usage.
- **Analysis-noDriver.ipynb:** Graphs data of latency measured without drivers or applications (Read-Write latency of Flink in Kafka) for 3 samples for each event-rate.
- **Analysis-driverapps-controlled-Multiple-tests.ipynb:**. Graphs the data of latency measured of all drivers and applications with 3 samples for each event-rate, in this case graphing the processed_averaged data.
