# Measuring Latency of the Semantic Data Aggregator

This repository contains part of the code developed during the master's Thesis **System for Netflow traffic enhancement in aim of cryptojacking detection**, the separation of this repository is as follows:

- `drivers`. Contains the code written in Java for the input (`input-driver`) and output (`Netlfow2CDS`) drivers.
- `aggregation`. Two applications developed in Apache Flink with Java API for unidirectional to bidirectional flow conversion (`Netflow2Bidirectional`) and Netflowv9 aggregation (`goflowAggregator`)
- `docker`. Contains three folders to create the images for:
   - The Cryptomining Detection System (CDS) in `crypto-detector`
   - An event generator web server developed in python that lets you control the traffic rate of events written into a certain topic for testing purposes `event-generator`.
   - An image of goflow2 modified to obtain more fields `goflow2-collector`
- `yang-models`. Contains the netflowv9 (`netflow-v9.yang`) and aggregated (`netflow-v9-agg.yang`) yang models.
- `utils/flink_tester`. Contains the applications `FlinkLatencyA` and `FlinkLatencyB` used to measure the latency of any componente of the YANG-NAS system.
- `tests`. Contains all the scripts developed to test the latency, memory and CPU of the systems, with the corresponding scripts for creating the graphs.
   - `controlled_DATA`. Contains the data obtained when performed latency measures with controlled rate.
   - `DATA`. Contains the data obtained when performed latency measures WITHOUT controlled rate, also for the measures of CPU and MEMORY.
   - `CODE`. Contains the script to correlate latency events obtained from `FlinkLatencyA` and `FlinkLatencyB`, parsing prometheus JSON, creating graphs and more.


