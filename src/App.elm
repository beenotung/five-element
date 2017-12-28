module Main exposing (main)

import Html
import Html.Attributes
import Svg exposing (svg)
import Svg.Attributes exposing (..)


type alias Model =
    List Element


type alias Element =
    { elementType : ElementType
    , amount : Float
    , cx : Float
    , cy : Float
    , r : Float
    }


positions :
    { bottom : Float
    , center : Float
    , left : Float
    , padding : Float
    , r : Float
    , right : Float
    , size : Float
    , top : Float
    }
positions =
    let
        padding =
            4

        size =
            320

        r =
            60

        right =
            r + padding

        left =
            size - r - padding

        top =
            r + padding

        bottom =
            size - r - padding

        center =
            (left + right) / 2
    in
        { padding = padding
        , size = size
        , r = r
        , right = right
        , left = left
        , top = top
        , bottom = bottom
        , center = center
        }


initModel : List Element
initModel =
    let
        p =
            positions
    in
        [ Element Fire 100 p.right p.top p.r
        , Element Wood 100 p.right p.bottom p.r
        , Element Gold 100 p.left p.top p.r
        , Element Water 100 p.left p.bottom p.r
        , Element Soil 100 p.center p.center p.r
        ]


init : ( Model, Cmd msg )
init =
    initModel ! []


view : Model -> Html.Html msg
view model =
    Html.div
        [ Html.Attributes.style [ ( "margin", "8px" ) ] ]
        [ Html.h1 [] [ Html.text "Five Elements" ]
        , viewMain model
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
    , ( Gold, "white" )
    , ( Wood, "greenyellow" )
    , ( Water, "black" )
    , ( Soil, "yellow" )
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


viewMain : Model -> Html.Html msg
viewMain model =
    let
        p =
            positions

        sizeStr =
            toString p.size
    in
        svg
            [ version "1.1"
            , x "0"
            , y "0"
            , viewBox ("0 0 " ++ sizeStr ++ " " ++ sizeStr)
            , Html.Attributes.style
                [ ( "background", "tan" )
                , ( "padding", (toString p.padding) ++ "px" )
                ]
            ]
            (List.map viewElement model)


viewElement : Element -> Html.Html msg
viewElement element =
    let
        color =
            elementColor element.elementType
    in
        Svg.circle [ Svg.Attributes.cx (toString element.cx), Svg.Attributes.cy (toString element.cy), Svg.Attributes.r (toString element.r), fill color ] []


update : a -> Model -> ( Model, Cmd msg )
update msg model =
    model ! []


subscriptions : a -> Sub msg
subscriptions model =
    Sub.none


main : Program Never Model msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
