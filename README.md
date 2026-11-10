> ⚠️ **Disclaimer: this project is 100% AI-generated code.** Every line of it was written by an AI (Claude, by Anthropic) from natural-language prompts. Review it before you rely on it, and use it at your own risk.

# Focus Timer

A KDE Plasma 6 widget that combines a **timer with presets**, a **Pomodoro** mode and a **Flowmodoro** mode in one place, with a countdown dial in the panel and configurable sounds.

---

## Introduction

I wanted a simple Plasmoid that had a timer and Pomodoro/Flowmodoro all in one package. As I have zero experience with qml, I vibe-coded it.

---

## Screenshots

<img width="348" height="493" alt="Screenshot_20261109_201212" src="https://github.com/user-attachments/assets/ff49973c-552b-40d6-ac78-967be1f2f7ba" />
<img width="348" height="493" alt="Screenshot_20261109_201223" src="https://github.com/user-attachments/assets/4fdc78a3-eb07-41ef-a287-abb87dcba2f5" />
<img width="348" height="493" alt="Screenshot_20261109_201233" src="https://github.com/user-attachments/assets/75993bdf-1861-4629-9a68-b15ab6fd3793" />

---

## Features

- **Three modes in one widget:** Timer, Pomodoro and Flowmodoro, switched with tabs at the top of the popup.
- **Timer presets:** one-click preset buttons that start immediately, plus a custom-minutes box.
- **Pomodoro:** focus, short break and long break phases with a configurable number of focus sessions before a long break.
- **Flowmodoro:** focus counts up with no limit. When you take a break, its length is your focus time divided by a ratio (default 5). It asks whether you want a break every N minutes (default 10).
- **Countdown dial:** the circle is full when a timer starts and empties as time runs out, in both the panel icon and the popup. Flowmodoro focus shows a spinner that grows and shrinks as it turns.
- **Panel display options:** icon only, timer only, or icon and timer. The icon is white when idle, dims when paused and turns dark grey during breaks.
- **Scroll to adjust:** scroll over the panel icon or the popup ring to add or remove a minute from the current countdown.
- **Middle-click:** starts a session from idle, pauses a running one and resumes a paused one.
- **Sounds:** an alert at the end of focus and at the end of a break, an optional sound when a phase starts, and an optional tick every second during focus.
- **Notifications:** a desktop notification when a phase ends. The Flowmodoro break prompt has **Take break** and **Keep going** buttons.
- **Settings sidebar:** General, Timer, Pomodoro, Flowmodoro and Sounds pages.

---

## Requirements

- KDE Plasma 6
- Qt Multimedia (for sounds). Without it the widget still works, just silently.
- Optional: the Ocean and freedesktop sound themes, used for the default alert sounds. If a sound file is missing, a bundled chime plays instead.

---

## Installation

**KDE Store**

- Install at: https://store.kde.org/p/2381528

**Manual**

Download `focustimer.plasmoid`, then use either method.

- Terminal

```bash
kpackagetool6 -t Plasma/Applet -i focustimer.plasmoid
```

- Graphical

1. Right-click the desktop or a panel and choose **Add or Manage Widgets**.
2. Choose **Get New Widgets**, then **Install Widget From Local File…**.
3. Select `focustimer.plasmoid`.

Then search for **Focus Timer** in Add Widgets and drag it onto a panel or the desktop.

- Updating

```bash
kpackagetool6 -t Plasma/Applet -u focustimer.plasmoid
kquitapp6 plasmashell; kstart plasmashell
```

- Uninstalling

```bash
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.focustimer
```

> The widget is meant for panels and the desktop. It does not support the system tray.

---

## Using the widget

### The panel icon

| Action | Result |
| --- | --- |
| Left-click | Open or close the popup |
| Middle-click | Start from idle, pause when running, resume when paused |
| Scroll up / down | Add or remove a minute from the current countdown |
| Right-click | Menu with Start / Pause / Resume and Stop |
| Hover | Tooltip with the phase and time left |

