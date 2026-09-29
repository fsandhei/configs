-- My XMonad config
--
-- Dependencies (Arch):
--   pacman -S dmenu xmobar alacritty tmux dunst picom nitrogen thunar \
--             pavucontrol wireplumber maim xdotool xclip ttf-hack-nerd
--   yay -S betterlockscreen bluetuith
--
-- Also needed: ~/.config/xmonad/lib/Colors/DoomOne.hs, and an xmobarrc that
-- uses the XMonadLog plugin (this config publishes to _XMONAD_LOG).

import Data.Tree (Tree (Node))
import System.Exit (exitSuccess)
import System.IO (hClose, hPutStr)

import XMonad
import XMonad.Actions.TreeSelect
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (doCenterFloat, doRectFloat, isDialog)
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.ResizableTile (ResizableTall (..))
import XMonad.Layout.Spacing (Border (..), Spacing, spacingRaw)
import XMonad.Layout.ThreeColumns (ThreeCol (ThreeColMid))
import XMonad.Util.EZConfig (mkKeymap, mkNamedKeymap, removeKeysP)
import XMonad.Util.NamedActions
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce (spawnOnce)

import Colors.DoomOne

import qualified Data.Map as M
import qualified XMonad.StackSet as W

------------------------------------------------------------------------
-- Basics

-- Alacritty running tmux; used by mod-shift-return.
myTerminal :: String
myTerminal = "alacritty -e tmux new-session"

myModMask :: KeyMask
myModMask = mod4Mask -- Super

myBorderWidth :: Dimension
myBorderWidth = 2

myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor  = colorBack
myFocusedBorderColor = color11

------------------------------------------------------------------------
-- Workspaces (Nerd Font icon + name)

wsDev, wsWww, wsEtc, wsDoc, wsSys, wsVbox, wsMail :: WorkspaceId
wsDev  = "\xf489 dev"   -- nf-oct-terminal
wsWww  = "\xe745 www"   -- nf-dev-firefox
wsEtc  = "\xf02b etc"   -- nf-fa-tag
wsDoc  = "\xf15c doc"   -- nf-fa-file_text
wsSys  = "\xf085 sys"   -- nf-fa-cogs
wsVbox = "\xf1b2 vbox"  -- nf-fa-cube
wsMail = "\xf0e0 mail"  -- nf-fa-envelope

myWorkspaces :: [WorkspaceId]
myWorkspaces = [wsDev, wsWww, wsEtc, wsDoc, wsSys, wsVbox, wsMail]

------------------------------------------------------------------------
-- Key bindings
--
-- Built with XMonad.Util.NamedActions, so every binding carries a description.
-- Press mod-shift-/ to list them all in dmenu (type to filter, Esc to close).
--
-- My bindings are added on top of xmonad's defaults. The defaults are listed
-- too (via 'defaultKeysDescr'), minus any I override or remove.

type Keys = [((KeyMask, KeySym), NamedAction)]

