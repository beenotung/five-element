module RandomTest exposing (main)

import FormatNumber
import FormatNumber.Locales
import Html exposing (..)
import Html.Attributes exposing (style)
import Random


type alias Model =
    { inc : Int, dec : Int, rest : Int }


init : ( Model, Cmd Msg )
init =
    ( Model 0 0 0, genDelta )


type Msg
    = Delta Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Delta d ->
            let
                m =
                    case d of
                        (-1) ->
                            { model | dec = model.dec + 1 }

                        0 ->
                            { model | rest = model.rest + 1 }

                        1 ->
                            { model | inc = model.inc + 1 }

                        _ ->
                            Debug.crash ("Invalid delta: " ++ (toString d))
            in
                ( m, genDelta )


genDelta : Cmd Msg
genDelta =
    Random.int 1 3
        -- 1 .. 3 => -1 .. 1
        |> Random.map (\x -> x - 2)
        |> Random.generate Delta


subscriptions : a -> Sub msg
subscriptions model =
    Sub.none


table : List (Attribute msg) -> List (Html msg) -> Html msg
table attrs children =
    Html.table (style borderStyle :: attrs) children


th : List (Attribute msg) -> List (Html msg) -> Html msg
th attrs children =
    Html.th (style borderStyle :: attrs) children


td : List (Attribute msg) -> List (Html msg) -> Html msg
td attrs children =
    Html.td (style borderStyle :: attrs) children


borderStyle : List ( String, String )
borderStyle =
    [ ( "border", "black 1px solid" )
    , ( "border-collapse", "collapse" )
    , ( "padding", "4px" )
    ]


view : Model -> Html Msg
view model =
    let
        sum =
            model.inc + model.rest + model.dec
    in
        table
            [ style [ ( "margin", "8px" ) ] ]
            [ thead []
                [ th [] [ text "-1" ]
                , th [] [ text "0" ]
                , th [] [ text "1" ]
                , th [] [ text "sum" ]
                ]
            , tbody []
                [ tr []
                    [ td [] [ model.dec |> toString |> text ]
                    , td [] [ model.rest |> toString |> text ]
                    , td [] [ model.inc |> toString |> text ]
                    , td [] [ model.inc - model.dec |> toString |> text ]
                    ]
                , tr []
                    [ td [] [ viewPercent model.dec sum ]
                    , td [] [ viewPercent model.rest sum ]
                    , td [] [ viewPercent model.inc sum ]
                    ]
                ]
            ]


viewPercent : Int -> Int -> Html msg
viewPercent i sum =
    (toFloat i)
        / (toFloat sum)
        * 100
        |> FormatNumber.format (FormatNumber.Locales.Locale 4 "" "." "-" "")
        |> (\x -> x ++ "%")
        |> text


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
