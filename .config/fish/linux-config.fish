# Put Linux specific setup in here

echo "Configuring fish for Linux"

fish_add_path $HOME/go/bin
fish_add_path /usr/lib/llvm-21/bin

set -gx MESSAGE_DIALOG_COMMAND qmessage
