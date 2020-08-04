module Main exposing (..)

import Bytes exposing (Bytes)
import Bytes.Decode as BD
import Bytes.Encode as BE
import Http.Server.LowLevel as HSL
import Simplex


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


type Msg
    = GetRequest HSL.HttpRequest


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
                            ("<html>This page has been viewed <b>" ++ String.fromInt model.count ++ "</b> times.</html>")
                }
            )


main : Simplex.BackendProgram () Model Msg Never
main =
    Simplex.new
        { init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = \m -> HSL.subscribe GetRequest
        }
