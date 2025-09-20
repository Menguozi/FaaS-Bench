#!/bin/bash
#################################################################################
# Run hello-bench for nerdctl with OCI/Stargz/Nydus/overlayBD image.            #
# Platform :Key Laboratory of Information Storage System，Ministry of Education #
# Version  :1.0                                                                 #
# Date     :2024-01-15                                                          #
# Author   :Yang Xiao                                                           #
# Contact  :menguozi@hust.edu.cn                                                #
#################################################################################

#########################################################
# No need to modify
#########################################################
CURRENT_ROUND=1
RESULT_FILE=result.txt
RESULT_CSV=result.csv
NYDUSIFY_BIN=$(which nydusify)
NYDUS_IMAGE_BIN=$(which nydus-image)
CONVERTOR_BIN=/opt/overlaybd/snapshotter/convertor

#########################################################
# Could alert value via arguments
#########################################################
ROUND_NUM=10
RESULT_DIR=data
SOURCE_REGISTRY=docker.m.daocloud.io/library
TARGET_REGISTRY=""
SKIP=false
IMAGES_PATH=hello_bench_image_list.txt

#########################################################
# Pull OCI/Stargz/Nydus/overlayBD image to Local
# Globals:
#   TARGET_REGISTRY
# Arguments:
#   image
# Returns:
#   None
#########################################################
function pull_registry() {
    image=$1
    echo "[INFO] Pulling ${TARGET_REGISTRY}/${image}to ${image}"

    echo "[INFO] nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}"
    sudo nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}
    
    echo "[INFO] nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}:estargz"
    sudo nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}:estargz
    
    echo "[INFO] nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}:nydusv6"
    sudo nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}:nydusv6
    
    echo "[INFO] nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}:latest_obd"
    sudo nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}:latest_obd
}

#########################################################
# Push OCI image to TARGET_REGISTRY
# Globals:
#   TARGET_REGISTRY
# Arguments:
#   image
# Returns:
#   None
#########################################################
function push_registry() {
    image=$1
    echo "[INFO] Pushing ${image} to ${TARGET_REGISTRY}/${image}"

    echo "[INFO] nerdctl --insecure-registry pull ${SOURCE_REGISTRY}/${image}"
    sudo nerdctl --insecure-registry pull ${SOURCE_REGISTRY}/${image}

    # echo "[INFO] nerdctl pull ${SOURCE_REGISTRY}/${image}"
    # sudo nerdctl pull ${SOURCE_REGISTRY}/${image}

    echo "[INFO] nerdctl --insecure-registry tag ${SOURCE_REGISTRY}/${image} ${TARGET_REGISTRY}/${image}"
    sudo nerdctl --insecure-registry tag ${SOURCE_REGISTRY}/${image} ${TARGET_REGISTRY}/${image}
    
    echo "[INFO] nerdctl --insecure-registry push ${TARGET_REGISTRY}/${image}"
    sudo nerdctl --insecure-registry push ${TARGET_REGISTRY}/${image}
    
    echo "[INFO] nerdctl --insecure-registry rmi -f ${TARGET_REGISTRY}/${image}"
    sudo nerdctl --insecure-registry rmi -f ${TARGET_REGISTRY}/${image}
    
    # echo "[INFO] nerdctl --insecure-registry rmi -f ${SOURCE_REGISTRY}/${image}"
    # sudo nerdctl --insecure-registry rmi -f ${SOURCE_REGISTRY}/${image}
}

