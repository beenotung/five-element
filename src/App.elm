module Main exposing (main)

import Html


init : ( number, Cmd msg )
init =
    1 ! []


view : a -> Html.Html msg
view model =
    Html.text "todo"


update : a -> b -> ( b, Cmd msg )
update msg model =
    model ! []


subscriptions : a -> Sub msg
subscriptions model =
    Sub.none


main : Program Never number msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }





