# Controlled_DATA Folder
All the events in this folder are tests done with constant event-rates after the development of the event-generator component.

The data in these folders corresponds to the publication in [ICIN 2023](https://ieeexplore.ieee.org/document/10073490):
- **latency-raw:** It contains the start and end timestamps after sending the above-mentioned samples to each driver, this scripts will be correlated and saved to:
- **latency-parsed:** It contains the latency processed from the latency-raw folder

The data in these folders corresponds to the extension (To be published in Annals of Telecommunications). These tests are done with the new system, in which System.NanoTime() is used so we can achieve higher precision:
- **results_latency_nodriver:** Results of latency without using a driver or application. We measure the latency in reading and writting from topics (better explained in the extended paper).
   Inside we have the start and end timestamps of 3 samples for each event-rate. The processed folder contains the latency of every event rate and sample. And the subfolder processed_averaged contains the average of all 3 samples for every event-rate
- **latency-raw:** Contains the same as `results_latency_nodriver` but using all drivers and applications for the Netflow pipeline.
