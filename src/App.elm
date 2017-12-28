module Main exposing (main)

import Html
import Html.Attributes
import Random
import Svg exposing (svg)
import Svg.Attributes exposing (..)
import Time exposing (Time)


type alias Model =
    List Element


type alias Element =
    { elementType : ElementType
    , amount : Float
    , cx : Float
    , cy : Float
    , r : Float
    }


type ElementType
    = Fire
    | Gold
    | Wood
    | Water
    | Soil


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


view : Model -> Html.Html Msg
view model =
    Html.div
        [ Html.Attributes.style [ ( "margin", "8px" ) ] ]
        [ Html.h1 [] [ Html.text "Five Elements" ]
        , viewMain model
        ]


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


colors : List ( ElementType, String )
colors =
    [ ( Fire, "red" )
    , ( Gold, "white" )
    , ( Wood, "greenyellow" )
    , ( Water, "black" )
    , ( Soil, "yellow" )
    ]


textColor : String -> String
textColor backgroundColor =
    case backgroundColor of
        "black" ->
            "white"

        _ ->
            "black"


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


viewMain : Model -> Html.Html Msg
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


viewElement : Element -> Html.Html Msg
viewElement element =
    let
        color =
            elementColor element.elementType

        fontSize =
            element.r * 35 / 60
    in
        Svg.g [ Svg.Attributes.transform ("translate(" ++ (toString element.cx) ++ "," ++ (toString element.cy) ++ ")") ]
            [ Svg.circle
                [ Svg.Attributes.r (toString element.r)
                , fill color
                ]
                []
            , Svg.text_
                [ x (toString (-element.r / 2))
                , y (toString ((element.r - fontSize) / 2))
                , fontFamily "Verdana"
                , Svg.Attributes.fontSize (toString fontSize)
                , fill (textColor color)
                ]
                [ Html.text (toString element.amount) ]
            ]


type Msg
    = Tick Time
    | Action ( ActionType, ElementType )


type ActionType
    = Attack
    | Recover
    | Rest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            ( model, generateAction )

        Action ( actionType, elementType ) ->
            let
                r =
                    Debug.log "update action" ( actionType, elementType )

                m =
                    List.map (\x -> updateElement actionType elementType model x) model
            in
                ( m, Cmd.none )


generateAction : Cmd Msg
generateAction =
    let
        gen =
            Random.pair generateActionType generateElementType
    in
        Random.generate Action gen


generateActionType : Random.Generator ActionType
generateActionType =
    Random.int 1 3
        |> Random.map
            (\x ->
                case x of
                    1 ->
                        Attack

                    2 ->
                        Recover

                    3 ->
                        Rest

                    _ ->
                        Debug.crash "Invalid random value"
            )


generateElementType : Random.Generator ElementType
generateElementType =
    Random.int 1 5
        |> Random.map
            (\x ->
                case x of
                    1 ->
                        Fire

                    2 ->
                        Water

                    3 ->
                        Gold

                    4 ->
                        Wood

                    5 ->
                        Soil

                    _ ->
                        Debug.crash "Invalid random value"
            )


updateElement : ActionType -> ElementType -> Model -> Element -> Element
updateElement actionType elementType model self =
    if self.elementType == elementType then
        let
            downElement =
                downElementType self.elementType
                    |> flip lookupElement model

            upElement =
                upElementType self.elementType
                    |> flip lookupElement model

            inc =
                upElement.amount * 0.1

            dec =
                downElement.amount * 0.1

            newAmount =
                self.amount + inc - dec
        in
            { self | amount = newAmount }
    else
        self


downElementType : ElementType -> ElementType
downElementType elementType =
    case elementType of
        Water ->
            Fire

        Fire ->
            Gold

        Gold ->
            Wood

        Wood ->
            Soil

        Soil ->
            Water


upElementType : ElementType -> ElementType
upElementType elementType =
    let
        down1 =
            downElementType elementType

        down2 =
            downElementType down1
    in
        down2


lookupElement : ElementType -> Model -> Element
lookupElement elementType model =
    List.filterMap
        (\x ->
            if x.elementType == elementType then
                Just x
            else
                Nothing
        )
        model
        |> List.head
        |> \x ->
            case x of
                Nothing ->
                    Debug.crash
                        ("ElementType not found:"
                            ++ (toString
                                    { elementType = elementType
                                    , model = model
                                    }
                               )
                        )

                Just x ->
                    x


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second Tick


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
