#!/bin/bash

set +H

NUM_PROCESSES=10

log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local message="$timestamp $*"
    echo "$message" | tee -a ~/battery_control.log
}

stopCharging() {
    log "Stopping charging..."
    sudo smc -k CH0I -w 02
}

beginCharging() {
    log "Starting charging..."
    sudo smc -k CH0I -w 00
}

consumeCPU() {
    log "Consuming CPU with $NUM_PROCESSES processes..."
    for i in $(seq 1 $NUM_PROCESSES); do
        cpu_consume.sh &
        pid_list+=("$!")
    done
    log "Started CPU-consuming processes: ${pid_list[@]}"
    cpu_consuming=true
}

stopConsumeCPU() {
    log "Stopping CPU consumption..."
    for pid in "${pid_list[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" && log "Stopped process $pid"
        fi
    done
    pid_list=()
    cpu_consuming=false
}

consumeGPU() {
    log "Consuming GPU by opening $NUM_PROCESSES Chrome windows..."
    for i in $(seq 1 $NUM_PROCESSES); do
        open -na "Google Chrome" --args --new-window "https://millerzzz.github.io/vsbm.html" &
        gpu_pid_list+=("$!")
    done
    log "Started GPU-consuming Chrome windows: ${gpu_pid_list[@]}"
    gpu_consuming=true
}

stopConsumeGPU() {
    log "Stopping GPU consumption by closing Chrome windows..."
    pkill -f "Google Chrome"
    gpu_pid_list=()
    gpu_consuming=false
}

resetSMC() {
    log "Resetting SMC to default..."
    sudo smc -k CH0I -w 00
}

shutdownAll() {
    log "Shutting down all processes and exiting..."
    stopConsumeCPU
    stopConsumeGPU
    resetSMC
    kill 0
    exit 0
}

checkBattery() {
    battery_status=$(battery status)
    battery_percentage=$(log "$battery_status" | grep -o '[0-9]\+%' | awk -F'%' '{print $1}')
    if [ -z "$battery_percentage" ]; then
        log "Failed to get battery percentage, defaulting to 0."
        battery_percentage=0
    fi
    log "Current battery level: $battery_percentage%"
    if [ "$battery_percentage" -gt 96 ]; then
        if [ "$cpu_consuming" = false ]; then
            consumeCPU
        fi
        if [ "$gpu_consuming" = false ]; then
            consumeGPU
        fi
        stopCharging
        charging=false
    elif [ "$battery_percentage" -lt 4 ]; then
        if [ "$cpu_consuming" = true ]; then
            stopConsumeCPU
        fi
        if [ "$gpu_consuming" = true ]; then
            stopConsumeGPU
        fi
        beginCharging
        charging=true
    fi
}

charging=false
cpu_consuming=false
gpu_consuming=false
pid_list=()
gpu_pid_list=()

monitorBattery() {
    while true; do
        checkBattery
        sleep 60
    done
}

listenForInput() {
    while true; do
        read -r -t 1 input
        if [ "$input" = "s" ]; then
            shutdownAll
        fi
    done
}

log "Starting battery monitoring. Type 's' to shut down all processes and exit."

monitorBattery &
listenForInput
