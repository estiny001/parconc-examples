{-# LANGUAGE TemplateHaskell, DeriveDataTypeable #-}
import Remote
import Control.Monad.IO.Class
import Control.Monad
import Text.Printf
import Control.Concurrent
import Data.DeriveTH
import Data.Binary
import Data.Typeable

-- <<Message
data Message = Ping ProcessId
             | Pong ProcessId
  deriving Typeable

$( derive makeBinary ''Message )
-- >>

-- <<pingServer
pingServer :: ProcessM ()
pingServer = forever $ do
  m <- expect
  case m of
    Ping from -> do
      mypid <- getSelfPid
      send from (Pong mypid)
    _ -> return ()

$( remotable ['pingServer] )
-- >>

-- <<initialProcess
initialProcess :: String -> ProcessM ()
initialProcess "WORKER" = receiveWait []

initialProcess "MASTER" = do
  peers <- getPeers

  let workers = findPeerByRole peers "WORKER"

  ps <- forM workers $ \nid -> do
          say $ printf "spawning on %s" (show nid)
          spawn nid pingServer__closure

  mypid <- getSelfPid

  forM_ ps $ \pid -> do
    say $ printf "pinging %s" (show pid)
    send pid (Ping mypid)

  waitForPongs ps

  say "All pongs successfully received"
  terminate


waitForPongs [] = return ()
waitForPongs ps = do
  m <- expect
  case m of
    Pong p -> waitForPongs (filter (/= p) ps)
    _  -> say "MASTER received ping" >> terminate
-- >>

-- <<main
main = remoteInit (Just "config") [Main.__remoteCallMetaData] initialProcess
-- >>
