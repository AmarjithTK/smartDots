function choicerunner() {
    echo -e "Enter your choice:"
    echo -e "1) gitsetup \n2) nvimsetup \n3) vscodesetup \n4) nixsetup \n5) dwmsetup \n6) binsetup \n7) basepackagesetup \n8) packagesetup \n9) zshsetup \n10)cronsetup \n 11) themesetup"
    echo -e "Enter 'q' to quit"
    read CHOICE
    if [[ $CHOICE == 'q' ]]; then
        echo "Exiting ..."
        exit 1
    fi

    # Create an array to store the selected setup numbers
    selected_setups=()

    # Check if the user wants to do multiple setups
    echo -e "Do you want to perform multiple setups? (y/n)"
    read MULTIPLE_CHOICE

    if [[ $MULTIPLE_CHOICE == 'y' ]]; then
        echo -e "Enter the numbers of the setups you want to perform (separated by whitespace):"
        read -a selected_setups
    else
        selected_setups=("$CHOICE")
    fi

    # Get the absolute path of the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Iterate over the selected setups
    for setup_number in "${selected_setups[@]}"; do
        case "$setup_number" in
            1)
                source "$SCRIPT_DIR/setups/gitsetup"
                ;;
            2)
                source "$SCRIPT_DIR/setups/nvimsetup"
                ;;
            3)
                source "$SCRIPT_DIR/setups/vscodesetup"
                ;;
            4)
                source "$SCRIPT_DIR/setups/nixsetup"
                ;;
            5)
                source "$SCRIPT_DIR/setups/dwmsetup"
                ;;
            6)
                source "$SCRIPT_DIR/setups/binsetup"
                ;;
            7)
                source "$SCRIPT_DIR/setups/basepkgsetup"
                ;;
            8)
                source "$SCRIPT_DIR/setups/packagesetup"
                ;;
            9)
                source "$SCRIPT_DIR/setups/zshsetup"
                ;;
            10)
                source "$SCRIPT_DIR/setups/cronsetup"
                ;;
            11)
                source "$SCRIPT_DIR/setups/themesetup"
                ;;                
            *)
                echo "Invalid choice: $setup_number"
                ;;
        esac
    done
}

while true; do
    choicerunner
done
