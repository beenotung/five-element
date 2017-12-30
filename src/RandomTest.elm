module RandomTest exposing (main)

import Html
import Random


init =
    ( 0, genDelta )


type Msg
    = Delta Int


update msg model =
    case msg of
        Delta d ->
            ( model + d, genDelta )


genDelta =
    Random.int 1 3
        -- 1 .. 3 => -1 .. 1
        |> Random.map (\x -> x - 2)
        |> Random.generate Delta


subscriptions model =
    Sub.none


view model =
    Html.text (toString model)


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
