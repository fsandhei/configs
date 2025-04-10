-- My XMonad config file
--
-- Dependencies
--    pacman -S alsa-utils dmenu xmobar alacritty tmux
--    yay -S betterlockscreen

import XMonad
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import Data.Monoid
import System.Exit

import XMonad.Layout.NoBorders
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows
import XMonad.Layout.ResizableTile
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts

import XMonad.Util.NamedScratchpad

-- Library that contains mapping of XF86 keyboard types.
-- Using this for having mapping of sound keys for now,
-- instead of using the ridiculously difficult keymap values.
import Graphics.X11.ExtraTypes.XF86

import Colors.DoomOne

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
-- myTerminal      = "tabbed -r 2 st -w ''"
myTerminal :: String
myTerminal = "alacritty -e tmux new-session"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces = ["dev", "www", "etc", "doc", "sys", "vbox", "mail"]

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor  = colorBack
myFocusedBorderColor = color14

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

   -- Lock screen   
    , ((modm .|. shiftMask, xK_l     ), spawn "betterlockscreen --lock blur")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Increase audio by 2%
    , ((0                , xF86XK_AudioLowerVolume), spawn ("amixer -q sset Master 5%-"))

    -- Decrease audio by 2%
    , ((0                , xF86XK_AudioRaiseVolume), spawn ("amixer -q sset Master 5%+"))

    -- Toggle audio 
    , ((0                , xF86XK_AudioMute), spawn ("amixer -q sset Master toggle"))

    -- Scratchpads
    , ((modm .|. controlMask, xK_c), namedScratchpadAction myScratchPads "calculator")

    , ((modm .|. shiftMask, xK_f), spawn ("firefox"))
    , ((modm .|. shiftMask, xK_g), spawn ("chromium"))
    , ((modm .|. shiftMask, xK_u), spawn ("pavucontrol")) -- spawns pavucontrol, for audio control (pulseaudio).
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--
--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Default layout. Yields the 'typical' tiling window style.
-- limitWindows set maximum number of visible windows
-- mySpacing sets the gap size around the windows in pixels
tall = renamed [Replace "tall"]
      $ limitWindows 5
      $ noBorders
      $ mySpacing 8
      $ subLayout [] (noBorders Simplest)
      $ ResizableTall 1 (3/100) (1/2) []

-- Full screen layout mode. Replaces the default one to have more styling.
full = renamed [Replace "full"]
      $ noBorders
      $ subLayout [] (noBorders Simplest)
      $ Full

myLayout = avoidStruts $ myDefaultLayout
   where
      myDefaultLayout = withBorder myBorderWidth tall ||| full

------------------------------------------------------------------------

myScratchPads :: [NamedScratchpad]
myScratchPads = [NS "calculator" spawnCalc findCalc manageCalc]
   where
      spawnCalc = "kcalc"
      findCalc = className =? spawnCalc
      manageCalc = customFloating $ W.RationalRect l t w h
         where
            l = 0.70 - w
            t = 0.75 - h
            w = 0.4
            h = 0.5

-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "firefox"        --> doShift (myWorkspaces !! 1)
    ] <+> namedScratchpadManageHook myScratchPads

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook xmproc0 xmproc1 = dynamicLogWithPP xmobarPP
  { ppLayout = wrap "(<fc=#e4b63c>" "</fc>)"
  , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"  -- Current workspace in xmobar
  , ppVisible = xmobarColor "#98be65" ""                 -- Non-focused (but still visible) screen
  , ppHidden = xmobarColor "#82aaff" "" . wrap "*" ""    -- Hidden workspaces in xmobar
  , ppHiddenNoWindows = xmobarColor "#c792ea" ""         -- Hidden workspaces but no windows in xmobar
  , ppSep = "<fc=#666666> | </fc>"                       -- Separators in xmobar
  , ppTitle = xmobarColor "#0acdff" "" . shorten 30      -- Title of active window in xmobar
  , ppOrder = \(ws:_:t:_) -> [ws]++[t]                   -- Formatting of input to xmobar
  , ppOutput = \x -> hPutStrLn xmproc0 x                 -- Instance of xmobar on monitor 1
               >> hPutStrLn xmproc1 x                    -- Instance of xmobar on monitor 2
  }

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.

myStartupHook :: X ()
myStartupHook = do
   spawnOnce "nitrogen --restore &"
   -- For better handling of mouse handling in X, for example having
   -- consistent and smooth scrolling.
   spawnOnce "imwheel &"
   spawnOnce "picom &"
   spawnOnce "dunst &"
   spawnOnce "conky --daemonize --pause=5"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
   xmproc0 <- spawnPipe "xmobar -x 0 /home/fredrik/.config/xmobar/xmobarrc"
   xmproc1 <- spawnPipe "xmobar -x 1 /home/fredrik/.config/xmobar/xmobarrc"
   xmonad $ docks $ def {
-- No need to modify this.
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc0 xmproc1,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]