#########################################################
# Convert OCI image to nydus/stargz/overlaybd image and 
# push to TARGET_REGISTRY
# Globals:
#   TARGET_REGISTRY
# Arguments:
#   image
# Returns:
#   None
#########################################################
function convert() {
    check_binary

    image=$1

    # echo "[INFO] Converting ${TARGET_REGISTRY}/${image} to ${TARGET_REGISTRY}/${image}:estargz ..."
    # sudo nerdctl pull --insecure-registry ${TARGET_REGISTRY}/${image}
    # echo "sudo nerdctl --insecure-registry image convert \
    #     --estargz \
    #     --oci \
    #     ${TARGET_REGISTRY}/${image} \
    #     ${TARGET_REGISTRY}/${image}:estargz"
    # sudo nerdctl --insecure-registry image convert \
    #     --estargz \
    #     --oci \
    #     ${TARGET_REGISTRY}/${image} \
    #     ${TARGET_REGISTRY}/${image}:estargz
    # echo "[INFO] Pushing ${TARGET_REGISTRY}/${image}:estargz ..."
    # echo "sudo nerdctl --insecure-registry push ${TARGET_REGISTRY}/${image}:estargz"
    # sudo nerdctl --insecure-registry push ${TARGET_REGISTRY}/${image}:estargz

    # echo "[INFO] Converting ${TARGET_REGISTRY}/${image} to ${TARGET_REGISTRY}/${image}:nydusv6 ..."
    # echo "sudo $NYDUSIFY_BIN convert \
    #     --fs-version 6 \
    #     --compressor zstd \
    #     --chunk-size 0x10000 \
    #     --nydus-image $NYDUS_IMAGE_BIN \
    #     --source-insecure \
    #     --target-insecure \
    #     --source ${TARGET_REGISTRY}/${image} \
    #     --target ${TARGET_REGISTRY}/${image}:nydusv6 \
    #     --fs-align-chunk true"
    # sudo $NYDUSIFY_BIN convert \
    #     --fs-version 6 \
    #     --compressor zstd \
    #     --chunk-size 0x10000 \
    #     --nydus-image $NYDUS_IMAGE_BIN \
    #     --source-insecure \
    #     --target-insecure \
    #     --source ${TARGET_REGISTRY}/${image} \
    #     --target ${TARGET_REGISTRY}/${image}:nydusv6 \
    #     --fs-align-chunk true

    # echo "[INFO] Converting ${TARGET_REGISTRY}/${image} to ${TARGET_REGISTRY}/${image}:latest_obd ..."
    # echo "sudo $CONVERTOR_BIN \
    #     --plain \
    #     --insecure \
    #     -r ${TARGET_REGISTRY}/${image} \
    #     -i latest \
    #     -o latest_obd"
    # sudo $CONVERTOR_BIN \
    #     --plain \
    #     --insecure \
    #     -r ${TARGET_REGISTRY}/${image} \
    #     -i latest \
    #     -o latest_obd
}

#########################################################
# Stop all running containers
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#########################################################
function stop_all_containers {
    containers=$(sudo nerdctl ps -q | tr '\n' ' ')
    if [[ ${containers} == "" ]]; then
        return 0
    else
        echo "Killing containers ${containers}"
        for C in ${containers}; do
            sudo nerdctl kill "${C}"
            sudo nerdctl stop "${C}"
            sudo nerdctl rm "${C}"
        done
        return 1
    fi
}

