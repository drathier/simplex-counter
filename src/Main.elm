module Main exposing (..)

import Bytes exposing (Bytes)
import Bytes.Decode as BD
import Bytes.Encode as BE
import Http.Server.LowLevel as HSL


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


type Msg
    = GetRequest
        { method : String -- GET, POST, ...
        , host : String -- example.com, always without port number
        , path : String -- /search?q=elm (remember #anchor is never sent to the server)
        , headers : List ( String, String ) -- raw headers, not yet normalized
        , body : Bytes
        , requestId : HSL.HttpRequestId
        }


update msg model =
    case msg of
        GetRequest req ->
            ( { model | count = model.count + 1 }
            , HSL.respond
                { requestId = req.requestId
                , status = 200
                , headers = [ ( "Content-Type", "text/html; charset=UTF-8" ) ]
                , body =
                    BE.encode <|
                        BE.string <|
                            List.foldr String.append
                                ""
                                [ "<html>This page has been viewed <b>"
                                , String.fromInt model.count
                                , "</b> times.</html>"
                                ]
                }
            )


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = \m -> HSL.subscribe GetRequest
        }
