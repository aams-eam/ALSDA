# DATA Folder

All the data in this folder corresponds to the publication in [ICIN 2023](https://ieeexplore.ieee.org/document/10073490). All the data in this folder corresponds with the uncontrolled tests before developing the event-generator to maintain a "constant" (because it is not totally precise) event-rate.-
- **pipeline-flows:** It contains the samples to send to each driver/application to measure the latency.
- **latency-raw:** It contains the start and end timestamps after sending the above-mentioned samples to each driver, this scripts will be correlated and saved to:
- **latency-parsed:** It contains the calculated latency for every event in the sent samples
- **memory_cpu:** Information from prometheus and information processed from prometheus to obtain the CPU and Memory usage during the deployment of 7 full pipelines
