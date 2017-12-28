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


elementColor : ElementType -> String
elementColor element =
    List.filterMap
        (\x ->
            let
                ( e, c ) =
                    x
            in
                if e == element then
                    Just c
                else
                    Nothing
        )
        colors
        |> List.head
        |> \x ->
            case x of
                Nothing ->
                    Debug.crash "Invalid ElementType"

                Just x ->
                    x


viewMain : Html.Html msg
viewMain =
    let
        size =
            320

        r =
            60

        right =
            r

        left =
            size - r

        top =
            r

        bottom =
            size - r

        center =
            (left + right) / 2

        sizeStr =
            toString size
    in
        svg
            [ version "1.1", x "0", y "0", viewBox ("0 0 " ++ sizeStr ++ " " ++ sizeStr) ]
            [ viewElement Fire right top r
            , viewElement Gold right bottom r
            , viewElement Wood left top r
            , viewElement Water left bottom r
            , viewElement Soil center center r
            ]


viewElement : ElementType -> number -> number -> number -> Svg.Svg msg
viewElement element cx cy r =
    let
        color =
            elementColor element
    in
        Svg.circle [ Svg.Attributes.cx (toString cx), Svg.Attributes.cy (toString cy), Svg.Attributes.r (toString r), fill color ] []


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
