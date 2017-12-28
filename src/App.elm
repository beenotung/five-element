module Main exposing (main)

import Html
import Html.Attributes
import Svg exposing (svg)
import Svg.Attributes exposing (..)


init : ( number, Cmd msg )
init =
    1 ! []


view : a -> Html.Html msg
view model =
    Html.div
        [ Html.Attributes.style [ ( "margin", "8px" ) ] ]
        [ Html.h1 [] [ Html.text "Five Elements" ]
        , viewMain
        ]


type ElementType
    = Fire
    | Gold
    | Wood
    | Water
    | Soil


colors : List ( ElementType, String )
colors =
    [ ( Fire, "red" )
    , ( Gold, "gold" )
    , ( Wood, "burlywood" )
    , ( Water, "darkturquoise" )
    , ( Soil, "sienna" )
    ]


viewMain : Html.Html msg
viewMain =
    let
        size =
            320

        r =
            60

        sizeStr =
            toString size
    in
        svg
            [ version "1.1", x "0", y "0", viewBox ("0 0 " ++ sizeStr ++ " " ++ sizeStr) ]
            [ viewElement "red" "60" "60" r
            , viewElement "gold" "100" "100" r
            , viewElement "burlywood" "200" "200" r
            , viewElement "burlywood" "200" "200" r
            , viewElement "burlywood" "200" "200" r
            ]


viewElement : String -> String -> String -> a -> Svg.Svg msg
viewElement color cx cy r =
    Svg.circle [ Svg.Attributes.cx cx, Svg.Attributes.cy cy, Svg.Attributes.r (toString r), fill color ] []


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
