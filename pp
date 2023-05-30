#!/bin/sh

if [ "$DEBUG" = "1" ]; then set -x; fi
set -eu
had_any_block_devices=0

validate_block_device() {
    argument_name=$1
    possible_disk=$2
    possible_kernel_name=$3
    set +e
    device_model=$(cat "/sys/block/$possible_kernel_name/device/model" 2>/dev/null)
    if [ $? = "0" ]; then
        had_any_block_devices=1
        echo "Argument '$argument_name' points to $possible_kernel_name: $device_model"
    fi

    grep "$possible_disk" /proc/mounts | awk '
        {
            printf("\tArgument %s is mounted to %s (type %s)\n", $1, $2, $3);
        }
    '
    set -e
}

check_argument() {
    argument=$1
    argument_name=$(echo "$argument" | cut -d '=' -f 1)
    possible_disk=$(echo "$argument" | cut -d '=' -f 2 | xargs realpath)
    possible_kernel_name=$(basename "$possible_disk")
    validate_block_device "$argument_name" "$possible_disk" "$possible_kernel_name"
}

for arg in "$@"
do
    case "$arg" in
        "if="*) check_argument "$arg" ;;
        "of="*) check_argument "$arg" ;;
        *) ;;
    esac
done

if [ "$had_any_block_devices" = "1" ]; then
    echo "At least one block device was found in this invocation."
    printf "\tdo you wish to continue? (answer 'yes' if so): "
    read -r inp
    if [ ! "$inp" = "yes" ]; then
        echo "Operation not confirmed. Aborting."
        exit 1
    else
        echo "Operation confirmed, running dd."
        dd "$@"
    fi
else
    dd "$@"
fi
