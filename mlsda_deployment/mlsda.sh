#!/bin/bash

# If there are commands here that could not be executed by root, use:
# sudo -u ${who am i | awk '{print $1}'} <command>}

usage () { echo "$(basename "$0") [-h] [-j jar] [-c classmain] [-f file] [TEST_NAME] -- This program calculates the latency of an SDA driver or application. If no driver or application is indicated, it calculates the latency of reading and writing in kafka topics

where:
    -h  Show help
    -j  Jar file of the driver/application to measure
    -f  File with the events that are going to be sent with the event-generator
    -c  Name of the main in the jar file (e.g., tid.NetflowAggregator)
    -n  Kubernetes namespace in which to deploy the applications"; }

namespace=default

options=':hj:f:c::n:'
while getopts $options option
do
    case "$option" in
        j  ) jarfile=$OPTARG;;
        f  ) eventsfile=$OPTARG;;
        c  ) classmain=$OPTARG;;
        n  ) namespace=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$option" >&2; exit 1;;
    esac
done


if ((OPTIND < 7))
then
    echo "Options -j -f -c are needed."
    echo ""
    usage
    exit
fi

shift $((OPTIND - 1))

if (($# == 0))
then
    echo "A name for the test must be specified"
    echo ""
    usage
    exit
fi

test_name=$1
if [ ${namespace} = "default" ]
then
	kube_namespace=""
else
	kube_namespace="-n $namespace"
fi

# Get information about the registry from values.yaml
evgen_reg=$(awk '/eventGenerator/{flag=1} flag && /repository:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
evgen_name=$(awk '/eventGenerator/{flag=1} flag && /name:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
fla_reg=$(awk '/flinklatencyanano/{flag=1} flag && /repository:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
fla_name=$(awk '/flinklatencyanano/{flag=1} flag && /name:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
flb_reg=$(awk '/flinklatencybnano/{flag=1} flag && /repository:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
flb_name=$(awk '/flinklatencybnano/{flag=1} flag && /name:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
driver_app_reg=$(awk '/driverApp/{flag=1} flag && /repository:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)
driver_app_name=$(awk '/driverApp/{flag=1} flag && /name:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1)

# assert_docker_push () {
#         echo $push_output
#         if [[ ! $push_output =~ "digest: sha256:" ]]
#         then
#                 echo "One of the images could not be pushed!"
#                 exit
#         fi
# }
# 
# # Build and push FlinkLatency apps
# # FLINKLATENCY(A)
# echo "Building flinklatencyanano (A)"
# docker build -t $fla_reg ./builds/FlinkLatencyANano
# echo "Pushing flinklatencyanano (A) into the registry"
# push_output=$(docker push $fla_reg)
# echo $push_output
# assert_docker_push
# 
# # FLINKLATENCY(B)
# echo "Building flinklatencybnano (B)"
# docker build -t $flb_reg ./builds/FlinkLatencyBNano
# echo "Pushing flinklatencybnano (B) into the registry"
# push_output=$(docker push $flb_reg)
# echo $push_output
# assert_docker_push
# 
# # EVENT-GENERATOR
# # Copy eventsfile into event-generator
# cp $eventsfile ./builds/event-generator/pipeline-flows
# 
# # Build and push event-generator with eventsfile
# echo "Building event generator"
# docker build -t $evgen_reg ./builds/event-generator
# echo "Pushing event-generator into the registry"
# push_output=$(docker push $evgen_reg)
# echo $push_output
# # Delete eventfile from the event-generator folder
# rm ./builds/event-generator/pipeline-flows/$eventsfile
# assert_docker_push
# 
# # ToDo: Build and Push the application with the jar file
# # DRIVER/APP
# mkdir ./builds/driver-app
# cp $jarfile ./builds/driver-app/driverapptesting-1.0.jar
# touch ./builds/driver-app/Dockerfile
# 
# echo "FROM flink:1.14.4-scala_2.12-java11" > ./builds/driver-app/Dockerfile
# echo "ADD driverapptesting-1.0.jar /opt/flink/usrlib/" >> ./builds/driver-app/Dockerfile
# 
# # change the main name in the values.yaml file
# 
sed -i 's/classMain: tid.NetflowAggregator/classMain: ${classmain}/' ./deployment/values.yaml
# 
# echo "Building driver/app image"
# docker build -t $driver_app_reg ./builds/driver-app
# echo "Pushing event-generator into the registry"
# push_output=$(docker push $driver_app_reg)
# echo $push_output
# assert_docker_push
# 
# # Delete temporary driver-app directory
# rm -r ./builds/driver-app
# 
# 
# sleep 6s


# # DEPLOY EVERYTHING
echo "Deploying FlinkLatencyA, FlinkLatencyB, event-generator and ${driver_app_name}"
sudo -u $(who am i | awk '{print $1}') helm install $(echo "$kube_namespace") flink-latency-rw deployment/ --values deployment/values.yaml


# Change back the main name of driverapp in values.yaml file
sed -i 's/classMain: ${classmain}/classMain: tid.NetflowAggregator/' ./deployment/values.yaml

wait_correct_deployment () {
        local is_deployed=0
        local iteration=1
        local status

        while [ $is_deployed -eq 0 ]
        do
                if [ $iteration -eq 6 ]
                then
                        echo "Something went wrong with the deployment"
                        exit;
                fi

                sleep ${iteration}m
		kubectl_result=$(sudo -u $(who am i | awk '{print $1}') kubectl get pods --all-namespaces)
		evgen_status=$(awk -v name="$evgen_name" 'index($0, name) != 0' <<< $kubectl_result | awk '{print $4}' )
                fla_status=$(awk -v name="${fla_name}-job-submitter" 'index($0, name) != 0' <<< $kubectl_result | awk '{print $4}' )
                flb_status=$(awk -v name="${flb_name}-job-submitter" 'index($0, name) != 0' <<< $kubectl_result | awk '{print $4}' )
                driverapp_status=$(awk -v name="${driver_app_name}-job-submitter" 'index($0, name) != 0' <<< $kubectl_result | awk '{print $4}' )
		echo "event-generator status: ${evgen_status}"
		echo "flink-latencya-nano status: ${fla_status}"
		echo "flink-latencyb-nano status: ${flb_status}"
		echo "driverapp status: ${driverapp_status}"
                if [[ $evgen_status =~ "Running" ]] && [[ $fla_status =~ "Completed" ]] && [[ $flb_status =~ "Completed" ]] && [[ $driverapp_status =~ "Completed" ]]
                then
			echo "INSIDE"
                        is_deployed=1
                fi

                iteration=$((iteration+1))

        done
}

# loop and test correct deployment
wait_correct_deployment

echo "Scenario deployed correctly!"
echo "Starting to generate tests!"

# file to request to the event-generator
evgen_filepath=$(awk '/eventGenerator/{flag=1} flag && /filepath:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1 )
evgen_topic=$(awk '/eventGenerator/{flag=1} flag && /topic:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1 )  # topic to write from the event-generator
evgen_kafka=$(awk '/eventGenerator/{flag=1} flag && /kafka:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1 )
evgen_port=$(awk '/eventGenerator/{flag=1} flag && /port:/{print $NF;flag=""}'  ./deployment/values.yaml | head -1 )
kafka_pod=$(sudo -u $(who am i | awk '{print $1}') kubectl get pods --all-namespaces -o wide | awk 'index($0, "kafka") != 0' | awk '{print $2}')
kafka_pod=pod/$kafka_pod
echo "The kafka pod name is: $kafka_pod"

# Obtain the ip of the event-generator so we can make the request
evgen_ip=$(sudo -u $(who am i | awk '{print $1}') kubectl get pods --all-namespaces -o wide | awk 'index($0, "event-generator") != 0' | awk '{print $7}')

# Create folder for results
echo "Create folder for results"
mkdir ./results_${driver_app_name}

for delay in 0.016 0.025 0.05 0.1 0.2
do
	for iteration in {1..3}
	do
		echo "Executing ITERATION:${iteration} with DELAY:${delay}"
		# Delete and create topics so they are empty of messages
		sudo -u $(who am i | awk '{print $1}') kubectl exec -it $kafka_pod $kube_namespace -- kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic topicStart
		sudo -u $(who am i | awk '{print $1}') kubectl exec -it $kafka_pod $kube_namespace -- kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic topicEnd
		sudo -u $(who am i | awk '{print $1}') kubectl exec -it $kafka_pod $kube_namespace -- kafka-topics.sh --create --bootstrap-server localhost:9092 --topic topicStart
		sudo -u $(who am i | awk '{print $1}') kubectl exec -it $kafka_pod $kube_namespace -- kafka-topics.sh --create --bootstrap-server localhost:9092 --topic topicEnd
		
		# Requesting the event-generator to start generating events
		echo "requesting following url: http://$evgen_ip:$evgen_port/?filepath=$evgen_filepath\&topic=$evgen_topic\&kafkabroker=$evgen_kafka\&delay=$delay"
		
		curl http://$evgen_ip:$evgen_port/?filepath=$evgen_filepath\&topic=$evgen_topic\&kafkabroker=$evgen_kafka\&delay=$delay

		# some drivers like the input-driver are going to be saturated with high rates. In this cases the curl is going to finish before all the events go to topicEnd.
		# This sleep assures that the test is finished before obtaining the result. Something dynamic could be done by checking if events keep arriving in the kafka-console-consumer
		sleep 13m
		
		startfile=results_${driver_app_name}/batch${delay}_${iteration}-start.txt
		endfile=results_${driver_app_name}/batch${delay}_${iteration}-end.txt
		
		# Obtaining information from the topic suppossing the topic has no information
		echo "Obtaining results..."
		timeout --foreground 45s sudo -u $(who am i | awk '{print $1}') kubectl exec -it $kafka_pod $kube_namespace-- kafka-console-consumer.sh --topic topicStart --bootstrap-server localhost:9092 --from-beginning > $startfile
		timeout --foreground 45s sudo -u $(who am i | awk '{print $1}') kubectl exec -it $kafka_pod $kube_namespace-- kafka-console-consumer.sh --topic topicEnd --bootstrap-server localhost:9092 --from-beginning > $endfile
		printf "Results written in: ${startfile} and ${endfile}\n\n"
	done
done
