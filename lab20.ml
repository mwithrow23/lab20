open Image ;;

let mona = create 250 360 Monalisa.image in
    depict mona;
    depict (threshold 0.75 mona);
    depict (dither mona);
    depict (error_diffuse mona) ;;