-- My own bindings, grouped under subtitles.
myCustomKeys :: XConfig Layout -> Keys
myCustomKeys c = concat
  [ section "Session"
      [ ("M-g",   addName "Power menu"                   exitSelectAction)
      , ("M-S-l", addName "Lock screen"                  myLockScreen)
      , ("M-q",   run     "Recompile and restart xmonad" "xmonad --recompile && xmonad --restart")
      ]

  , section "Layout"
      [ ("M-b",   addName "Toggle status bar gap"        (sendMessage ToggleStruts))
      ]

  , section "Audio"
      [ ("<XF86AudioRaiseVolume>", run "Volume up 5%"   "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")
      , ("<XF86AudioLowerVolume>", run "Volume down 5%" "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-")
      , ("<XF86AudioMute>",        run "Toggle mute"    "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
      ]

  , section "Programs"
      [ ("M-C-f", run "File manager (Thunar)"  "thunar")
      , ("M-S-f", run "Firefox"                "firefox")
      , ("M-S-g", run "Chromium"               "chromium")
      , ("M-S-u", run "Audio mixer (pavucontrol)" "pavucontrol")
      , ("M-S-b", run "Bluetooth (bluetuith)"  "alacritty -e bluetuith")
      ]

  , section "Screenshots (to clipboard)"
      [ ("M-S-s", run "Screenshot: select region"
                      "maim -s | xclip -selection clipboard -t image/png")
      , ("M-C-s", run "Screenshot: active window"
                      "maim -i \"$(xdotool getactivewindow)\" | xclip -selection clipboard -t image/png")
      ]
  ]
  where
    section title ks = subtitle title : mkNamedKeymap c ks
    run desc cmd     = addName desc (spawn cmd)

-- Default bindings I don't want.
myRemovedKeys :: [String]
myRemovedKeys = ["M-S-p"] -- gmrun

-- Everything shown in the help list: the still-active defaults, then mine.
myKeys :: XConfig Layout -> Keys
myKeys c = filter (not . overridden . fst) (defaultKeysDescr c) ++ custom
  where
    custom     = myCustomKeys c
    customKeys = map fst custom
    removed    = mkKeymap c [(k, pure ()) | k <- myRemovedKeys]
    -- Subtitles use the key (0,0); never treat those as overridden.
    overridden k = k /= (0, 0) && (k `elem` customKeys || k `M.member` removed)

-- Show the keybinding list in dmenu (already a dependency; no xmessage needed).
showKeybindingsDmenu :: Keys -> NamedAction
showKeybindingsDmenu ks = addName "Show keybindings" . io $ do
  h <- spawnPipe "dmenu -l 35 -p 'keybindings:'"
  hPutStr h (unlines (showKm ks))
  hClose h

------------------------------------------------------------------------
-- Layouts

nmaster :: Int
nmaster = 1

delta, ratio :: Rational
delta = 3 / 100
ratio = 1 / 2

-- Uniform gap around windows and screen edges.
mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing i = spacingRaw False gap True gap True
  where gap = Border i i i i

threeCol = renamed [Replace "3col"]
         . limitWindows 7
         . mySpacing 5
         $ ThreeColMid nmaster delta ratio

tall = renamed [Replace "tall"]
     . limitWindows 5
     . smartBorders
     . mySpacing 8
     $ ResizableTall nmaster delta ratio []

full = renamed [Replace "full"]
     . smartBorders
     $ Full

-- avoidStruts keeps windows clear of the status bar.
myLayout = avoidStruts
         . lessBorders (Combine Difference Screen OnlyFloat)
         $ withBorder myBorderWidth threeCol ||| tall ||| full

------------------------------------------------------------------------
-- Window rules (find class names with: xprop | grep WM_CLASS)

myManageHook :: ManageHook
myManageHook = composeAll
  [ resource  =? "desktop_window" --> doIgnore
  , resource  =? "kdesktop"       --> doIgnore
  , className =? "firefox"        --> doShift wsWww
  , className =? "Thunar"         --> thunarRect
  , className =? "Pavucontrol"    --> doCenterFloat
  , isDialog                      --> doCenterFloat
  ]
  where
    -- Empirically chosen size/position.
    thunarRect = doRectFloat $ W.RationalRect (1/4) (1/4) (3/5) (3/5)

------------------------------------------------------------------------
-- Status bars (xmobar, fed through the _XMONAD_LOG property)

myXmobarPP :: PP
myXmobarPP = xmobarPP
  { ppLayout          = wrap "(<fc=#e4b63c>" "</fc>)"
  , ppCurrent         = xmobarColor "#98be65" "" . wrap "[" "]"
  , ppVisible         = xmobarColor "#98be65" ""
  , ppHidden          = xmobarColor "#82aaff" "" . wrap "*" ""
  , ppHiddenNoWindows = xmobarColor "#c792ea" ""
  , ppSep             = "<fc=#666666> | </fc>"
  , ppTitle           = xmobarColor "#0acdff" "" . shorten 30
  , ppOrder           = take 2 -- workspaces and layout only; drop the title
  }

xmobarOn :: Int -> StatusBarConfig
xmobarOn n = statusBarProp
  ("xmobar -x " ++ show n ++ " ~/.config/xmobar/xmobarrc")
  (pure myXmobarPP)

-- Dual-screen setup; harmless if the second screen isn't connected.
mySB :: StatusBarConfig
mySB = xmobarOn 0 <> xmobarOn 1

------------------------------------------------------------------------
-- Power menu (mod-g)

myLockScreen :: X ()
myLockScreen = spawn "betterlockscreen --lock blur"

-- Tree menu centred (roughly) on the current screen.
myTreeConf :: X (TSConfig a)
myTreeConf = withWindowSet $ \ws -> do
  let Rectangle _ _ w h = screenRect . W.screenDetail $ W.current ws
      centre d = fromIntegral d `div` 2 - 50
  pure def
    { ts_background  = 0xdd282c34
    , ts_font        = "xft:Hack Nerd Font:size=10:Regular"
    , ts_node        = (0xffd0d0d0, 0xff1c1f24)
    , ts_nodealt     = (0xffd0d0d0, 0xff282c34)
    , ts_highlight   = (0xffffffff, 0xff755999)
    , ts_extra       = 0xffd0d0d0
    , ts_node_width  = 200
    , ts_node_height = 20
    , ts_originX     = centre w
    , ts_originY     = centre h
    , ts_indent      = 80
    }

exitSelectAction :: X ()
exitSelectAction = do
  conf <- myTreeConf
  treeselectAction conf
    [ leaf "\xf0a48 Log out"    "Logs out from this session." (io exitSuccess)
    , leaf "\xf023 Lock screen" "Locks the screen."           myLockScreen
    , leaf "\xf011 Shutdown"    "Powers off the system."      (spawn "systemctl poweroff")
    , leaf "\xf0709 Restart"    "Restarts the system."        (spawn "systemctl reboot")
    , leaf "\xf073a Cancel"     "Exits this menu."            (pure ())
    ]
  where
    leaf name desc act = Node (TSNode name desc act) []

------------------------------------------------------------------------
-- Startup

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "nitrogen --restore" -- wallpaper
  spawnOnce "picom"              -- compositor
  spawnOnce "dunst"              -- notifications

------------------------------------------------------------------------

main :: IO ()
main = xmonad
     . ewmhFullscreen . ewmh
     . withSB mySB
     . docks
     $ myConfig

myConfig = (`removeKeysP` myRemovedKeys)
         . addDescrKeys' ((myModMask .|. shiftMask, xK_plus), showKeybindingsDmenu) myKeys
         $ def
  { terminal           = myTerminal
  , focusFollowsMouse  = True
  , clickJustFocuses   = False
  , borderWidth        = myBorderWidth
  , modMask            = myModMask
  , workspaces         = myWorkspaces
  , normalBorderColor  = myNormalBorderColor
  , focusedBorderColor = myFocusedBorderColor
  , layoutHook         = myLayout
  , manageHook         = myManageHook
  , startupHook        = myStartupHook
  }