The icon is an outline circle with a filled wedge showing the time left. Idle it is a solid white outline; while running the wedge pulses gently, and when paused the whole icon dims. During a break it turns dark grey. In Flowmodoro focus the wedge becomes a spinning, growing and shrinking wedge.

### The popup

- **Tabs:** Timer, Pomodoro, Flowmodoro. They are disabled while a session is active, so press **Stop** to switch.
- **Ring:** shows the time and phase in the middle. It starts full and empties as time runs out.
- **Controls:**
  - Idle: a **Start** button in Pomodoro and Flowmodoro. In Timer mode, click a preset or use the custom box.
  - Active: **Pause / Resume** and **Stop**. In Flowmodoro focus there is also **Take break**.

### Timer mode

Click a preset (default 5, 10, 15, 25, 45 and 60 minutes) to start it immediately, or type a number of minutes in the custom box and press Start. When it finishes you get a sound and a notification, and the timer returns to its last length.

### Pomodoro mode

Focus (default 25 minutes), short break (5) and long break (15), with a long break after every 4 focus sessions. The popup counts your completed focus sessions. After each phase the next one loads, and starts automatically if you have turned on **Automatically start the next phase**.

### Flowmodoro mode

1. Press **Start** and focus for as long as you like. The timer counts up.
2. Every N minutes of focus (default 10) you are asked whether to take a break, with the break length shown. Clicking **Keep going** or ignoring it just means the next prompt arrives at the next interval.
3. Press **Take break** in the popup, or in the notification, when you are ready. The break lasts your focus time divided by the ratio (default 5), with a 30 second minimum.
4. When the break ends you are back to idle focus, and it starts again automatically if you have turned on auto-start.

---

## Sounds

Open **Settings → Sounds**.

- **Phase end:** a sound at the end of a focus session or timer, and another at the end of a break. Both default to `dialog-question.oga` from the Ocean sound theme.
- **Phase start:** an optional sound when a phase starts. It is off by default and does not play when you resume from a pause.
- **Volume:** one volume for the alert sounds, from 0 to 100 percent (default 70).
- **Ticking:** an optional tick every second during Pomodoro and Flowmodoro focus, with its own volume (default 30 percent). Off by default.
- **Choosing a sound:** pick a built-in sound or **Custom file…** for your own audio file (ogg, oga, wav, mp3 or flac). Every picker has a **Test** button.
- **Missing files:** if a chosen sound file is missing or cannot be played, the bundled chime plays instead.

---

## Do not Disturb
Currently, it isn't working; however, full DnD will be enabled in a future update.

---

## Settings reference

| Page | What you can change | Defaults |
| --- | --- | --- |
| **General** | Panel display (icon only, timer only, icon and timer); automatically start the next phase | Icon and timer; off |
| **Timer** | Preset list in minutes, comma-separated (decimals work, e.g. `0.5` is 30 seconds) | `5,10,15,25,45,60` |
| **Pomodoro** | Focus, short break and long break lengths; focus sessions before a long break | 25, 5, 15; 4 |
| **Flowmodoro** | Break ratio (break = focus ÷ ratio); suggest a break every N minutes (0 turns it off) | 5; 10 |
| **Sounds** | Phase-end sounds, start sound, tick, volumes | See above |

---

## Troubleshooting

- **The widget isn't in the Add Widgets list:** restart the shell with `kquitapp6 plasmashell; kstart plasmashell`, or log out and back in.
- **It's blank or shows an error:** run it in a window to see the messages: `plasmawindowed org.kde.plasma.focustimer`.
- **No sound:** check that the sound file exists and press **Test** on the Sounds page. Qt Multimedia must be installed. If your system also plays its own notification chime, you may hear two sounds. You can turn either one off.
- **A running timer disappears after restarting Plasma:** timers are not saved across shell restarts. Your settings are.

---

## Credits and license

Inspired by [Fokus](https://store.kde.org/p/1308861) (focus-plasmoid by diVinae), which this widget aims to match in features while adding timer presets, a repeating Flowmodoro break prompt and a countdown dial.

Licensed under **GPL-3.0+**.
