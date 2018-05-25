#!/bin/bash
# Tool to convert bitcoin privkeys into WIF keys
# by sudofox
# see post: https://www.reddit.com/r/litecoin/comments/6vc8tc/how_do_i_convert_a_raw_private_key_to_wif_for/

declare -a base58=(
      1 2 3 4 5 6 7 8 9
    A B C D E F G H I J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h i j k   m n o p q r s t u v w x y z
)

convertToBase58() {
    echo -n "$1" | sed -e's/^\(\(00\)*\).*/\1/' -e's/00/1/g' | tr -d '\n'
    dc -e "16i ${1^^} [3A ~r d0<x]dsxx +f" |
    while read -r n; do echo -n "${base58[n]}"; done
}

# start

# key is $1

KEY=$1 # first arg

# add 0x80 to beginning
EXTENDEDKEY=$(echo 80$KEY)
FIRSTHASH=$(echo -n "$EXTENDEDKEY" |xxd -r -p |gsha256sum -b|awk '{print $1}')
SECONDHASH=$(echo -n "$FIRSTHASH" |xxd -r -p |gsha256sum -b|awk '{print $1}')
CHECKSUM=$(echo $SECONDHASH|cut -c1-8)
FINAL=$(echo $EXTENDEDKEY$CHECKSUM)
FINAL=$(convertToBase58 $FINAL)
echo $FINAL