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
    -s|--skip-existing)
    SKIP="skip$2"
    shift
    ;;
    -d|--decrypt-path)
    DECRYPT_PATH=$(readlink -f "$2")
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
    echo "All contents of --decrypt-path directory will be decrypted to --output directory"
    echo "Usage: ./decrypt.sh --decrypt-path|-d ~/encrypted --output|-o ~/tmp [--skip-existing|-s true]"
    exit 1
}

decrypt_folder_recurse() {
    for i in "$1"/*;do
        file="$2${i:${#3}}"
        if [ -d "$i" ];then
            echo -e "${GREEN}Creating directory: ${YELLOW}$file${NC}"
            mkdir "$file"
            decrypt_folder_recurse "$i" "$2" "$3" "$4"
        elif [ -f "$i" ]; then
            if [[ "$4" && -f "$file" ]]; then
                echo -e "${YELLOW}Skipping ${GREY}$i ${YELLOW}since it exists ${GREY}$file${NC}"
            else
                echo -e "${GREEN}Decrypting file ${YELLOW}$i ${GREEN}to ${YELLOW}$file${NC}"
                gpg --output "$file" --decrypt "$i"
            fi
        fi
    done
}

if [[ -d "$DECRYPT_PATH" && -d "$OUTPUT_PATH" ]]; then
    if [[ "$OUTPUT_PATH" == *"$DECRYPT_PATH"* ]]; then
        echo -e "${RED}Output path ${YELLOW}$OUTPUT_PATH ${RED}can not be in or equal to decrypt path ${YELLOW}$DECRYPT_PATH${NC}"
        print_usage
    fi
    echo -e "${GREEN}Decrypting path ${YELLOW}$DECRYPT_PATH ${GREEN}to ${YELLOW}$OUTPUT_PATH${NC}"
else
    if [[ ! -d "$DECRYPT_PATH" ]];then
        echo -e "${RED}Decrypt path ${YELLOW}$DECRYPT_PATH ${RED}does not exist${NC}"
    fi
    if [[ ! -d "$OUTPUT_PATH" ]];then
        echo -e "${RED}Output path ${YELLOW}$OUTPUT_PATH ${RED}does not exist${NC}"
    fi
    print_usage
fi

decrypt_folder_recurse "$DECRYPT_PATH" "$OUTPUT_PATH" "$DECRYPT_PATH" "$SKIP"
