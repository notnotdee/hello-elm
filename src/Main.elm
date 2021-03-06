module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, map2, field, string)

-- Main

main = 
    Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- Model 

type Model 
    = Failure
    | Loading
    | Success (List Villager)

init : () -> (Model, Cmd Msg)
init _ = 
    (Loading, getVillager)


-- Update


type Msg
    = FindFriends 
    | GotVillager (Result Http.Error (List Villager))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 
        FindFriends ->
            (Loading, getVillager)
        
        GotVillager result ->
            case result of 
                Ok villager ->
                    (Success villager, Cmd.none)
                
                Err _ -> 
                    (Failure, Cmd.none)


-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- View


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "acnh villagers"]
        , viewVillagers model
        ]

viewVillagers : Model -> Html Msg
viewVillagers model = 
    case model of 
        Failure -> 
            div [ class "failure" ]
                [ text "i couldn't find any island friends :(" 
                , button [ onClick FindFriends ] [ text "try again!" ]
                ]
            
        Loading ->
            text "loading..."

        Success villager ->
            div [] 
                [ ul [ class "villager-list" ] ( renderVillagers villager ) ]

renderVillager : Villager -> Html Msg
renderVillager villager = 
    let
        children = 
            [ div [] 
                [ text villager.name ]
                    , img [ class "img", src villager.image] []
                ]
    in 
        li [ class "villager" ] children

renderVillagers : List Villager -> List (Html Msg)
renderVillagers villagers = 
    List.map renderVillager villagers


-- JSON Decoder


getVillager : Cmd Msg
getVillager =
    Http.get
        { url = "https://ac-vill.herokuapp.com/villagers?perPage=20"
        , expect = Http.expectJson GotVillager listDecoder
        }

type alias Villager = 
    { name : String
    , image : String
    }

villagerDecoder : Decoder Villager
villagerDecoder =
    map2 Villager
        (field "name" string)
        (field "image" string)
    
listDecoder : Decoder (List Villager)
listDecoder = 
    Json.Decode.list villagerDecoder

