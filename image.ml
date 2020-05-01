module G = Graphics ;;
let cMAXRGB = 255 ;;

type pixel = float ;;

type size = int * int ;;

type image = { size : size;
               content : float list list } ;;

let rgb_of_gray (value : pixel) : G.color =
  if value > 1. || value < 0. then
    failwith "rgb_of_gray: value outside of range"
  else
    let level = int_of_float (float_of_int cMAXRGB *. (1. -. value)) in
    G.rgb level level level ;;

let create (col_size : int) (row_size : int)
    (contents : float list list)
  : image =
  {size = col_size, row_size;
   content = contents} ;;

let depict ({size = col_size, row_size; content} : image) : unit =
  try
    G.open_graph "";
    G.clear_graph ();
    G.resize_window col_size row_size;

    content
    |> List.iteri
      (fun row_index row ->
         row
         |> List.iteri
           (fun col_index pixel ->
              G.set_color (rgb_of_gray pixel);
              G.plot col_index (row_size - row_index - 1)));
    Unix.sleep 2

  with
    exn -> (G.close_graph (); raise exn) ;;

let filter (f : pixel -> pixel)
    ({content; _} as img : image)
  : image =
  {img with content = List.map (List.map f) content} ;;

let invert : image -> image =
  filter (fun p -> (1. -. p)) ;;

let threshold (threshold : float) : image -> image =
  filter
    (fun p -> if threshold < p then 1. else 0.) ;;

let dither : image -> image =
  filter
    (fun p -> if Random.float 1. < p then 1. else 0.) ;;

let error_diffuse : image -> image =
  filter
    (let error = ref 0. in
     fun p -> if 0.5 < p +. !error then
         (error := !error -. (1. -. p);
          1.)
       else
         (error := !error -. (0. -. p);
          0.)) ;;