#########################################################
# Run hello bench for OCI image, nydus image, overlaybd image
# Globals:
#   TARGET_REGISTRY
# Arguments:
#   image
# Returns:
#   None
#########################################################
function run() {
    image=$1

    stop_all_containers
    sudo nerdctl ps -a | awk 'NR>1 {print $1}' | xargs sudo nerdctl rm >/dev/null 2>&1
    sudo nerdctl container prune -f
    sync; echo 3 > /proc/sys/vm/drop_caches
    sudo nerdctl image prune -f --all

    for c in `ctr c ls -q`; do nerdctl container stop $c; nerdctl container rm $c; done
    for c in `ctr content ls -q`; do ctr content rm $c; done
    for c in `ctr i ls -q`; do ctr i rm $c; done
    
    sudo systemctl stop stargz-snapshotter
    sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/fscache/*
    sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/httpcache/*
    sudo systemctl start stargz-snapshotter
    
    sudo systemctl stop overlaybd-snapshotter
    sudo systemctl stop overlaybd-tcmu
    sudo rm -rf /opt/overlaybd/registry_cache/*
    sudo rm -rf /opt/overlaybd/gzip_cache/*
    sudo systemctl start overlaybd-tcmu
    sudo systemctl start overlaybd-snapshotter

    sleep 1

    # echo "[INFO] Run hello bench in ${image} ..."
    # sudo nerdctl --insecure-registry --snapshotter overlayfs rmi -f ${TARGET_REGISTRY}/${image} >/dev/null 2>&1
    # result=$(sudo ./hello.py --engine nerdctl --insecure-registry --snapshotter overlayfs --op run \
    #     --registry=${TARGET_REGISTRY} \
    #     --images ${image} |
    #     grep "repo")
    # echo ${result}
    # echo ${result} >>${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}
    # nerdctl images
    # nerdctl ps -a
    # sync; echo 3 > /proc/sys/vm/drop_caches
    # echo "[INFO] Remove image ${TARGET_REGISTRY}/${image} ..."
    # sudo nerdctl --insecure-registry --snapshotter overlayfs rmi -f ${TARGET_REGISTRY}/${image} >/dev/null 2>&1
    
    echo "[INFO] Run hello bench in ${image}:estargz ..."
    sudo nerdctl --insecure-registry --snapshotter stargz rmi -f ${TARGET_REGISTRY}/${image}:estargz >/dev/null 2>&1
    result=$(sudo ./hello.py --engine nerdctl --insecure-registry --snapshotter stargz --op run \
        --registry=${TARGET_REGISTRY} \
        --images ${image}:estargz |
        grep "repo")
    echo ${result}
    echo ${result} >>${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}
    nerdctl images
    nerdctl ps -a
    sync; echo 3 > /proc/sys/vm/drop_caches
    echo "[INFO] Remove image ${TARGET_REGISTRY}/${image}:estargz ..."
    sudo nerdctl --insecure-registry --snapshotter stargz rmi -f ${TARGET_REGISTRY}/${image}:estargz >/dev/null 2>&1

    # echo "[INFO] Run hello bench in ${image}:nydusv6 ..."
    # sudo nerdctl --insecure-registry --snapshotter nydus rmi -f ${TARGET_REGISTRY}/${image}:nydusv6 >/dev/null 2>&1
    # result=$(sudo ./hello.py --engine nerdctl --insecure-registry --snapshotter nydus --op run \
    #     --registry=${TARGET_REGISTRY} \
    #     --images ${image}:nydusv6 |
    #     grep "repo")
    # echo ${result}
    # echo ${result} >>${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}
    # nerdctl images
    # nerdctl ps -a
    # sync; echo 3 > /proc/sys/vm/drop_caches
    # echo "[INFO] Remove image ${TARGET_REGISTRY}/${image}:nydusv6 ..."
    # sudo nerdctl --insecure-registry --snapshotter nydus rmi -f ${TARGET_REGISTRY}/${image}:nydusv6 >/dev/null 2>&1

    # echo "[INFO] Run hello bench in ${image}:latest_obd ..."
    # sudo nerdctl --insecure-registry --snapshotter overlaybd rmi -f ${TARGET_REGISTRY}/${image}:latest_obd >/dev/null 2>&1
    # result=$(sudo ./hello.py --engine nerdctl --insecure-registry --snapshotter overlaybd --op run \
    #     --registry=${TARGET_REGISTRY} \
    #     --images ${image}:latest_obd |
    #     grep "repo")
    # echo ${result}
    # echo ${result} >>${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}
    # nerdctl images
    # nerdctl ps -a
    # sync; echo 3 > /proc/sys/vm/drop_caches
    # echo "[INFO] Remove image ${TARGET_REGISTRY}/${image}:latest_obd ..."
    # sudo nerdctl --insecure-registry --snapshotter overlaybd rmi -f ${TARGET_REGISTRY}/${image}:latest_obd >/dev/null 2>&1
}

#########################################################
# Handle data in $RESULT_DIR to csv and png
# Globals:
#   RESULT_DIR
# Arguments:
#   None
# Returns:
#   None
#########################################################
function handle_data() {
    python3_path=$(which python3)
    if [ "$(which python3)" == "" ]; then
        echo "[ERROR] Can not found python3"
        exit
    fi
    if [ ! -d ${RESULT_DIR} ]; then
        echo "[ERROR] Directory ${RESULT_DIR} not exist"
        exit
    fi
    ${python3_path} draw.py -d ${RESULT_DIR} -r result
}

#########################################################
# Check required options for this script
# Globals:
#   TARGET_REGISTRY
#   SOURCE_REGISTRY
# Arguments:
#   None
# Returns:
#   None
#########################################################
function check_opts() {
    if [ "${TARGET_REGISTRY}" == "" ]; then
        echo "[ERROR] TARGET_REGISTRY is null"
        exit
    fi
    if [ "${SOURCE_REGISTRY}" == "" ]; then
        echo "[ERROR] SOURCE_REGISTRY is null"
        exit
    fi
}

#########################################################
# Check required binary for this script
# Globals:
#   NYDUSIFY_BIN
#   NYDUS_IMAGE_BIN
#   CONVERTOR
# Arguments:
#   None
# Returns:
#   None
#########################################################
function check_binary() {
    if [ "${NYDUSIFY_BIN}" == "" ]; then
        echo "[ERROR] nydusify is not found in \$PATH"
        exit
    fi
    if [ "${NYDUS_IMAGE_BIN}" == "" ]; then
        echo "[ERROR] nydus-image is not found in \$PATH"
        exit
    fi
    
    if [ "${CONVERTOR_BIN}" == "" ]; then
        echo "[ERROR] convertor is not found in \$PATH"
        exit
    fi
}

#########################################################
# Usage information
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#########################################################
function usage() {
    echo "Usage:"
    echo -e "run.sh -o OPERATION -s SOURCE_REGISTRY -t TARGET_REGISTRY [other options]
[-o operation]          \tavailable options are [ pull push convert run all draw ]
[-i images]             \timages list
[-p images path]        \tfile path that contains images list (line by line)
[-s source registry]    \tsource registry for pulling image
[-t target registry]    \target registry for pushing image
[-r round number]       \tnumber of round to run hellobench
[-d result directory]   \tdirectory to store raw result data
[-k skip finished test] \tskip images that already finisned (in \$RESULT_DIR/\$RESULT_FILE)"
    exit -1
}

function getopts_extra() {
    declare i=1
    while [[ ${OPTIND} -le $# && ${!OPTIND:0:1} != '-' ]]; do
        OPTARG[i]=${!OPTIND}
        let i++ OPTIND++
    done
}

available_operation="pull push convert run all draw"

if [ $# -eq 0 ]; then
    usage
fi

while getopts o:i:p:s:t:r:d:kh OPT; do
    case $OPT in
    o)
        operation=${OPTARG}
        if ! [[ "$available_operation" =~ "$operation" ]]; then
            echo "operation ${operation} not support now"
            exit
        fi

        ;;
    i)
        getopts_extra "$@"
        images=("${OPTARG[@]}")
        ;;
    p)
        IMAGES_PATH=${OPTARG}
        ;;
    s)
        SOURCE_REGISTRY=${OPTARG}
        ;;
    t)
        TARGET_REGISTRY=${OPTARG}
        ;;
    r)
        ROUND_NUM=${OPTARG}
        ;;
    d)
        RESULT_DIR=${OPTARG}
        ;;
    k)
        SKIP=true
        ;;
    *)
        usage
        ;;
    esac
done
shift $((OPTIND - 1))

if [ ${#images[@]} -gt 0 ]; then
    IMAGES=()
    for image in "${images[@]}"; do
        IMAGES+=($image)
    done
else
    IMAGES=($(cat ${IMAGES_PATH} | tr "\n" " "))
fi

images_length=${#IMAGES[@]}
echo "images:"
for IMAGE in "${IMAGES[@]}"; do
    echo "- ${IMAGE}"
done

if [ ${images_length} -eq 0 ] && [ "$IMAGES_PATH" == "" ]; then
    echo "both images list and file path are null"
    exit
fi

case $operation in
pull)
    check_opts
    for image in "${IMAGES[@]}"; do
        pull_registry ${image}
    done
    ;;
push)
    # check_opts
    for image in "${IMAGES[@]}"; do
        push_registry ${image}
    done
    ;;
convert)
    check_opts
    for image in "${IMAGES[@]}"; do
        convert ${image}
    done
    ;;
run)
    check_opts
    if [ ! "${SKIP}" == "true" ]; then
        if [ -d ${RESULT_DIR} ]; then
            rm -rf ${RESULT_DIR}
        fi
        mkdir ${RESULT_DIR}
    fi
    for i in $(seq 1 ${ROUND_NUM}); do
        CURRENT_ROUND=${i}
        echo $CURRENT_ROUND
        if [ ! "${SKIP}" == "true" ]; then
            echo "" >${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}
        fi

        for image in "${IMAGES[@]}"; do
            if [ "${SKIP}" == "true" ]; then
                skip=false
                for i in $(cat ${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}); do
                    if [[ "${i}" =~ "${image}" ]]; then
                        echo "Skip image ${image}."
                        skip=true
                        break
                    fi
                done
                if [ "${skip}" == "true" ]; then
                    continue
                fi
            fi
            run ${image}
        done
    done
    ;;
all)
    check_opts
    if [ ! "${SKIP}" == "true" ]; then
        if [ -d ${RESULT_DIR} ]; then
            rm -rf ${RESULT_DIR}
        fi
        mkdir ${RESULT_DIR}
    fi
    for i in $(seq 1 ${ROUND_NUM}); do
        CURRENT_ROUND=${i}
        echo $CURRENT_ROUND
        if [ ! "${SKIP}" == "true" ]; then
            echo "" >${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}
        fi

        for image in "${IMAGES[@]}"; do
            if [ "${SKIP}" == "true" ]; then
                skip=false
                for i in $(cat ${RESULT_DIR}/${RESULT_FILE}.${CURRENT_ROUND}); do
                    if [[ "${i}" =~ "${image}" ]]; then
                        echo "Skip image ${image}."
                        skip=true
                        break
                    fi
                done
                if [ "${skip}" == "true" ]; then
                    continue
                fi
            fi
            if [ ${CURRENT_ROUND} -eq 1 ]; then
                pull_registry ${image}
                push_registry ${image}
                convert ${image}
            fi
            run ${image}
        done
    done

    handle_data
    ;;
draw)
    handle_data
    ;;
*)
    echo "get invalid operation: ${operation}"
    usage
    exit
    ;;
esac
