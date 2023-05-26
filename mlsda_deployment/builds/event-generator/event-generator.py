import sys
import time
import argparse

from kafka.errors import NoBrokersAvailable
from kafka import KafkaProducer

from flask import Flask
from flask import request

app = Flask(__name__)



@app.route("/")
def generate_events():

    KAFKA_BROKER = request.args.get("kafkabroker", type=str)
    DELAY_BETWEEN_EVENTS = request.args.get("delay", type=float)
    FILE_PATH = request.args.get("filepath", type=str)
    KAFKA_TOPIC = request.args.get("topic", type=str)
    print("KAFKA_BROKER:", KAFKA_BROKER)
    print("DELAY_BETWEEN_EVENTS:", DELAY_BETWEEN_EVENTS)
    print("FILE_PATH:", FILE_PATH)
    print("KAFKA_TOPIC:", KAFKA_TOPIC)
    

    print("Generation of events started")
    
    # Read events from indicated file
    try:
        with open(FILE_PATH) as fd:
            lines = fd.read().splitlines()
    except FileNotFoundError as e:
        print(e)
        sys.exit()

    producer = None
    try:
        # Kafka Sink Topic
        producer = KafkaProducer(bootstrap_servers=[KAFKA_BROKER])
    except NoBrokersAvailable:
        sys.exit()

    print("PRODUCER:\n", producer)    

    # READ from kafka topic when messages available
    for event in lines:

        # Write the event in kafka topic
        print("Event: %s\n" % (event), flush=True)
        producer.send(topic=KAFKA_TOPIC, key=event.encode('utf-8'), value=event.encode('utf-8'))
        producer.flush()
        print(DELAY_BETWEEN_EVENTS)
        time.sleep(DELAY_BETWEEN_EVENTS)

    return "All events generated"


#
# Serve the endpoint
#

def main():
    
    # run webserver
    app.run(host="0.0.0.0", port=8088)


if __name__ == '__main__':
    main()
