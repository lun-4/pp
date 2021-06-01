#!/bin/sh

had_any_block_devices=0

validate_block_device() {
    argument_name=$1
    possible_kernel_name=$2
    device_model=$(cat "/sys/block/$possible_kernel_name/device/model" 2>/dev/null)
    if [ $? = "0" ]; then
        had_any_block_devices=1
        echo "Argument '$argument_name' points to $possible_kernel_name: $device_model"
    fi
}

check_argument() {
    argument=$1
    argument_name=$(echo "$argument" | cut -d '=' -f 1)
    possible_disk=$(echo "$argument" | cut -d '=' -f 2)
    possible_kernel_name=$(echo "$possible_disk" | cut -d '/' -f 3)
    validate_block_device "$argument_name" "$possible_kernel_name"
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
    echo -n "\tdo you wish to continue? (say 'yes'): "
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
