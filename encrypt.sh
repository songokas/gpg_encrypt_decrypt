#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GREY='\033[0;37m'
RED='\033[0;31m'
NC='\033[0m'
SKIP=""

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -r|--recipient)
    RECIPIENT="$2"
    shift
    ;;
    -s|--skip-existing)
    SKIP="skip$2"
    shift
    ;;
    -e|--encrypt-path)
    ENCRYPT_PATH=$(readlink -f "$2")
    shift
    ;;
    -o|--output)
    OUTPUT_PATH=$(readlink -f "$2")
    shift
    ;;
    *)
    ;;
esac
shift
done

print_usage() {
    echo "All contents of --encrypt-path directory will be encrypted to --output directory"
    echo "Usage: ./encrypt.sh --recipient|-r Recipient Id --encrypt-path|-e ~/not_encrypted --output|-o ~/tmp [--skip-existing|-s true]"
    exit 1
}

encrypt_folder_recurse() {
    for i in "$1"/*;do
        file="$2${i:${#3}}"
        if [ -d "$i" ];then
            echo -e "${GREEN}Creating directory: ${YELLOW}$file${NC}"
            mkdir "$file"
            encrypt_folder_recurse "$i" "$2" "$3" "$4" "$5"
        elif [ -f "$i" ]; then
            if [[ "$4" && -f "$file" ]]; then
                echo -e "${YELLOW}Skipping ${GREY}$i ${YELLOW}since it exists ${GREY}$file${NC}"
            else
                echo -e "${GREEN}Encrypting file ${YELLOW}$i ${GREEN}to ${YELLOW}$file${NC}"
                gpg --recipient "$5" --sign --output "$file" --encrypt "$i"
            fi
        fi
    done
}

if [[ -d "$ENCRYPT_PATH" && -d "$OUTPUT_PATH" && "$RECIPIENT" ]]; then
    if [[ "$OUTPUT_PATH" == *"$ENCRYPT_PATH"* ]]; then
        echo -e "${RED}Output path ${YELLOW}$OUTPUT_PATH ${RED}can not be in or equal to encrypt path ${YELLOW}$ENCRYPT_PATH{NC}"
        print_usage
    fi
    echo -e "${GREEN}Encrypting path ${YELLOW}$ENCRYPT_PATH ${GREEN}to ${YELLOW}$OUTPUT_PATH ${GREEN}using recipient ${YELLOW}$RECIPIENT${NC}"
else
    if [[ ! -d "$ENCRYPT_PATH" ]];then
        echo -e "${RED}Encrypt path ${YELLOW}$ENCRYPT_PATH ${RED}does not exist${NC}"
    fi
    if [[ ! -d "$OUTPUT_PATH" ]];then
        echo -e "${RED}Output path ${YELLOW}$OUTPUT_PATH ${RED}does not exist${NC}"
    fi
    if [[ ! "$RECIPIENT" ]];then
        echo -e "${RED}Recipient not provided${NC}"
    fi
    print_usage
fi

encrypt_folder_recurse "$ENCRYPT_PATH" "$OUTPUT_PATH" "$ENCRYPT_PATH" "$SKIP" "$RECIPIENT"!
