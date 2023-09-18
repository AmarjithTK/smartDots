function choicerunner() {
    echo -e "Enter your choice:"
    echo -e "1) gitsetup \n2) nvimsetup \n3) vscodesetup \n4) nixsetup \n5) dwmsetup \n6) binsetup \n7) basepackagesetup \n8) packagesetup \n9) zshsetup"
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

    # Iterate over the selected setups
    for setup_number in "${selected_setups[@]}"; do
        case "$setup_number" in
            1)
                source setups/gitsetup
                ;;
            2)
                source setups/nvimsetup
                ;;
            3)
                source setups/vscodesetup
                ;;
            4)
                source setups/nixsetup
                ;;
            5)
                source setups/dwmsetup
                ;;
            6)
                source setups/binsetup
                ;;
            7)
                source setups/basepackagesetup
                ;;
            8)
                source setups/packagesetup
                ;;
            9)
                source setups/zshsetup
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
